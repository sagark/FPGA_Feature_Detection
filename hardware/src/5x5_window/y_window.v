module y_window #(
	parameter h0 = 6,
	parameter h1 = 58,
	parameter h2 = 128
)(
	input reset,
	input clock,
	input [2:0] hsel,
	input [7:0] din0,
	input [7:0] din1,
	input [7:0] din2,
	input [7:0] din3,
	input [7:0] din4,
	input validin,
	output [7:0] dout,
	output validout);

	reg [7:0] OUT;
	reg [14:0] B0, B1, B2, B3, B4, C2, C4;
	reg [15:0] C0, C1;
	reg [16:0] C3;
	reg [17:0] C5;
	reg [2:0] valid_count;

	wire [7:0] divide_result_8;
	reg [7:0] coeff0, coeff1, coeff2, coeff3, coeff4;

	always @(posedge clock)
		if (reset) begin
			B0 <= 0;
			B1 <= 0;
			B2 <= 0;
			B3 <= 0;
			B4 <= 0;
			C0 <= 0;
			C1 <= 0;
			C2 <= 0;
			C3 <= 0;
			C4 <= 0;
			C5 <= 0;
			OUT <= 0;
		end
		else if (validin) begin
			B0 <= din0 * coeff0;
			B1 <= din1 * coeff1;
			B2 <= din2 * coeff2;
			B3 <= din3 * coeff3;
			B4 <= din4 * coeff4;
			C0 <= B0 + B1;
			C1 <= B2 + B3;
			C2 <= B4;
			C3 <= C0 + C1;
			C4 <= C2;
			C5 <= C3 + C4;
			OUT <= divide_result_8;
		end

	always @(*)
		case (hsel)
			3'b000: begin
				coeff0 = h0;
				coeff1 = h1;
				coeff2 = h2;
				coeff3 = h1;
				coeff4 = h0;
			end			
			3'b001: begin
				coeff0 = h0;
				coeff1 = h0;
				coeff2 = h1;
				coeff3 = h2;
				coeff4 = h1;
			end
			3'b010: begin
				coeff0 = h1;
				coeff1 = h0;
				coeff2 = h0;
				coeff3 = h1;
				coeff4 = h2;
			end
			3'b011: begin
				coeff0 = h2;
				coeff1 = h1;
				coeff2 = h0;
				coeff3 = h0;
				coeff4 = h1;
			end
			3'b100: begin
				coeff0 = h1;
				coeff1 = h2;
				coeff2 = h1;
				coeff3 = h0;
				coeff4 = h0;
			end
			default: begin
				coeff0 = h0;
				coeff1 = h1;
				coeff2 = h2;
				coeff3 = h1;
				coeff4 = h0;
			end
		endcase

	assign divide_result_8 = C5[15:8];

	assign validout = validin & (valid_count == 3'd5);

	assign dout = OUT;

	always @(posedge clock)
		if (reset) valid_count <= 0;
		else if (validin & (valid_count != 3'd5)) valid_count <= valid_count + 1;

endmodule
