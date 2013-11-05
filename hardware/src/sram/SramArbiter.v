module SramArbiter(
  // Application interface
  input reset,

  // W0
  input         w0_clock,
  output        w0_din_ready,
  input         w0_din_valid,
  input [53:0]  w0_din,// {mask,addr,data}

  // W1
  input         w1_clock,
  output        w1_din_ready,
  input         w1_din_valid,
  input [53:0]  w1_din,// {mask,addr,data}

  // R0
  input         r0_clock,
  output        r0_din_ready,
  input         r0_din_valid,
  input  [17:0] r0_din, // addr
  input         r0_dout_ready,
  output        r0_dout_valid,
  output [31:0] r0_dout, // data

  // R1
  input         r1_clock,
  output        r1_din_ready,
  input         r1_din_valid,
  input  [17:0] r1_din, // addr
  input         r1_dout_ready,
  output        r1_dout_valid,
  output [31:0] r1_dout, // data

  //`define MODELSIM
  `ifdef MODELSIM // Output for testbench
  output wire [2:0] state,
  output wire r0_data_write_output,
  output wire r1_data_write_output,
  output wire r0_rd_en_output,
  output wire r1_rd_en_output,
  input wire r0_prog_full,
  input wire r1_prog_full,
  `endif

  // SRAM Interface
  input         sram_clock,
  output        sram_addr_valid, // assigned
  input         sram_ready, //TODO WHAT TO DO WITH THIS?
  output [17:0] sram_addr,
  output [31:0] sram_data_in, // assigned
  output  [3:0] sram_write_mask, // assigned
  input  [31:0] sram_data_out,
  input         sram_data_out_valid);

// Clock crossing FIFOs --------------------------------------------------------

// The SRAM_WRITE_FIFOis have been instantiated for you, but you must wire it
// correctly

localparam DOW0 = 3'b000,
           DOW1 = 3'b001,
           DOR0 = 3'b010,
           DOR1 = 3'b011,
           PAUSE = 3'b100;

// Arbiter States
reg [2:0] CurrentState;
reg [2:0] NextState;

wire w0_valid; // if there are pending writes in the W0 fifo
wire w1_valid; // if there are pending writes in the W1 fifo

// bank of registers for keeping track of which read port data read from the
// SRAM needs to go 0 = R0, 1 = R1
reg next2; // next 3 cycle delay read-to port
reg this0; // current cycle's read-to port (only "valid" if this is a read)
reg this1; // next cycle's read-to port
reg this2; // next-next cycle's read-to-port


wire w0_rd_en, w1_rd_en; // enable reading from the SRAM_WRITE_FIFOs in DOW0 or DOW1
wire [53:0] w0dout, w1dout; // consists of {Write Mask, Addr, Data}

wire r0_data_write, r1_data_write; // write_enables for the Read DATA FIFOs, assigned below

`ifdef MODELSIM
assign r0_data_write_output = r0_data_write;
assign r1_data_write_output = r1_data_write;
`endif

wire r0_data_full, r1_data_full; // FULL marker for READ ADDR FIFOs. should eventually be
                                 // unnecessary when "backpressure" implemented

wire r0_addr_full, r1_addr_full;

wire r0_read_valid, r1_read_valid; // whether or not there are pending read requests 
                                   // addresses waiting in READ ADDR FIFO

wire r0_addr, r1_addr; // address value read from READ ADDR FIFO
wire r0_rd_en, r1_rd_en; // enable reading from READ ADDR FIFO to issue read req in DOR0 or DOR1

`ifdef MODELSIM
assign r0_rd_en_output = r0_rd_en;
assign r1_rd_en_output = r1_rd_en;
`endif

wire w0_full, w1_full; // asserted when SRAM_WRITE_FIFOs are full
assign w0_din_ready = !w0_full; // if full, not ready (no more requests)
assign w1_din_ready = !w1_full; // if full, not ready (no more requests)

assign w0_rd_en = (CurrentState == DOW0); // issue write to SRAM if we're in DOW0
assign w1_rd_en = (CurrentState == DOW1); // issue write to SRAM if we're in DOW1

