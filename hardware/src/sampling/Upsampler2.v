module Upsampler2(

    // this version does not contain a fifo - want to hook it up externally
    input clock,
    input reset,

    input valid,
    input [7:0] data,

    output [9:0] current_rowcount,
    output [9:0] current_colcount,

    output fifo_read,
    output [7:0] dataout,
    output validout
);

// DERP DERP DERP ENSURE CORRECT WIDTHS
wire [7:0] shift_reg_in;
wire [7:0] shift_reg_out;

reg [9:0] colcount;
reg [9:0] rowcount;

reg [9:0] prev_colcount;

wire [9:0] next_col;
wire [9:0] next_row;

reg prev_valid;

assign shift_reg_in = data;
assign dataout = (rowcount % 2 == 1) ? shift_reg_out : data;
assign validout  = ((rowcount % 2 == 1) || valid || prev_valid) && (rowcount < 600 && colcount < 800);
assign next_col = ((valid || prev_valid || rowcount % 2 == 1) && (colcount == 839)) ? 0 : ((valid || prev_valid || rowcount % 2 == 1) ? colcount + 1 : colcount);
assign next_row = ((colcount == 839) && (rowcount == 639)) ? 0 : ((colcount == 839 && prev_colcount == 838) ? rowcount + 1 : rowcount);
assign fifo_read = (colcount % 2 == 1) && (rowcount % 2 == 0);

assign current_colcount = colcount;
assign current_rowcount = rowcount;



shift_ram SR(
    .clk(clock),
    .q(shift_reg_out),
    .d(shift_reg_in)
);


always @(posedge clock) begin
    if(reset) begin
        prev_valid <= 0;
        colcount <= 0;
        rowcount <= 0;
        prev_colcount <= 0;
    end else begin
        prev_valid <= valid;
        colcount <= next_col;
        rowcount <= next_row;
        prev_colcount <= colcount;
    end
end

endmodule
