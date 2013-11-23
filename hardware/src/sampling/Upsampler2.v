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

localparam NUMROW = 599;
localparam NUMCOL = 799;


// DERP DERP DERP ENSURE CORRECT WIDTHS
wire [7:0] shift_reg_in;
wire [7:0] shift_reg_out;

reg [9:0] colcount;
reg [9:0] rowcount;

reg [9:0] prev_colcount;

wire [9:0] next_col;
wire [9:0] next_row;

wire sr_clk_en;

//reg stop_everything;
//wire stop_everything2;

//reg [10:0] push_extra;
//wire [10:0] push_extra_in;

reg prev_valid;

assign sr_clk_en = (rowcount % 2 == 1) | valid | prev_valid;
assign shift_reg_in = data;
//assign dataout = (colcount % 2 == 0 ? 8'b00000000 : 8'b00000001 );
assign dataout = (rowcount % 2 == 1) ? shift_reg_out : data;
assign validout  = /*(push_extra > 100) ? 0 :*/ ((rowcount % 2 == 1) || valid || prev_valid);
assign next_col = ((valid || prev_valid || (rowcount % 2 == 1)) && (colcount == NUMCOL)) ? 0 : ((valid || prev_valid || (rowcount % 2 == 1)) ? (colcount + 1) : colcount);
assign next_row = ((colcount == NUMCOL) && (rowcount == NUMROW)) ? 0 : (((colcount == NUMCOL) && (prev_colcount == NUMCOL-1)) ? (rowcount + 1) : rowcount);
assign fifo_read = (colcount % 2 == 1) && (rowcount % 2 == 0);

//assign stop_everything2 = colcount == NUMCOL && rowcount == NUMROW;
//assign push_extra_in = stop_everything ? push_extra + 1 : 0;


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
        //push_extra <= 0;
        prev_valid <= 0;
        colcount <= 0;
        rowcount <= 0;
        prev_colcount <= 0;
        //stop_everything <= 0;
    end else begin
        prev_valid <= valid;
        colcount <= next_col;
        rowcount <= next_row;
        prev_colcount <= colcount;
/*        if (push_extra < 101) begin
            push_extra <= push_extra_in;
        end
        if (!stop_everything) begin
            stop_everything <= stop_everything2;
        end*/
    end
end

endmodule
