module Upsampler(

    // this version does not contain a fifo - want to hook it up externally
    input clock,
    input reset,

    input valid,
    input [7:0] data,

    output [9:0] current_rowcount,
    output [9:0] current_colcount,

    output fifo_read,
    output [7:0] dataout,
    output reg validout
);

// DERP DERP DERP ENSURE CORRECT WIDTHS
wire [7:0] shift_reg_in;
wire [7:0] shift_reg_out;

reg [9:0] colcount;
reg [9:0] rowcount;

reg [7:0] data_int;

reg valid_r;

wire ord_valid;
wire [9:0] next_col;
wire [9:0] next_row;
wire enable_sig;
wire [7:0] next_data;

reg delay_mod1;
reg [7:0] sr_out_r; 

shift_ram SR(
    .clk(clock),
    .q(shift_reg_out),
    .d(shift_reg_in)
);


//assign sr_out_r = shift_reg_out;
assign ord_valid = valid_r | valid;
assign next_col = (colcount == 840 ? 0 : (ord_valid ? colcount + 1 : colcount));
assign next_row = (rowcount == 640 ? 0 : (colcount == 840 ? rowcount + 1 : rowcount));
assign enable_sig = valid && (colcount % 2 == 0) && (rowcount % 2 == 0);
assign next_data = (enable_sig ? data : data_int);
assign fifo_read = enable_sig;
assign shift_reg_in = data_int;
// NEED TO ASSIGN DATAOUT BASED ON SIGNAL
assign dataout = delay_mod1 ? sr_out_r : data_int;
assign valid_out_in = (rowcount < 600) && (colcount < 800) && ( ord_valid | (rowcount % 2 == 1));
assign delay_mod1_in = (rowcount % 2 == 1);
assign current_rowcount = rowcount;
assign current_colcount = colcount;



always @(posedge clock) begin
    if(reset) begin
        colcount <= 0;
        rowcount <= 0;
        valid_r <= 0;
        validout <= 0;
        delay_mod1 <= 0;
        data_int <= 0;
        sr_out_r <= 0;
    end else begin
        valid_r <= valid;
        colcount <= next_col;
        rowcount <= next_row;
        validout <= valid_out_in;
        delay_mod1 <= delay_mod1_in;
        data_int <= next_data;
        sr_out_r <= shift_reg_out;
    end
end

endmodule
