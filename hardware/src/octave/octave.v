module octave #(
	parameter width = 420,
	parameter difference_shift = 3
)(
	input reset,
	input clock,
	input [7:0] din,
	input validin,
	input blanking_in,
	
	output [7:0] g0_dout,
	output [7:0] g1_dout,
	output [7:0] g2_dout,
	output [7:0] g3_dout,
	output [7:0] g4_dout,

	output g0_valid,
	output g1_valid,
	output g2_valid,
	output g3_valid,
	output g4_valid,

	output [7:0] d0_dout,
	output [7:0] d1_dout,
	output [7:0] d2_dout,
	output [7:0] d3_dout,

	output d0_valid,
	output d1_valid,
	output d2_valid,
	output d3_valid,

	output [7:0] next_octave_dout,
	output next_octave_valid,
	output next_octave_blanking);

	wire [7:0] gauss0_dout, gauss1_dout, gauss2_dout, gauss3_dout, gauss4_dout;
	wire [7:0] shift0_dout, shift1_dout, shift2_dout, shift3_dout, shift4_dout;
	wire gauss0_validout, gauss1_validout, gauss2_validout, gauss3_validout, gauss4_validout;
	wire gauss0_blankingout, gauss1_blankingout, gauss2_blankingout, gauss3_blankingout, gauss4_blankingout;

	reg [8:0] d0,d1,d2,d3;
    reg d0_v,d1_v,d2_v,d3_v;

	// Instantiate each 5x5 window
	/*
	Octave 0:
	s=0, sigma_0 =   0.80  using row_filt=[   6.   58.  128.   58.    6.]
	s=1, sigma_1 =   1.01  using row_filt=[  14.   63.  102.   63.   14.]
	s=2, sigma_2 =   1.27  using row_filt=[ 24.  62.  84.  62.  24.]
	s=3, sigma_3 =   1.60  using row_filt=[ 33.  59.  72.  59.  33.]
	s=4, sigma_4 =   2.02  using row_filt=[ 39.  57.  64.  57.  39.]

	Octave 1:

	s=3, sigma_o =   1.60  using row_filt=[ 33.  59.  72.  59.  33.]
	s=4, sigma_o =   2.02  using row_filt=[ 39.  57.  64.  57.  39.]

	s=5, sigma_o =   2.54  using row_filt=[ 43.  55.  59.  55.  43.]
	s=6, sigma_o =   3.20  using row_filt=[ 46.  54.  56.  54.  46.]
	s=7, sigma_o =   4.03  using row_filt=[ 48.  53.  54.  53.  48.]
	*/

	generate
	if (width == 420) begin

	five_by_five_window #(.width(width), .h0(6), .h1(58), .h2(128)) gauss0a (
		.reset(reset),
		.clock(clock),
		.din(din),
		.blanking_in(blanking_in),
		.validin(validin),
		.dout(gauss0_dout),
		.validout(gauss0_validout),
		.blanking_out(gauss0_blankingout)
		);

	five_by_five_window #(.width(width), .h0(14), .h1(63), .h2(102)) gauss1a (
		.reset(reset),
		.clock(clock),
		.din(gauss0_dout),
		.blanking_in(gauss0_blankingout),
		.validin(gauss0_validout),
		.dout(gauss1_dout),
		.validout(gauss1_validout),
		.blanking_out(gauss1_blankingout)
		);

	five_by_five_window #(.width(width), .h0(24), .h1(62), .h2(84)) gauss2a (
		.reset(reset),
		.clock(clock),
		.din(gauss1_dout),
		.blanking_in(gauss1_blankingout),
		.validin(gauss1_validout),
		.dout(gauss2_dout),
		.validout(gauss2_validout),
		.blanking_out(gauss2_blankingout)
		);

	five_by_five_window #(.width(width), .h0(33), .h1(59), .h2(72)) gauss3a (
		.reset(reset),
		.clock(clock),
		.din(gauss2_dout),
		.blanking_in(gauss2_blankingout),
		.validin(gauss2_validout),
		.dout(gauss3_dout),
		.validout(gauss3_validout),
		.blanking_out(gauss3_blankingout)
		);

	five_by_five_window #(.width(width), .h0(39), .h1(57), .h2(64)) gauss4a (
		.reset(reset),
		.clock(clock),
		.din(gauss3_dout),
		.blanking_in(gauss3_blankingout),
		.validin(gauss3_validout),
		.dout(gauss4_dout),
		.validout(gauss4_validout),
		.blanking_out(gauss4_blankingout)
		);

	end else if (width == 210) begin

	five_by_five_window #(.width(width), .h0(33), .h1(59), .h2(72)) gauss0b (
		.reset(reset),
		.clock(clock),
		.din(din),
		.blanking_in(blanking_in),
		.validin(validin),
		.dout(gauss0_dout),
		.validout(gauss0_validout),
		.blanking_out(gauss0_blankingout)
		);

	five_by_five_window #(.width(width), .h0(39), .h1(57), .h2(64)) gauss1b (
		.reset(reset),
		.clock(clock),
		.din(gauss0_dout),
		.blanking_in(gauss0_blankingout),
		.validin(gauss0_validout),
		.dout(gauss1_dout),
		.validout(gauss1_validout),
		.blanking_out(gauss1_blankingout)
		);

	five_by_five_window #(.width(width), .h0(43), .h1(55), .h2(59)) gauss2b (
		.reset(reset),
		.clock(clock),
		.din(gauss1_dout),
		.blanking_in(gauss1_blankingout),
		.validin(gauss1_validout),
		.dout(gauss2_dout),
		.validout(gauss2_validout),
		.blanking_out(gauss2_blankingout)
		);

	five_by_five_window #(.width(width), .h0(46), .h1(54), .h2(56)) gauss3b (
		.reset(reset),
		.clock(clock),
		.din(gauss2_dout),
		.blanking_in(gauss2_blankingout),
		.validin(gauss2_validout),
		.dout(gauss3_dout),
		.validout(gauss3_validout),
		.blanking_out(gauss3_blankingout)
		);

	five_by_five_window #(.width(width), .h0(48), .h1(53), .h2(54)) gauss4b (
		.reset(reset),
		.clock(clock),
		.din(gauss3_dout),
		.blanking_in(gauss3_blankingout),
		.validin(gauss3_validout),
		.dout(gauss4_dout),
		.validout(gauss4_validout),
		.blanking_out(gauss4_blankingout)
		);

	end
	endgenerate

	// Create shift registers to delay 5x5 outputs for the purpose of taking the difference
	generate
	if (width == 420) begin
		wire [7:0] inter0, inter1, inter2, inter3, inter4;
		shiftdelay_1088 delay0a (.clk(clock), .sclr(reset), .ce(gauss0_validout), .d(gauss0_dout), .q(inter0));
		shiftdelay_184  delay0b (.clk(clock), .sclr(reset), .ce(gauss0_validout), .d(inter0), .q(shift0_dout));
		shiftdelay_1088 delay1a (.clk(clock), .sclr(reset), .ce(gauss1_validout), .d(gauss1_dout), .q(inter1));
		shiftdelay_184  delay1b (.clk(clock), .sclr(reset), .ce(gauss1_validout), .d(inter1), .q(shift1_dout));
		shiftdelay_1088 delay2a (.clk(clock), .sclr(reset), .ce(gauss2_validout), .d(gauss2_dout), .q(inter2));
		shiftdelay_184  delay2b (.clk(clock), .sclr(reset), .ce(gauss2_validout), .d(inter2), .q(shift2_dout));
		shiftdelay_1088 delay3a (.clk(clock), .sclr(reset), .ce(gauss3_validout), .d(gauss3_dout), .q(inter3));
		shiftdelay_184  delay3b (.clk(clock), .sclr(reset), .ce(gauss3_validout), .d(inter3), .q(shift3_dout));
		shiftdelay_1088 delay4a (.clk(clock), .sclr(reset), .ce(gauss4_validout), .d(gauss4_dout), .q(inter4));
		shiftdelay_184  delay4b (.clk(clock), .sclr(reset), .ce(gauss4_validout), .d(inter4), .q(shift4_dout));

	end
	else if (width == 210) begin
		shiftdelay_642 delay0 (.clk(clock), .sclr(reset), .ce(gauss0_validout), .d(gauss0_dout), .q(shift0_dout));
		shiftdelay_642 delay1 (.clk(clock), .sclr(reset), .ce(gauss1_validout), .d(gauss1_dout), .q(shift1_dout));
		shiftdelay_642 delay2 (.clk(clock), .sclr(reset), .ce(gauss2_validout), .d(gauss2_dout), .q(shift2_dout));
		shiftdelay_642 delay3 (.clk(clock), .sclr(reset), .ce(gauss3_validout), .d(gauss3_dout), .q(shift3_dout));
		shiftdelay_642 delay4 (.clk(clock), .sclr(reset), .ce(gauss4_validout), .d(gauss4_dout), .q(shift4_dout));
	end
	endgenerate

	// Registers to pipeline difference calculations
	always @(posedge clock) begin
		if (reset) begin
            d0 <= 9'b100000000;
            d0_v <= 0;
        end
		else if (gauss1_validout) begin
            d0 <= {gauss1_blankingout, ((shift0_dout - gauss1_dout) << difference_shift)};
            d0_v <= 1;
        end
        else d0_v <= 0;
	end

	always @(posedge clock) begin
		if (reset) begin
            d1 <= 9'b100000000;
            d1_v <= 0;
        end
		else if (gauss2_validout) begin
            d1 <= {gauss2_blankingout, ((shift1_dout - gauss2_dout) << difference_shift)};
            d1_v <= 1;
        end
        else d1_v <= 0;
	end

	always @(posedge clock) begin
		if (reset) begin
            d2 <= 9'b100000000;
            d2_v <= 0;
        end
		else if (gauss3_validout) begin
            d2 <= {gauss3_blankingout, ((shift2_dout - gauss3_dout) << difference_shift)};
            d2_v <= 1;
        end
        else d2_v <= 0;
	end

	always @(posedge clock) begin
		if (reset) begin
            d3 <= 9'b100000000;
            d3_v <= 0;
        end
		else if (gauss4_validout) begin
            d3 <= {gauss4_blankingout, ((shift3_dout - gauss4_dout) << difference_shift)};
            d3_v <= 1;
        end
        else d3_v <= 0;
	end


	// Assign outputs for gaussian images
	assign g0_dout = gauss0_dout;
	assign g1_dout = gauss1_dout;
	assign g2_dout = gauss2_dout;
	assign g3_dout = gauss3_dout;
	assign g4_dout = gauss4_dout;
	assign g0_valid = gauss0_validout & (~gauss0_blankingout);
	assign g1_valid = gauss1_validout & (~gauss1_blankingout);
	assign g2_valid = gauss2_validout & (~gauss2_blankingout);
	assign g3_valid = gauss3_validout & (~gauss3_blankingout);
	assign g4_valid = gauss4_validout & (~gauss4_blankingout);

	// Assign outputs for difference images
	assign d0_dout = d0[7:0];
	assign d1_dout = d1[7:0];
	assign d2_dout = d2[7:0];
	assign d3_dout = d3[7:0];
	assign d0_valid = ~d0[8] & d0_v;
	assign d1_valid = ~d1[8] & d1_v;
	assign d2_valid = ~d2[8] & d2_v;
	assign d3_valid = ~d3[8] & d3_v;

	// Assign outputs to the next octave
	assign next_octave_dout = gauss3_dout;
	assign next_octave_valid = gauss3_validout;
	assign next_octave_blanking = gauss3_blankingout;

endmodule
