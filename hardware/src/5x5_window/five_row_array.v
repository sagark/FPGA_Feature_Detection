module five_row_array #(
	parameter width = 420
)(
	input reset,
	input clock,
	input [7:0] din,
	input [4:0] asel,
	input validin,
	output [7:0] dout0,
	output [7:0] dout1,
	output [7:0] dout2,
	output [7:0] dout3,
	output [7:0] dout4,
	output validout);

	reg [10:0] valid_count;
	wire [7:0] array0_in, array0_out;
	wire [7:0] array1_in, array1_out;
	wire [7:0] array2_in, array2_out;
	wire [7:0] array3_in, array3_out;
	wire [7:0] array4_in, array4_out;

	generate
	if (width == 420) begin
		shift_ram_420 array0a(.clk(clock), .sclr(reset), .ce(validin), .d(array0_in), .q(array0_out));
		shift_ram_420 array1a(.clk(clock), .sclr(reset), .ce(validin), .d(array1_in), .q(array1_out));
		shift_ram_420 array2a(.clk(clock), .sclr(reset), .ce(validin), .d(array2_in), .q(array2_out));
		shift_ram_420 array3a(.clk(clock), .sclr(reset), .ce(validin), .d(array3_in), .q(array3_out));
		shift_ram_420 array4a(.clk(clock), .sclr(reset), .ce(validin), .d(array4_in), .q(array4_out));
	end
	else if (width == 210) begin
		shift_ram_210 array0b(.clk(clock), .sclr(reset), .ce(validin), .d(array0_in), .q(array0_out));
		shift_ram_210 array1b(.clk(clock), .sclr(reset), .ce(validin), .d(array1_in), .q(array1_out));
		shift_ram_210 array2b(.clk(clock), .sclr(reset), .ce(validin), .d(array2_in), .q(array2_out));
		shift_ram_210 array3b(.clk(clock), .sclr(reset), .ce(validin), .d(array3_in), .q(array3_out));
		shift_ram_210 array4b(.clk(clock), .sclr(reset), .ce(validin), .d(array4_in), .q(array4_out));	
	end
	endgenerate

	assign array0_in = asel[0] ? din : array0_out;
	assign array1_in = asel[1] ? din : array1_out;
	assign array2_in = asel[2] ? din : array2_out;
	assign array3_in = asel[3] ? din : array3_out;
	assign array4_in = asel[4] ? din : array4_out;

	assign dout0 = array0_out;
	assign dout1 = array1_out;
	assign dout2 = array2_out;
	assign dout3 = array3_out;
	assign dout4 = array4_out;

	assign validout = validin & (valid_count == 3 * width);

	always @(posedge clock)
		if (reset) valid_count <= 0;
		else if (validin & (valid_count != 3 * width)) valid_count <= valid_count + 1;
	

endmodule
