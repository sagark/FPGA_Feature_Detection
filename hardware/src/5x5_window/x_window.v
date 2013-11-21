module x_window #(
	parameter h0 = 6,
	parameter h1 = 58,
	parameter h2 = 128
)(
	input reset,
	input clock,
	input [7:0] din,
	input validin,
	output [7:0] dout,
	output validout);

	reg [7:0] A0, B0, OUT;
	reg [14:0] A1, A2, A3, B1, B2, B3, C1, C2, C3, C4, C5;
	reg [15:0] B4, C6;
	reg [16:0] B5;
	reg [17:0] A4;
	reg [2:0] valid_count;

	wire [18:0] operand0, operand1, divide_result;
	wire [7:0] divide_result_8;


	always @(posedge clock)
		if (reset) begin
			A0 <= 0;
			A1 <= 0;
			A2 <= 0;
			A3 <= 0;
			A4 <= 0;
			B0 <= 0;
			B1 <= 0;
			B2 <= 0;
			B3 <= 0;
			B4 <= 0;
			B5 <= 0;
			C1 <= 0;
			C2 <= 0;
			C3 <= 0;
			C4 <= 0;
			C5 <= 0;
			C6 <= 0;
			OUT <= 0;
		end
		else if (validin) begin
			A0 <= B0;
			A1 <= A0 * h2;
			A2 <= A1;
			A3 <= A3;
			A4 <= B5 + A3;
			B0 <= din;
			B1 <= B0 * h1;
			B2 <= B1;
			B3 <= B2;
			B4 <= B1 + B3;
			B5 <= B4 + C6;
			C1 <= din * h0;
			C2 <= C1;
			C3 <= C2;
			C4 <= C3;
			C5 <= C4;
			C6 <= C1 + C5;
			OUT <= divide_result;
		end

	assign operand0 = { A4, 1'b0 };
	assign operand1 = { 1'b0, A4 };
	assign divide_result = operand0 + operand1;
	assign divide_result_8 = divide_result[18:11];

	assign validout = validin & (valid_count == 3'd7);

	assign dout = OUT;

	always @(posedge clock)
		if (reset) valid_count <= 0;
		else if (validin & (valid_count != 3'd7)) valid_count <= valid_count + 1;

endmodule

