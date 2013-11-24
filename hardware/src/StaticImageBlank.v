module StaticImageBlank(
    input clock,
    input reset,
    input [7:0] pixel,

    input valid,
    output ready,
    output [7:0] pixelout
);

localparam ROW_COMPARE = 700;
localparam COL_COMPARE = 900;


reg [12:0] rowcount;
reg [12:0] colcount;

wire [12:0] nextcolcount;
wire [12:0] nextrowcount;


assign nextrowcount = (rowcount == ROW_COMPARE ? 0 : (colcount == COL_COMPARE ? rowcount + 1 : rowcount));
assign nextcolcount = (colcount == COL_COMPARE ? 0 : (valid ? colcount + 1 : colcount));
assign ready = (rowcount < 600 && colcount < 800) && valid;
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
