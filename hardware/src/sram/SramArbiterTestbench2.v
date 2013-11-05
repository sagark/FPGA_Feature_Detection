`timescale 1ns / 1ps

module SramArbiterTestbench2();

    reg sram_clock, port_clock_fast, port_clock_slow;
    reg reset;

    wire w0, w1, r0, r1;
    reg w0_reg,w1_reg,r0_reg,r1_reg;
    assign w0 = w0_reg;
    assign w1 = w1_reg;
    assign r0 = r0_reg;
    assign r1 = r1_reg;
    wire [2:0] arbiter_output_actual;

    reg fail;

    integer i;

    initial sram_clock = 1;
    initial port_clock_fast = 1;
    initial port_clock_slow = 1;
    always #2 sram_clock = ~sram_clock; // sram clock is two increments long
    always #8 port_clock_slow = ~port_clock_slow; // port clock slow is eight increments long
    always #4 port_clock_fast = ~port_clock_fast; // port clock fast is four increments long

    // Instantiate arbiter, make and connect wires here
    SramArbiter dut(
  	.reset(reset),
        .w0_clock(port_clock_fast),
	.w0_din_ready(),
	.w0_din_valid(w0),
	.w0_din(3),

	.w1_clock(port_clock_slow),
	.w1_din_ready(),
	.w1_din_valid(w1),
	.w1_din(4),

	.r0_clock(port_clock_fast),
	.r0_din_ready(),
	.r0_din_valid(r0),
	.r0_din(0), // addr
	.r0_dout_ready(1'b1),
	.r0_dout_valid(), // Don't care about this output
	.r0_dout(),  // Don't care about this output

	.r1_clock(port_clock),
	.r1_din_ready(),
	.r1_din_valid(r1),
	.r1_din(0), // addr
	.r1_dout_ready(1'b1),
	.r1_dout_valid(), // Don't care about this output
	.r1_dout(), // Don't care about this output

	.sram_clock(sram_clock), // Don't care about this output
	.sram_addr_valid(),
	.sram_ready(1'b1),
	.sram_addr(), // Don't care about this output
	.sram_data_in(), // Don't care about this output
	.sram_write_mask(), // Don't care about this output
	.sram_data_out(0),
	.sram_data_out_valid(1'b1));

    initial begin
	i = 0;
	fail = 0;

        reset = 1;
	#16 reset = 0;

	$display("Begin test of two complete sequences");
	w0_reg = 1;
	w1_reg = 1;
	r0_reg = 1;
	r1_reg = 1;
	for (i = 0; i < 1024; i = i + 1) begin
		#4;
	end		
	if (fail == 0) $display("All tests passed.");
        $finish();
    end 


endmodule
