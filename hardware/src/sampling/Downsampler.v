module Downsampler(
    input clock,
    input reset,

    input valid,
    input [7:0] data,

    output reg [7:0] dataout,
    output reg validout,
    output reg blankingregion
);

reg [12:0] rowcounter, colcounter;
//reg valid_r;

wire validoutregin, blankingregionin;
wire [7:0] dataoutregin;
wire [12:0] next_row;
wire [12:0] next_col;

// slightly modified from block diagram:
// and gate before validout reg has new input: (valid OR blankingregionin)
assign validoutregin = (rowcounter % 2 == 0) && (colcounter % 2 == 0) && (valid || blankingregionin);
assign blankingregionin = (rowcounter > 599) || (colcounter > 799);
assign dataoutregin = (blankingregionin ? 3 : data);
assign next_row = ((rowcounter == 639) && (colcounter == 839)) ? 0 : ((colcounter == 839) ? (rowcounter + 1) : rowcounter);
assign next_col = (colcounter == 839) ? 0 : ((valid | blankingregionin) ? (colcounter + 1) : colcounter);


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
        dataout <= dataoutregin;
        //valid_r <= valid;
    end
end

endmodule
