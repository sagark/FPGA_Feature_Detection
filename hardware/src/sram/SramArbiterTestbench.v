`timescale 1ns / 1ps

module SramArbiterTestbench();

    // This module is used to test the basic functionality of the
    // SramArbiter module. It will make sure that all reads and
    // write work correctly and that all requests are serviced in
    // order.

    localparam num_tests = 10;

    reg sram_clock, port_clock;
    reg reset;

    // Arrays loaded from input files
    reg [0:0] arbiter_w0 [num_tests-1:0];
    reg [0:0] arbiter_w1 [num_tests-1:0];
    reg [0:0] arbiter_r0 [num_tests-1:0];
    reg [0:0] arbiter_r1 [num_tests-1:0];
    reg [2:0] arbiter_output_expected [num_tests-1:0];

    wire w0, w1, r0, r1;
    wire [2:0] expected;
    wire [2:0] arbiter_output_actual;

    reg fail;

    integer i;

    initial sram_clock = 1;
    initial port_clock = 1;
    always #1 sram_clock = ~sram_clock; // sram clock is two increments long
    always #4 port_clock = ~port_clock; // port clock is eight increments long

    assign w0 = arbiter_w0[i];
    assign w1 = arbiter_w1[i];
    assign r0 = arbiter_r0[i];
    assign r1 = arbiter_r1[i];
    assign expected = arbiter_output_expected[i];

    // Instantiate arbiter, make and connect wires here
    SramArbiter dut(
  	.reset(reset),
        .w0_clock(port_clock),
	.w0_din_ready(),
	.w0_din_valid(w0),
	.w0_din(3),

	.w1_clock(port_clock),
	.w1_din_ready(),
	.w1_din_valid(w1),
	.w1_din(4),

	.r0_clock(port_clock),
	.r0_din_ready(),
	.r0_din_valid(r0),
	.r0_din(0), // addr
	.r0_dout_ready(1),
	.r0_dout_valid(), // Don't care about this output
	.r0_dout(),  // Don't care about this output

	.r1_clock(port_clock),
	.r1_din_ready(),
	.r1_din_valid(r1),
	.r1_din(0), // addr
	.r1_dout_ready(1),
	.r1_dout_valid(), // Don't care about this output
	.r1_dout(), // Don't care about this output

	.state(arbiter_output_actual),
	.r0_data_write_output(), //INSERT OUTPUT HERE
	.r1_data_write_output(), //INSERT OUTPUT HERE
	.r0_rd_en_output(), //INSERT OUTPUT HERE
	.r1_rd_en_output(), //INSERT OUTPUT HERE

	.sram_clock(sram_clock),
	.sram_addr_valid(), //INSERT OUTPUT HERE
	.sram_ready(1),
	.sram_addr(), // Don't care about this output
	.sram_data_in(), // Don't care about this output
	.sram_write_mask(), // Don't care about this output
	.sram_data_out(0),
	.sram_data_out_valid(1));

    initial begin
	i = 0;
	fail = 0;
        $readmemh("arbiter_w0.hex",arbiter_w0);
        $readmemh("arbiter_w1.hex",arbiter_w1);
        $readmemh("arbiter_r0.hex",arbiter_r0);
        $readmemh("arbiter_r1.hex",arbiter_r1);
        $readmemh("arbiter_out.hex",arbiter_output_expected);

        reset = 1;
	#8 reset = 0;

        for (i = 0; i < num_tests; i = i + 1) begin
            if (arbiter_output_expected[i] != arbiter_output_actual) begin
                $display("FAIL: expected: %d received: %d", arbiter_output_expected[i], arbiter_output_actual);
		fail = 1;
		end
	    #2;
        end
	#64;
	if (fail == 0) $display("All tests passed.");
        $finish();
    end 


endmodule
