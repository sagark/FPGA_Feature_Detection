`timescale 1ns / 1ps

module five_by_five_testbench ();

	localparam num_tests = 134,400;
	localparam delay = 1272;

	reg reset;
	reg clock;

	reg [7:0] inputs [num_tests-1:0];
	reg [7:0] expected_outputs [num_tests-1:0];
	
	integer i, j;
	wire current_input;
	wire current_output;
	wire expected_output;
	wire blanking_out;
	wire valid_out;
	assign current_input = inputs[i];
	assign expected_output = expected_outputs[j];
	reg blanking_in;
	reg valid_in;
	wire blanking_in_wire;
	wire valid_in_wire;
	assign blanking_in_wire = blanking_in;
	assign valid_in_wire = valid_in;

	initial clock = 1;
	always #5 clock = ~clock;

	five_by_five_window #() dut(
		.reset(reset),
		.clock(clock),
		.din(current_input),
		.blanking_in(blanking_in_wire),
		.validin(valid_in_wire),
		.dout(current_out),
		.blanking_out(blanking_out),
		.valid_out(valid_out));

	initial begin
		i = 0;
		j = 0;
		valid_in = 0;
		reset = 1;
		$readmemh("gaussian_inputs.hex", inputs);
		$readmemh("gaussian_outputs.hex", expected_outputs);

		#40

		reset = 0;

		#40

		// Insert test code here

	end

endmodule
