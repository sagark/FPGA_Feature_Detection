module Upsampler4x(
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

localparam NUMROW = 599;
localparam NUMCOL = 799;

wire [7:0] shift_reg_in;
wire [7:0] shift_reg_out;

reg [9:0] colcount;
reg [9:0] rowcount;

reg [9:0] prev_colcount;

wire [9:0] next_col;
wire [9:0] next_row;

wire sr_clk_en;

assign sr_clk_en = (rowcount % 4 != 0) | valid;
assign shift_reg_in = (rowcount % 4 == 0) ? data : shift_reg_out;
assign dataout = (rowcount % 4 != 0) ? shift_reg_out : data;
assign validout  = /*(push_extra > 100) ? 0 :*/ ((rowcount % 4 != 0) || valid );
assign next_col = ((valid || (rowcount % 4 != 0)) && (colcount == NUMCOL)) ? 0 : ((valid || (rowcount % 4 != 0)) ? (colcount + 1) : colcount);
assign next_row = ((colcount == NUMCOL) && (rowcount == NUMROW)) ? 0 : (((colcount == NUMCOL) && (prev_colcount == NUMCOL-1)) ? (rowcount + 1) : rowcount);
assign fifo_read = (colcount % 4 == 3) && (rowcount % 4 == 0);

assign current_colcount = colcount;
assign current_rowcount = rowcount;

shift_ram SR(
    .clk(clock),
    .q(shift_reg_out),
    .d(shift_reg_in),
    .ce(sr_clk_en),
    .sclr()
);

always @(posedge clock) begin
    if(reset) begin
        colcount <= 0;
        rowcount <= 0;
        prev_colcount <= 0;
    end else begin
        colcount <= next_col;
        rowcount <= next_row;
        prev_colcount <= colcount;
    end
end

endmodule
