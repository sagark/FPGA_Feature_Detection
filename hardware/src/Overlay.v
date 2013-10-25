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

// This overlay will draw a 16x16 pixel + sign. Rows 7, 8, and columns
// 7, 8 will be green. The location of this pixel is determined by
// parameters LeftX and TopY. Those parameters describe the pixel in
// the output image that correspond to (0,0) in the 16x16 overlay.

// Indicate the top left corner of the 16x16 window of the pattern
localparam LeftX = 500;
localparam TopY = 250;
localparam vertical_bar_x = LeftX + 7; // The x value where the vertical bar starts
localparam horizontal_bar_y = TopY + 7; // The y value where the horizontal bar starts

// Components of dout
reg frame;
wire [16:0] addr;
reg [3:0] mask;

// Counters and state variables
reg [9:0] column;
reg [9:0] row;
reg horizontal_or_vertical; // 0 while drawing the horizontal bar
			    // 1 while drawing the vertical bar
reg started;

// Generate Green color for all pixels
wire [31:0] pixel;
assign pixel = 32'h02020202;

// Calculate byte address based on row and column
assign addr = row[9:2] + (200*column[9:0]);

// Calculate write mask based on column
always @(*)
	case(row[1:0])
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
  if (reset) begin
	row <= horizontal_bar_y;
	column <= LeftX;
	horizontal_or_vertical <= 1'b0;
  end
  else if (horizontal_or_vertical & inc) begin
    if (column == (LeftX+15)) begin
	if (row == (horizontal_bar_y + 1)) begin
	  horizontal_or_vertical <= 1'b1;
	  row <= TopY;
	  column <= vertical_bar_x;
	end
	else begin
	  row <= row + 1;
	  column <= LeftX;
	end
    end
	else
	  column <= column + 1;
  end
  else if (inc) begin
    if (column == (vertical_bar_x+1)) begin
	if (row == (TopY+15)) begin
	  horizontal_or_vertical <= 1'b0;
	  row <= horizontal_bar_y;
	  column <= LeftX;
        end
        else begin
	  row <= row + 1;
	  column <= vertical_bar_x;
	end
    end
    else
	column <= column + 1;
  end
  
always @(posedge clock)
  if (reset) begin
	done <= 1'b0;
	frame <= 1'b1;
  end
  else if (done & done_ack) done <= 1'b0;
  else if (inc & (column == (vertical_bar_x+1)) & (row == (TopY+15))) begin
	done <= 1'b1;
	frame <= ~frame;
  end

always @(posedge clock)
  if (reset) started <= 1'b0;
  else if (start) started <= 1'b1;
  else if (inc & (column == (vertical_bar_x+1)) & (row == (TopY+15))) started <= 1'b0;

always @(posedge clock)
  if(reset) start_ack <= 1'b0;
  else  start_ack <= start;

endmodule
