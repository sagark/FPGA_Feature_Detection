module Downsampler(
    input clock,
    input reset,

    input valid,
    input [7:0] data,

    output reg [7:0] dataout,
    output reg validout,
    output reg blankingregion
);

reg [9:0] rowcounter, colcounter;

wire validoutregin, dataoutregin, blankingregionin, rowreset, colreset;

assign validoutregin = (rowcounter % 2 == 0) && (colcounter % 2 == 0);
assign blankingregionin = (rowcounter > 599) || (colcounter > 799);
assign dataoutregin = (blankingregionin ? 8'b00000000 : data);
assign next_row = (rowcounter == 639) ? 0 : ((colcounter == 839) ? rowcounter + 1 : rowcounter);
assign next_col = (colcounter == 839) ? 0 : ((valid | blankingregionin) ? colcounter + 1 : colcounter);


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
        validout <= validoutregin;
    end
end

endmodule
