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
//reg valid_r;

wire validoutregin, dataoutregin, blankingregionin, rowreset, colreset;


// slightly modified from block diagram:
// and gate before validout reg has new input: (valid OR blankingregionin)
assign validoutregin = (rowcounter % 2 == 0) && (colcounter % 2 == 0) && (valid || blankingregionin);
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
        //valid_r <= 0;
    end else begin
        validout <= validoutregin; 
        rowcounter <= next_row;
        colcounter <= next_col;
        blankingregion <= blankingregionin;
        validout <= validoutregin;
        //valid_r <= valid;
    end
end

endmodule
