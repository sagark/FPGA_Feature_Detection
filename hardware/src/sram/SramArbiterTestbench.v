`timescale 1ns / 1ps

module SramArbiterTestbench();

    // This module is used to test the basic functionality of the
    // SramArbiter module. It will make sure that all reads and
    // write work correctly and that all requests are serviced in
    // order.

    localparam num_tests = 26;

    reg sram_clock, port_clock;
    reg reset;

    // Arrays loaded from input files
    //reg [0:0] arbiter_w0 [num_tests-1:0];
    //reg [0:0] arbiter_w1 [num_tests-1:0];
    //reg [0:0] arbiter_r0 [num_tests-1:0];
    //reg [0:0] arbiter_r1 [num_tests-1:0];
    //reg [3:0] arbiter_input [num_tests-1:0];
    //reg [2:0] arbiter_output_expected [num_tests-1:0];

    wire w0, w1, r0, r1;
    reg w0_reg,w1_reg,r0_reg,r1_reg, r0_prog_full_reg, r1_prog_full_reg;
    wire sram_addr_valid, r0_data_write, r1_data_write, r0_read_en, r1_read_en, r0_prog_full, r1_prog_full;
    assign w0 = w0_reg;
    assign w1 = w1_reg;
    assign r0 = r0_reg;
    assign r1 = r1_reg;
    assign r0_prog_full = r0_prog_full_reg;
    assign r1_prog_full = r1_prog_full_reg;
    //wire [3:0] inputs;
    //wire [2:0] expected;
    wire [2:0] arbiter_output_actual;

    reg fail;

    integer i, j;

    initial sram_clock = 1;
    initial port_clock = 1;
    always #2 sram_clock = ~sram_clock; // sram clock is two increments long
    always #8 port_clock = ~port_clock; // port clock is eight increments long

    /*assign inputs = arbiter_input[i];
    assign w0 = inputs[3];
    assign w1 = inputs[2];
    assign r0 = inputs[1];
    assign r1 = inputs[0];
    assign expected = arbiter_output_expected[i];*/

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
	.r0_data_write_output(r0_data_write),
	.r1_data_write_output(r1_data_write),
	.r0_rd_en_output(r0_read_en),
	.r1_rd_en_output(r1_read_en),
	.r0_prog_full(r0_prog_full),
	.r1_prog_full(r1_prog_full),

	.sram_clock(sram_clock),
	.sram_addr_valid(sram_addr_valid),
	.sram_ready(1),
	.sram_addr(), // Don't care about this output
	.sram_data_in(), // Don't care about this output
	.sram_write_mask(), // Don't care about this output
	.sram_data_out(0),
	.sram_data_out_valid(1));

    initial begin
	i = 0;
	fail = 0;
	r0_prog_full_reg = 0;
	r1_prog_full_reg = 0;
	//$readmemh("arbiter_input.hex", arbiter_input);
       //$readmemh("arbiter_out.hex", arbiter_output_expected);

        reset = 1;
	#16 reset = 0;

	$display("Begin test of two complete sequences");
	w0_reg = 1;
	w1_reg = 1;
	r0_reg = 1;
	r1_reg = 1;
	for (i = 0; i < 2; i = i + 1) begin
		for (j = 0; j < 4; j = j + 1) begin
			#4;
			$display("Test %d: input: %b%b%b%b output: %d", (i*4)+j, w0,w1,r0,r1, arbiter_output_actual);
			if (arbiter_output_actual != j) begin
				$display("FAIL: expected: %d received: %d", j, arbiter_output_actual);
				fail = 1;
			end
		end
	end			

	#16	
	$display("Begin tests of arbiter service order transitions");	
	for (i = 0; i < 4; i = i + 1) begin
		for (j = 0; j < 4; j = j + 1) begin
			w0_reg = 0;
			w1_reg = 0;
			r0_reg = 0;
			r1_reg = 0;
			if (i == 0) w0_reg = 1;
			else if (i == 1) w1_reg = 1;
			else if (i == 2) r0_reg = 1;
			else r1_reg = 1;
			#4;
			$display("Test %d: input: %b%b%b%b output: %d", (i*4)+j, w0,w1,r0,r1, arbiter_output_actual);
			if (arbiter_output_actual != i) begin
				$display("FAIL: expected: %d received: %d", i, arbiter_output_actual);
				fail = 1;
			end
			w0_reg = 0;
			w1_reg = 0;
			r0_reg = 0;
			r1_reg = 0;
			if (j == 0) w0_reg = 1;
			else if (j == 1) w1_reg = 1;
			else if (j == 2) r0_reg = 1;
			else r1_reg = 1;
			#4;
			$display("Test %d: input: %b%b%b%b output: %d", (i*4)+j, w0,w1,r0,r1, arbiter_output_actual);
			if (arbiter_output_actual != j) begin
				$display("FAIL: expected: %d received: %d", j, arbiter_output_actual);
				fail = 1;
			end
		end
	end

	/*w0_reg = 1;
	w1_reg = 1;
	r0_reg = 1;
	r1_reg = 1;
	r0_prog_full_reg = 1;
	r1_prog_full_reg = 1;
	$display("Begin tests with full read FIFOs");
	for (i = 0; i < 64; i = i + 1) begin
		#4;
		if (r0_rd_en) begin
			$display("FAIL%d: r0_rd_en = 1, arbiter attempted to read from read address FIFO", i);
			fail = 1;
		end
		if (r1_rd_en) begin
			$display("FAIL%d: r1_rd_en = 1, arbiter attempted to read from read address FIFO", i);
			fail = 1;
		end
	end

	w0_reg = 0;
	w1_reg = 0;
	r0_reg = 0;
	r1_reg = 0;
	r0_prog_full_reg = 0;
	r1_prog_full_reg = 0;
	$display("Begin tests with empty request FIFOs")
	#4;
	if (sram_addr_valid) begin
		$display("FAIL0: sram_addr_valid = 1, arbiter attempted to submit a write");
		fail = 1;
	end
	for (i = 1; i < 65; i = i + 1) begin
		#4;
		if (sram_addr_valid) begin
			$display("FAIL%d: sram_addr_valid = 1, arbiter attempted to submit a write", i);
			fail = 1;
		end
		if (r0_data_write) begin
			$display("FAIL%d: r0_data_write = 1, arbiter attempted to write to r0", i);
			fail = 1;
		end
		if (r1_data_write) begin
			$display("FAIL%d: r1_data_write = 1, arbiter attempted to write to r1",i );
			fail = 1;
		end
	end*/						

        /*for (i = 0; i < num_tests; i = i + 1) begin
	    $display("Test %d: input: %b%b%b%b output: %d", i, w0,w1,r0,r1, arbiter_output_expected[i]);
	    #4;
            if (arbiter_output_expected[i] != arbiter_output_actual) begin
                $display("FAIL: expected: %d received: %d", arbiter_output_expected[i], arbiter_output_actual);
		fail = 1;
	    end
        end
	#64;*/
	if (fail == 0) $display("All tests passed.");
        $finish();
    end 


endmodule
