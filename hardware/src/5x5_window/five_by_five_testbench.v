`timescale 1ns / 1ps

module five_by_five_testbench ();

	localparam num_tests = 134400;
	localparam delay = 1272;

	reg reset;
	reg clock;

	reg [7:0] inputs [num_tests+delay-1:0];
	reg [7:0] expected_outputs [num_tests-1:0];
	
	integer i, j, k, fail_count;
	wire [7:0] current_input;
	wire [7:0] current_out;
	wire [7:0] expected_output;
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
	always #10 clock = ~clock;

	five_by_five_window #() dut(
		.reset(reset),
		.clock(clock),
		.din(current_input),
		.blanking_in(blanking_in_wire),
		.validin(valid_in_wire),
		.dout(current_out),
		.blanking_out(blanking_out),
		.validout(valid_out));

	initial begin
		i = 0;
		j = 0;
		fail_count = 0;
		valid_in = 0;
		reset = 1;
		$readmemh("gaussian_test_input.hex", inputs);
		$readmemh("gaussian_test_output.hex", expected_outputs);

		#80

		reset = 0;

		#80
		valid_in = 1;
		for (i = 0; i < delay; i = i + 1) begin
			blanking_in = 0;
			for (k = 400; k < 420; k = k + 1) begin
				if ((i != 0) & (i % k == 0)) begin
					blanking_in = 1;
				end
			end
			if (valid_out == 1) begin
				$display("FAIL: Output is valid when it should not be.");
				fail_count  = fail_count + 1;
			end
			#20;
		end
		i  = i - 1;
		j = 0;
		while (j < num_tests) begin
			i = i + 1;
			blanking_in = 0;
			for (k = 400; k < 420; k = k + 1) begin
				if ((i != 0) & (i % k == 0)) begin
					blanking_in = 1;
				end
			end
			if (((current_out < expected_output-5) || (current_out > expected_output+5)) & ~((current_out == 0) & (expected_output == 0))) begin
				$display("FAIL: expected: %d received: %d Iteration: %d, blanking: %d", expected_output, current_out, j, blanking_out);
				fail_count = fail_count + 1;
			end
			if (valid_out != 1) begin
				$display("FAIL: Output is not valid when it should be.");
				fail_count  = fail_count + 1;
			end
			if (fail_count > 99) $finish();
			j = j + 1;
			#20;
		end
		if (fail_count == 0) $display("ALL TESTS PASSED");
		else $display("AT LEAST ONE FAILURE");
		$finish();
	end


endmodule
