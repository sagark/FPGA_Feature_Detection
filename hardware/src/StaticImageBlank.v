module StaticImageBlank(
    input clock,
    input reset,
    input [7:0] pixel,

    input valid,
    output ready,
    output [7:0] pixelout
);

localparam ROW_COMPARE = 650;
localparam COL_COMPARE = 850;


reg [9:0] rowcount;
reg [9:0] colcount;

wire [9:0] nextcolcount;
wire [9:0] nextrowcount;


assign nextrowcount = (rowcount == ROW_COMPARE ? 0 : (colcount == COL_COMPARE ? rowcount + 1 : rowcount));
assign nextcolcount = (colcount == COL_COMPARE ? 0 : (valid ? colcount + 1 : colcount));
assign ready = (rowcount < 600 && colcount < 800);
assign pixelout = ready ? pixel : 0;


always @(posedge clock) begin
    if (reset) begin
        rowcount <= 0;
        colcount <= 0;
    end else begin
        rowcount <= nextrowcount;
        colcount <= nextcolcount;
    end 
end



endmodule
