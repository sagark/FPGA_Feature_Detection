module Overlay #(
  parameter N_PIXEL = 480000)
(
  input clock,
  input reset,

  input scroll,

  input start,
  output reg start_ack,

  output reg done,
  input done_ack,

  output [53:0] dout,
  output valid,
  input ready);

// This overlay will draw a 16x16 green drawing over the image, by reading
// out pixel coordinates from a hex file.

// Indicate the top left corner of the 16x16 window of the pattern
localparam x_offset = 500;
localparam y_offset = 250;
localparam num_inputs = 59;

// Components of dout
reg frame;
wire [16:0] addr;
reg [3:0] mask;

// Inputs from file
wire [3:0] x_orig;
wire [3:0] y_orig;

// Pixel location orig+offset
wire [9:0] x;
wire [9:0] y;
assign x = x_offset + x_orig;
assign y = y_offset + y_orig;

// Counters and state variables
reg [7:0] input_count;
reg started;

// Load pixel coordinates from hex file
reg [7:0] pixel_coordinates [num_inputs-1:0];
wire [7:0] pixel_input;
initial begin
  $readmemh("initials.hex", pixel_coordinates);
end
assign pixel_input = pixel_coordinates[input_count];
assign x_orig = pixel_input[3:0];
assign y_orig = pixel_input[7:4];

// Generate Green color for all pixels
wire [31:0] pixel;
assign pixel = 32'h02020202;

// Calculate byte address based on row and column
assign addr = x[9:2] + (200*y[9:0]);

// Calculate write mask based on column
always @(*)
	case(x[1:0])
		2'b00: mask = 4'b0001;
		2'b01: mask = 4'b0010;
		2'b10: mask = 4'b0100;
		2'b11: mask = 4'b1000;
	endcase

// Concatenate mask, frame, addr, and pixel data
assign dout = {mask, frame, addr, pixel};

// Have a signal for when the output is incremented
wire inc;
assign inc = ready & started;
assign valid = started;

// Increment through row and column counter to make pattern
always @(posedge clock)
  if (reset)
    input_count <= 0;
  else if (inc & (input_count == num_inputs-1))
    input_count <= 0;
  else if (inc)
    input_count <= input_count + 1;
  
always @(posedge clock)
  if (reset) begin
	done <= 1'b0;
	frame <= 1'b1;
  end
  else if (done & done_ack) done <= 1'b0;
  else if (inc & (input_count == num_inputs-1)) begin
	done <= 1'b1;
	frame <= ~frame;
  end

always @(posedge clock)
  if (reset) started <= 1'b0;
  else if (start) started <= 1'b1;
  else if (inc & (input_count == num_inputs-1)) started <= 1'b0;

always @(posedge clock)
  if(reset) start_ack <= 1'b0;
  else  start_ack <= start;

endmodule