//this is fine because we don't care what's on the sram_data_in line on R0 and R1
assign sram_data_in = (CurrentState == DOW0) ? w0dout[31:0] : w1dout[31:0];
assign sram_write_mask = (CurrentState == DOW0) ? w0dout[53:50] : ((CurrentState == DOW1) ? w1dout[53:50] : 4'b0000);
assign sram_addr = (CurrentState == DOW0) ? w0dout[49:32] : ((CurrentState == DOW1) ? w1dout[49:32] : ((CurrentState == DOR0) ? r0_addr : ((CurrentState == DOR1) ? r1_addr : 0)));
assign sram_addr_valid = (CurrentState == DOW0 || CurrentState == DOW1 || CurrentState == DOR0 || CurrentState == DOR1);

`ifdef MODELSIM
  assign w0_valid = w0_din_valid; // Use input to directly change state
`else
SRAM_WRITE_FIFO w0_fifo(
  .rst(reset),
  .wr_clk(w0_clock),
  .din(w0_din),
  .wr_en(w0_din_valid),
  .full(w0_full),

  .rd_clk(sram_clock), //sram_clock is our "internal clock"
  .rd_en(w0_rd_en), //assigned to (CurrentState == DOW0)
  .valid(w0_valid),
  .dout(w0dout),
  .empty()); // unused?
`endif

`ifdef MODELSIM
  assign w1_valid = w1_din_valid; // Use input to directly change state
`else
SRAM_WRITE_FIFO w1_fifo(
  .rst(reset),
  .wr_clk(w1_clock),
  .din(w1_din),
  .wr_en(w1_din_valid),
  .full(w1_full),

  .rd_clk(sram_clock), //sram_clock is our "internal clock"
  .rd_en(w1_rd_en), //assigned to (CurrentState == DOW1)
  .valid(w1_valid),
  .dout(w1dout),
  .empty()); // unused?
`endif


// Instantiate the Read FIFOs here
assign r0_data_write = sram_data_out_valid & (!this0);
assign r1_data_write = sram_data_out_valid & this0;

assign r0_din_ready = (!r0_addr_full); // TODO: backpressure
assign r1_din_ready = (!r1_addr_full); // TODO: backpressure

assign r0_rd_en = (CurrentState == DOR0);
assign r1_rd_en = (CurrentState == DOR1);

`ifdef MODELSIM
assign r0_dout = 0;
assign r0_dout_valid = 1;
assign r0_data_full = r0_prog_full;
`else
SRAM_DATA_FIFO r0_data_fifo(
  .rst(reset),
  .wr_clk(sram_clock),
  .din(sram_data_out),
  .wr_en(r0_data_write),
  .full(),

  .rd_clk(r0_clock),
  .rd_en(r0_dout_ready),
  .valid(r0_dout_valid),
  .dout(r0_dout),
  .empty(),
  .prog_full(r0_data_full));
`endif

`ifdef MODELSIM
assign r1_dout = 0;
assign r1_dout_valid = 1;
assign r1_data_full = r1_prog_full;
`else
SRAM_DATA_FIFO r1_data_fifo(
  .rst(reset),
  .wr_clk(sram_clock),
  .din(sram_data_out),
  .wr_en(r1_data_write),
  .full(),

  .rd_clk(r1_clock),
  .rd_en(r1_dout_ready),
  .valid(r1_dout_valid),
  .dout(r1_dout),
  .empty(),
  .prog_full(r1_data_full));
`endif


`ifdef MODELSIM
  assign r0_read_valid = r0_din_valid;
`else
SRAM_ADDR_FIFO r0_addr_fifo(
  .rst(reset),
  .wr_clk(r0_clock),
  .din(r0_din),
  .wr_en(r0_din_valid),
  .full(r0_addr_full),

  .rd_clk(sram_clock),
  .rd_en(r0_rd_en),
  .valid(r0_read_valid),
  .dout(r0_addr),
  .empty()); //unused?
`endif

`ifdef MODELSIM
  assign r1_read_valid = r1_din_valid;
`else
SRAM_ADDR_FIFO r1_addr_fifo(
  .rst(reset),
  .wr_clk(r1_clock),
  .din(r1_din),
  .wr_en(r1_din_valid),
  .full(r1_addr_full),

  .rd_clk(sram_clock),
  .rd_en(r1_rd_en),
  .valid(r1_read_valid),
  .dout(r1_addr),
  .empty()); //unused?
`endif


`ifdef MODELSIM // Output for testbench
assign state = CurrentState;
`endif


always @(posedge sram_clock) begin
    if (reset) begin
        CurrentState <= PAUSE;
        this0 <= 1'b0;
        this1 <= 1'b0;
        this2 <= 1'b0;
    end
    else begin
        CurrentState <= NextState;
        this0 <= this1;
        this1 <= this2;
        this2 <= next2;
    end
end


always @(*) begin
    case(CurrentState) 
        PAUSE: begin
            if(w0_valid) NextState = DOW0;
            else if(w1_valid) NextState = DOW1;
            else if( r0_read_valid & (!r0_data_full) ) NextState = DOR0;
            else if( r1_read_valid & (!r1_data_full)) NextState = DOR1;
            else NextState = PAUSE;
        end

        DOW0: begin
            if(w1_valid) NextState = DOW1;
            else if( r0_read_valid & (!r0_data_full)) NextState = DOR0;
            else if( r1_read_valid & (!r1_data_full)) NextState = DOR1;
            else if(w0_valid) NextState = DOW0;
            else NextState = PAUSE;
        end

        DOW1: begin
            if( r0_read_valid & (!r0_data_full)) NextState = DOR0;
            else if( r1_read_valid & (!r1_data_full)) NextState = DOR1;
            else if(w0_valid) NextState = DOW0;
            else if(w1_valid) NextState = DOW1;
            else NextState = PAUSE;
        end

        DOR0: begin
            next2 = 1'b0;
            if( r1_read_valid & (!r1_data_full)) NextState = DOR1;
            else if(w0_valid) NextState = DOW0;
            else if(w1_valid) NextState = DOW1;
            else if( r0_read_valid & (!r0_data_full)) NextState = DOR0;
            else NextState = PAUSE;
        end

        DOR1: begin
            next2 = 1'b1;
            if(w0_valid) NextState = DOW0;
            else if(w1_valid) NextState = DOW1;
            else if( r0_read_valid & (!r0_data_full)) NextState = DOR0;
            else if( r1_read_valid & (!r1_data_full)) NextState = DOR1;
            else NextState = PAUSE;
        end

    endcase
end


endmodule
