module five_by_five_window #(
	parameter width = 420
)(
	input reset,
	input clock,
	input [7:0] din,
	input blanking_in,
	input validin,
	output [7:0] dout,
	output blanking_out,
	output validout);

	wire [7:0] xin, xout;
	wire [7:0] ain, aout0, aout1, aout2, aout3, aout4;
	wire [7:0] yin0, yin1, yin2, yin3, yin4, yout;
	wire xvalidin, xvalidout, avalidin, avalidout, yvalidin, yvalidout;

	wire [2:0] hsel_wire;
	wire [4:0] asel_wire;

	reg [2:0] hsel;
	reg [4:0] asel;
	reg [8:0] x_count;

	x_window #() my_x_window(
		.clock(clock),
		.reset(reset),
		.validin(xvalidin),	
		.din(xin),
		.validout(xvalidout),
		.dout(xout));

	five_row_array #() my_five_row_array(
		.clock(clock),
		.reset(reset),
		.validin(avalidin),
		.asel(asel_wire),	
		.din(ain),
		.validout(avalidout),
		.dout0(aout0),
		.dout1(aout1),
		.dout2(aout2),
		.dout3(aout3),
		.dout4(aout4));

	y_window #() my_y_window(
		.clock(clock),
		.reset(reset),
		.validin(yvalidin),
		.hsel(hsel_wire),	
		.din0(yin0),
		.din1(yin1),
		.din2(yin2),
		.din3(yin3),
		.din4(yin4),
		.validout(yvalidout),
		.dout(yout));

	`define large_window
	`ifdef large_window
	wire intermediate;
	delay_1088 delay0 (.clk(clock), .sclr(reset), .ce(validin), .d(blanking_in), .q(intermediate));
	delay_184 delay1 (.clk(clock), .sclr(reset), .ce(validin), .d(intermediate), .q(blanking_out));
	`else
	delay_642 delay0 (.clk(clock), .sclr(reset), .ce(validin), .d(blanking_in), .q(blanking_out));
	`endif

	assign xin = blanking_in ? 8'b00000000 : din;
	assign xvalidin = validin;
	assign ain = xout;
	assign avalidin = xvalidout;
	assign yvalidin = avalidout;
	assign yin0 = aout0;
	assign yin1 = aout1;
	assign yin2 = aout2;
	assign yin3 = aout3;
	assign yin4 = aout4;
	assign dout = yout;
	assign asel_wire = asel;
	assign hsel_wire = hsel;
	assign validout = yvalidout;

	always @(posedge clock)
		if (reset) x_count <= 0;
		else if (validin & (x_count == width - 1)) x_count <= 0;
		else if (validin) x_count <= x_count + 1;

	always @(posedge clock)
		if (reset) asel <= 5'b00100;
		else if (validin & (x_count == width - 1))
			case (asel)
				5'b00001: asel <= 5'b00010;
				5'b00010: asel <= 5'b00100;
				5'b00100: asel <= 5'b01000;
				5'b01000: asel <= 5'b10000;
				5'b10000: asel <= 5'b00001;
				default: asel <= 5'b00001;
			endcase

	always @(posedge clock)
		if (reset) hsel <= 3'b001;
		else if (validin & (x_count == width - 1))
			if (hsel == 3'b100) hsel <= 3'b000;
			else hsel <= hsel + 1;

endmodule
