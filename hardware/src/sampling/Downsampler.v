module Downsampler(
    input clock,
    input reset,

    input valid,
    input [7:0] data,

    output reg [7:0] dataout,
    output reg validout,
    output reg blankingregion
);

localparam ROW_WITH_PAD = 639;
localparam COL_WITH_PAD = 839;

reg [12:0] rowcounter, colcounter;

wire validoutregin, blankingregionin;
wire [7:0] dataoutregin;
wire [12:0] next_row;
wire [12:0] next_col;

assign validoutregin = (rowcounter % 2 == 0) && (colcounter % 2 == 0) && (valid || blankingregionin);
assign blankingregionin = (rowcounter > 599) || (colcounter > 799);
assign dataoutregin = (blankingregionin ? 3 : data);
assign next_row = ((rowcounter == ROW_WITH_PAD) && (colcounter == COL_WITH_PAD)) ? 0 : ((colcounter == COL_WITH_PAD) ? (rowcounter + 1) : rowcounter);
assign next_col = (colcounter == COL_WITH_PAD) ? 0 : ((valid | blankingregionin) ? (colcounter + 1) : colcounter);


always @(posedge clock) begin
    if(reset) begin
        rowcounter <= 0;
        colcounter <= 0;
        dataout <= 0;
        validout <= 0;
        blankingregion <= 0;
    end else begin
        validout <= validoutregin; 
        rowcounter <= next_row;
        colcounter <= next_col;
        blankingregion <= blankingregionin;
        dataout <= dataoutregin;
    end
end

endmodule
