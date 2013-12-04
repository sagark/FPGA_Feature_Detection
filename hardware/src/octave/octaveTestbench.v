`timescale 1ns / 1ps

module octaveTestbench ();

	localparam num_tests = 134400;
	localparam delay = 2545;

	reg reset;
	reg clock;

	reg [7:0] inputs [num_tests+delay-1:0];
	reg [7:0] expected_outputs [num_tests-1:0];
	
	integer i, j, fail_count;
	reg k;
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

	octave #() dut(
		.reset(reset),
		.clock(clock),
		.din(current_input),
		.blanking_in(blanking_in_wire),
		.validin(valid_in_wire),

		.d0_dout(current_out),
		.d0_valid(valid_out));

	initial begin

		$display("BEGIN TEST 1");
		i = 0;
		j = 0;
		k = 0;
		fail_count = 0;
		valid_in = 0;
		reset = 1;
		$readmemh("gaussian_test_input2.hex", inputs);
		$readmemh("gaussian_test_output2.hex", expected_outputs);

		#80

		reset = 0;

		#80
		valid_in = 1;
		for (i = 0; i < delay; i = i + 1) begin
			if (( (400 <= (i % 420)) && ((i % 420) <= 419) && (i != 0) ) || (i >= 126000) ) blanking_in = 1;
			else blanking_in = 0;
			if (valid_out == 1) begin
				$display("FAIL: Output is valid when it should not be. i=%d", i);
				fail_count  = fail_count + 1;
			end
			if (fail_count > 19) $finish();
			#20;
		end
		i  = i - 1;
		j = 0;
		while (i < num_tests) begin
			i = i + 1;
			if (( (400 <= (i % 420)) && ((i % 420) <= 419) && (i != 0) ) || (i >= 126000) ) blanking_in = 1;
			else blanking_in = 0;
			if (((current_out < expected_output-1) || (current_out > expected_output+1)) & (current_out != expected_output)) begin
				$display("FAIL: expected: %d received: %d Iteration: %d", expected_output, current_out, j);
				fail_count = fail_count + 1;
			end
			if (valid_out != 1) begin
				$display("FAIL: Output is not valid when it should be.");
				fail_count  = fail_count + 1;
			end
			if (fail_count > 19) $finish();
			j = j + 1;
			if (i == 47364) begin // Stall mid-frame 
				valid_in = 0;
				#740000;
				valid_in = 1;
			end
			#20;
		end
		valid_in = 0;
		#2688000
		
		$display("BEGIN TEST 2");
		k = 1;
		i = 0;
		j = 0;
		valid_in = 1;
		for (i = 0; i < delay; i = i + 1) begin
			if ( ( (400 <= (i % 420)) && ((i % 420) <= 419) && (i != 0) ) || (i >=126000) ) blanking_in = 1;
			else blanking_in = 0;
			if (fail_count > 19) $finish();
			#20;
		end
		i  = i - 1;
		j = 0;
		while (i < num_tests) begin
			i = i + 1;
			if ( ( (400 <= (i % 420)) && ((i % 420) <= 419) && (i != 0) ) || (i >=126000) ) blanking_in = 1;
			else blanking_in = 0;
			if (((current_out < expected_output-1) || (current_out > expected_output+1)) & (current_out != expected_output)) begin
				$display("FAIL: expected: %d received: %d Iteration: %d", expected_output, current_out, j);
				fail_count = fail_count + 1;
			end
			if (valid_out != 1) begin
				$display("FAIL: Output is not valid when it should be.");
				fail_count  = fail_count + 1;
			end
			if (fail_count > 19) $finish();
			j = j + 1;

			if (i == 45000) begin // Stall mid-frame 
				valid_in = 0;
				#1140000;
				valid_in = 1;
			end
			#20;
		end
		valid_in = 0;
		#200

		if (fail_count == 0) $display("ALL TESTS PASSED");
		else $display("AT LEAST ONE FAILURE");
		$finish();
	end


endmodule
