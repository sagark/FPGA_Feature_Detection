`timescale 1ns / 1ps

module octaveTestbench2 ();

	localparam full_frame = 33600;
	localparam pipe_delay = 642;

	reg reset;
	reg clock;
	
	integer i;
	integer g0_count, g1_count, g2_count, g3_count, g4_count;
	integer g0_count2, g1_count2, g2_count2, g3_count2, g4_count2;
	reg pause;

	wire [7:0] g0_out, g1_out, g2_out, g3_out, g4_out;
	wire g0_v, g1_v, g2_v, g3_v, g4_v;


	reg [7:0] din;
	reg blanking_in;
	reg valid_in;
	wire [7:0] din_wire;
	wire blanking_in_wire;
	wire valid_in_wire;
	assign din_wire = din;
	assign blanking_in_wire = blanking_in;
	assign valid_in_wire = valid_in;

	initial clock = 1;
	always #10 clock = ~clock;

	octave #(.difference_shift(0), .width(210)) dut(
		.reset(reset),
		.clock(clock),
		.din(din_wire),
		.blanking_in(blanking_in_wire),
		.validin(valid_in_wire),

		.g0_dout(g0_out),
		.g0_valid(g0_v),
		.g1_dout(g1_out),
		.g1_valid(g1_v),
		.g2_dout(g2_out),
		.g2_valid(g2_v),
		.g3_dout(g3_out),
		.g3_valid(g3_v),
		.g4_dout(g4_out),
		.g4_valid(g4_v)
	);

	initial begin

		$display("BEGIN TEST");
		i = 0;
		din = 0;
		g0_count = 0;
		g1_count = 0;
		g2_count = 0;
		g3_count = 0;
		g4_count = 0;
		g0_count2 = 0;
		g1_count2 = 0;
		g2_count2 = 0;
		g3_count2 = 0;
		g4_count2 = 0;
		valid_in = 0;
		pause = 0;
		reset = 1;

		#80

		reset = 0;

		#80
		valid_in = 1;
		blanking_in = 0;
		for (i = 0; i < (1*full_frame + (2*pipe_delay)); i = i + 1) begin
			if ( ((i % 210) == 0) || ((i % 33600) == 0) ) begin
				valid_in = 0;
				pause = 1;
				#200;
				valid_in = 1;
				pause = 0;
			end
			din = 255;
			if ( ((i % 210) >= 200) || ( (i % 33600) >= 31500 ) ) blanking_in = 1;
			else blanking_in = 0;
			if (g0_v) g0_count = g0_count + 1;
			if (g1_v) g1_count = g1_count + 1;
			if (g2_v) g2_count = g2_count + 1;
			if (g3_v) g3_count = g3_count + 1;
			if (g4_v) g4_count = g4_count + 1;
			if (g0_out != 0) g0_count2 = g0_count2 + 1;
			if (g1_out != 0) g1_count2 = g1_count2 + 1;
			if (g2_out != 0) g2_count2 = g2_count2 + 1;
			if (g3_out != 0) g3_count2 = g3_count2 + 1;
			if (g4_out != 0) g4_count2 = g4_count2 + 1;
			if ( (g0_out != 0) && (g0_v == 0) ) $display("FAIL0 NOT VALID WHEN SHOULD BE");
			if ( (g0_out == 0) && (g0_v != 0) ) $display("FAIL0 VALID WHEN SHOULD NOT BE");
			if ( (g1_out != 0) && (g1_v == 0) ) $display("FAIL1 NOT VALID WHEN SHOULD BE");
			if ( (g1_out == 0) && (g1_v != 0) ) $display("FAIL1 VALID WHEN SHOULD NOT BE");
			if ( (g2_out != 0) && (g2_v == 0) ) $display("FAIL2 NOT VALID WHEN SHOULD BE");
			if ( (g2_out == 0) && (g2_v != 0) ) $display("FAIL2 VALID WHEN SHOULD NOT BE");
			if ( (g3_out != 0) && (g3_v == 0) ) $display("FAIL3 NOT VALID WHEN SHOULD BE");
			if ( (g3_out == 0) && (g3_v != 0) ) $display("FAIL3 VALID WHEN SHOULD NOT BE");
			if ( (g4_out != 0) && (g4_v == 0) ) $display("FAIL4 NOT VALID WHEN SHOULD BE");
			if ( (g4_out == 0) && (g4_v != 0) ) $display("FAIL4 VALID WHEN SHOULD NOT BE");
			#20;
		end
		$display("g0 valid count is %d", g0_count);
		$display("g1 valid count is %d", g1_count);
		$display("g2 valid count is %d", g2_count);
		$display("g3 valid count is %d", g3_count);
		$display("g4 valid count is %d", g4_count);
		$display("g0 data count is %d", g0_count2);
		$display("g1 data count is %d", g1_count2);
		$display("g2 data count is %d", g2_count2);
		$display("g3 data count is %d", g3_count2);
		$display("g4 data count is %d", g4_count2);
		$finish();
	end


endmodule
