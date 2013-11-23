`timescale 1ns / 1ps

module Upsampler3Test();

	reg reset;
	reg clock;
	reg validin;
	
	wire fiforead;
	wire [7:0] dataout;
	wire validout;

	wire validin_wire;
	wire [7:0] datain_wire;

	integer i;
	integer fail_count, valid_count;
	reg [7:0] datain;

	reg [7:0] output_valuesA [799:0];
	reg [7:0] output_valuesB [799:0];
	reg [7:0] output_valuesC [799:0];
	reg [7:0] output_valuesD [799:0];

	assign validin_wire = validin;
	assign datain_wire = datain;

	initial clock = 1;
	always #10 clock = ~clock;

/*	Upsampler2 dut(
		.reset(reset), 
        	.clock(clock),

        	.valid(validin_wire),
        	.data(datain_wire),
		.fifo_read(fiforead),

        	.dataout(dataout),
        	.validout(validout)
    	);*/

    UpsamplerWrap dut(
        .reset(reset), 
        .clock1(clock),
        .clock2(clock),

        .valid(validin_wire),
        .din(datain_wire),

        .rownum(current_rowcount),
        .colnum(current_colcount),

        .dataout(dataout),
        .validout(validout)
    );

	initial begin
		$display("BEGINNING TEST");

		reset = 1;
		validin = 0;
		datain = 0;
		fail_count = 0;
		valid_count = 0;
		#40;
		reset = 0;
		#40;

		validin = 1;
		for (i = 0; i < 800; i = i + 1) begin
			if (validout) begin 
				if (valid_count < 800)
					output_valuesA[valid_count] = dataout;
				else if (valid_count < 1600)
					output_valuesB[valid_count - 800]= dataout;
				else if (valid_count < 2400)
					output_valuesC[valid_count - 1600]= dataout;
				else if (valid_count < 3200)
					output_valuesD[valid_count - 2400]= dataout;
				valid_count = valid_count + 1;
			end
			if (i == 399) begin validin = 0; #400; validin = 1; end
			if (i == 799) begin validin = 0; #400; validin = 1; end
			#20;
			datain = datain + 1;
		end
		validin = 0;

		for (i = 0; i < 40000; i = i + 1) begin
			if (validout) begin 
				if (valid_count < 800)
					output_valuesA[valid_count] = dataout;
				else if (valid_count < 1600)
					output_valuesB[valid_count - 800]= dataout;
				else if (valid_count < 2400)
					output_valuesC[valid_count - 1600]= dataout;
				else if (valid_count < 3200)
					output_valuesD[valid_count - 2400]= dataout;
				valid_count = valid_count + 1;
			end
			#20;	
		end
		$display("FINAL VALID COUNT: %d", valid_count);

		/*validin = 1;
		i = 0;
		for (i = 0; i < 800; i = i + 1) begin
			if (validout) begin valid_count = valid_count + 1; end
			//$display("datain: %d, validin %b, dataout: %d, validout %b, fiforead %b", datain_wire, validin_wire, dataout, validout, fiforead);
			if (fiforead == 1) begin datain = datain + 1; end
			#20;

		end
		validin = 0;
		$display("VALID COUNT %d", valid_count);
		for (i = 0; i < 820; i = i + 1) begin
			if (validout) begin valid_count = valid_count + 1; end
			//if (dataout != (i >> 1)) begin
				//$display("ERROR, EXPECTED: %d, RECIEVED: %d", (i>>1), dataout);
				//fail_count = fail_count + 1;
			//end
			if (fail_count > 19) $finish();
			#20;
		end
		$display("VALID COUNT %d", valid_count);*/
		$writememh("OUTPUTA.hex", output_valuesA);
		$writememh("OUTPUTB.hex", output_valuesB);
		$writememh("OUTPUTC.hex", output_valuesC);
		$writememh("OUTPUTD.hex", output_valuesD);
		$finish();
	end

endmodule
