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

  `ifdef MODELSIM // Output for testbench
  output reg [2:0] state;
  `endif

  // SRAM Interface
  input         sram_clock,
  output        sram_addr_valid,
  input         sram_ready,
  output [17:0] sram_addr,
  output [31:0] sram_data_in,
  output  [3:0] sram_write_mask,
  input  [31:0] sram_data_out,
  input         sram_data_out_valid);

// Clock crossing FIFOs --------------------------------------------------------

// The SRAM_WRITE_FIFOis have been instantiated for you, but you must wire it
// correctly

// following 3 lines handle correctly asserting w0_din_ready and w1_din_ready
wire w0_full, w1_full;
assign w0_din_ready = !w0_full;
assign w1_din_ready = !w1_full;

SRAM_WRITE_FIFO w0_fifo(
  .rst(reset),
  .wr_clk(w0_clock),
  .din(w0_din),
  .wr_en(w0_din_valid),
  .full(w0_full),

  .rd_clk(sram_clock), //sram_clock is our "internal clock"
  .rd_en(),
  .valid(w0_valid),
  .dout(),
  .empty());

SRAM_WRITE_FIFO w1_fifo(
  .rst(reset),
  .wr_clk(w1_clock),
  .din(w1_din),
  .wr_en(w1_din_valid),
  .full(w1_full),

  .rd_clk(sram_clock), //sram_clock is our "internal clock"
  .rd_en(),
  .valid(w1_valid),
  .dout(),
  .empty());

// Instantiate the Read FIFOs here

SRAM_DATA_FIFO r0_data_fifo(
  .rst(reset),
  .wr_clk(),
  .din(),
  .wr_en(),
  .full(),

  .rd_clk(),
  .rd_en(),
  .valid(),
  .dout(),
  .empty()
  .prog_full());

SRAM_DATA_FIFO r1_data_fifo(
  .rst(reset),
  .wr_clk(),
  .din(),
  .wr_en(),
  .full(),

  .rd_clk(),
  .rd_en(),
  .valid(),
  .dout(),
  .empty()
  .prog_full());

SRAM_ADDR_FIFO r0_addr_fifo(
  .rst(reset),
  .wr_clk(),
  .din(),
  .wr_en(),
  .full(),

  .rd_clk(),
  .rd_en(),
  .valid(),
  .dout(),
  .empty());

SRAM_ADDR_FIFO r1_addr_fifo(
  .rst(reset),
  .wr_clk(),
  .din(),
  .wr_en(),
  .full(),

  .rd_clk(),
  .rd_en(),
  .valid(),
  .dout(),
  .empty());


// Arbiter Logic ---------------------------------------------------------------

reg [2:0] readshift; // potential for off by one error - might need to be 3:0
reg [2:0] CurrentState;
reg [2:0] NextState;

`ifdef MODELSIM // Output for testbench
always @(*)
  if (currentState == DOW0) state = 3'b00;
  else if (currentState == DOW1) state = 3'b001;
  else if (currentState == DOR0) state = 3'b010;
  else if (currentState == DOR1) state = 3'b011;
  else if (currentState == PAUSE) state = 3'b100;
  else state = 3'b111;
`endif

// need reg to keep track of whether or not a read is supposed to happen next
// cycle

localparam DOW0 = 3'b000,
           DOW1 = 3'b001,
           DOR0 = 3'b010,
           DOR1 = 3'b011,
           PAUSE = 3'b100;


always @(posedge sram_clock) begin
    if (reset) CurrentState <= PAUSE;
    else CurrentState <= NextState;
end

wire w0_valid;
wire w1_valid;

always @(*) begin
    case(CurrentState) begin
        PAUSE: begin
            if(w0_valid) NextState = DOW0;
            else if(w1_valid) NextState = DOW1;
            else if( R0 COND HERE ) NextState = DOR0;
            else if( R1 COND HERE ) NextState = DOR1;
            else NextState = PAUSE;
        end

        DOW0: begin
            if(w1_valid) NextState = DOW1;
            else if( R0 COND HERE ) NextState = DOR0;
            else if( R1 COND HERE ) NextState = DOR1;
            else if(w0_valid) NextState = DOW0;
            else NextState = PAUSE;
        end

        DOW1: begin
            if( R0 COND HERE ) NextState = DOR0;
            else if( R1 COND HERE ) NextState = DOR1;
            else if(w0_valid) NextState = DOW0;
            else if(w1_valid) NextState = DOW1;
            else NextState = PAUSE;
        end

        DOR0: begin
            if( R1 COND HERE ) NextState = DOR1;
            else if(w0_valid) NextState = DOW0;
            else if(w1_valid) NextState = DOW1;
            else if( R0 COND HERE ) NextState = DOR0;
            else NextState = PAUSE;
        end

        DOR1: begin
            if(w0_valid) NextState = DOW0;
            else if(w1_valid) NextState = DOW1;
            else if( R0 COND HERE ) NextState = DOR0;
            else if( R1 COND HERE ) NextState = DOR1;
            else NextState = PAUSE;
        end

    end
end

// Put your round-robin arbitration logic here

endmodule
