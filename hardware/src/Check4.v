module Check4 (
    input clock1,
    input clock2,
    input clock3,
    input reset,
    
    input [7:0] din,
    input valid,

    output [9:0] rowcount,
    output [9:0] colcount,


    output [7:0] dout,
    output validout
);

wire [7:0] down_to_five_data;
wire down_to_five_blank;
wire down_to_five_valid;

wire [7:0] five_to_up_data;
wire five_to_up_blank;
wire five_to_up_valid;


wire upsampler_valid_in = (!down_to_five_blank) && down_to_five_valid;


DownsamplerWrap down(
    .clock1(clock1),
    .clock2(clock2),
    .reset(reset),

    .valid(valid),
    .data(din),

    .dataout(down_to_five_data),
    .blankingregion(down_to_five_blank),
    .validout(down_to_five_valid)
);

UpsamplerWrap up(
    .clock1(clock2),
    .clock2(clock3),
    .reset(reset),

    .din(down_to_five_data),
    .valid(upsampler_valid_in),

    .rownum(rowcount),
    .colnum(colcount),

    .dataout(dout),
    .validout(validout)
);

/*
wire up_blank_in = (!five_to_up_blank) && five_to_up_valid;
DownsamplerWrap down(
    .clock1(clock1),
    .clock2(clock2),
    .reset(reset),

    .valid(valid),
    .data(din),

    .dataout(down_to_five_data),
    .blankingregion(down_to_five_blank), 
    .validout(down_to_five_valid)
);

five_by_five_window five(
	.reset(reset),
	.clock(clock2),
	.din(down_to_five_data),
	.blanking_in(down_to_five_blank),
	.validin(down_to_five_valid),

	.dout(five_to_up_data),
	.blanking_out(five_to_up_blank),
	.validout(five_to_up_valid)
);

UpsamplerWrap up(
    .clock1(clock2),
    .clock2(clock3),
    .reset(reset),

    .din(five_to_up_data),
    .valid(up_blank_in),

    .dataout(dout),
    .validout(validout)
);
*/
endmodule
