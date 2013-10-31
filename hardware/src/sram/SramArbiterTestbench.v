`timescale 1ns / 1ps

module SramArbiterTestbench()

    // This module is used to test the basic functionality of the
    // SramArbiter module. It will make sure that all reads and
    // write work correctly and that all requests are serviced in
    // order.

    localparam num_tests = 4;

    reg sram_clock, port_clock;
    reg [3:0] arbiter_input [num_tests-1:0];
    wire [3:0] input_vector;
    reg [2:0] arbiter_output_expected [num_tests-1:0];
    wire [2:0] arbiter_output_actual;
    wire reset;

    integer i;

    initial sram_clock = 0;
    initial port_clock = 0;
    always #1 sram_clock = ~sram_clock; // sram clock is two increments long
    always #4 port_clock = ~port_clock; // port clock is eight increments long

    // Instantiate arbiter, make and connect wires here
    SramArbiter dut(
  	.reset(reset),
        .w0_clock(port_clock),
	.w0_din_ready(INSERT OUTPUT HERE),
	.w0_din_valid(input_vector[0]),
	.w0_din(0),

	.w1_clock(port_clock),
	.w1_din_ready(INSERT OUTPUT HERE),
	.w1_din_valid(input_vector[1]),
	.w1_din(0),

	.r0_clock(port_clock),
	.r0_din_ready(INSERT OUTPUT HERE),
	.r0_din_valid(input_vector[2]),
	.r0_din(0), // addr
	.r0_dout_ready(1),
	.r0_dout_valid(INSERT OUTPUT HERE),
	.r0_dout(INSERT OUTPUT HERE), // data

	.r1_clock(port_clock),
	.r1_din_ready(INSERT OUTPUT HERE),
	.r1_din_valid(input_vector[3]),
	.r1_din(0), // addr
	.r1_dout_ready(1),
	.r1_dout_valid(INSERT OUTPUT HERE),
	.r1_dout(INSERT OUTPUT HERE), // data

	.state(arbiter_output_actual);

	.sram_clock(sram_clock),
	.sram_addr_valid(INSERT OUTPUT HERE),
	.sram_ready(1),
	.sram_addr(INSERT OUTPUT HERE),
	.sram_data_in(INSERT OUTPUT HERE),
	.ram_write_mask(INSERT OUTPUT HERE),
	.sram_data_out(0),
	.sram_data_out_valid(1));

    assign input_vector = arbiter_input[i];

    initial begin
        $readmemh("arbiter_in.input",arbiter_input);
        $readmemh("arbiter_out.input",arbiter_out_expected);

        reset = 1;
	#8 reset = 0;
        for (i = 0; i < num_tests; i++) begin
            if (arbiter_output_expected[i] != arbiter_output_actual)
                $display("FAIL: expected: %d received: %d", arbiter_output_expected[i], arbiter_output_actial);
        end
    end 

endmodule
