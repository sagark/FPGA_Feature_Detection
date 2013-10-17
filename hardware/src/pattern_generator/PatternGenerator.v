module PatternGenerator(
	input reset,
	input clock,
	input VideoReady,
	output reg VideoValid,
	output [23:0] Video);

	// This pattern generator will make a pattern for one second
	// and then invert the colors for the next second

	parameter VISIBLE_WIDTH = 10'd800;
	parameter VISIBLE_HEIGHT = 10'd600;
	parameter FRAME_RATE = 7'd72;

	//parameter Q1_color = 24'h00CC01; // BAD color value to inject error
	parameter Q1_color = 24'h00CC00; // CORRECT color value for Q1
	parameter Q2_color = 24'h00CCCC;
	parameter Q3_color = 24'hFF9A26;
	parameter Q4_color = 24'h9D26FF;
	
	reg invert;
	reg [6:0] frame_count;
	reg [9:0] horiz_pixel_count;
	reg [9:0] vertical_pixel_count;
	reg HState;
	reg VState;
	reg [23:0] OrigVideo;

	reg last_horiz_position;
	reg last_vertical_position;
	reg last_frame_in_sec;

	always @(*) begin
		if (horiz_pixel_count == (VISIBLE_WIDTH-1)) last_horiz_position = 1;
		else last_horiz_position = 0;
		if (vertical_pixel_count == (VISIBLE_HEIGHT-1)) last_vertical_position = 1;
		else last_vertical_position = 0;
		if (frame_count == (FRAME_RATE-1)) last_frame_in_sec = 1;
		else last_frame_in_sec = 0;
	end

	always @(posedge clock)
		if (reset) VideoValid <= 0;
		else if (VideoReady) VideoValid <= 1;
		else VideoValid <= 0;

	// This is used to count 72 frames and then wrap around. Used to invert colors at 1Hz
	always @(posedge clock)
		if (reset) frame_count <= 0;
		else if (last_horiz_position & last_vertical_position & VideoValid)
			if (last_frame_in_sec) frame_count <= 0;
			else frame_count <= frame_count + 1;

	// This is used to keep track of horizontal position in the frame
	always @(posedge clock)
		if (reset) horiz_pixel_count <= 0;
		else if (last_horiz_position & VideoValid) horiz_pixel_count <= 0;
		else if (VideoValid) horiz_pixel_count <= horiz_pixel_count + 1;

	// This is used to keep track of vertical position in the frame
	always @(posedge clock)
		if (reset) vertical_pixel_count <= 0;
		else if (last_horiz_position & VideoValid)
			if (last_vertical_position) vertical_pixel_count <= 0;
			else vertical_pixel_count <= vertical_pixel_count + 1;

	// This is used to determine if pre-defined colors should be inverted
	always @(posedge clock)
		if (reset) invert <= 0;
		else if (last_frame_in_sec & last_horiz_position & last_vertical_position & VideoValid) invert <= ~invert;

	// FSM for Horizontal Pattern. Each block in the pattern is 128 pixels wide and each sub-block is 64 pixels wide
	always @(posedge clock)
		if (reset) HState <= 0;
		else if (last_horiz_position & VideoValid) HState <= 0;
		else if ((&horiz_pixel_count[5:0]) & VideoValid) HState <= ~HState;

	// FSM for Vertical Pattern. Each block in the pattern is 64 pixels tall and each sub-block is 32 pixels tall
	always @(posedge clock)
		if (reset) VState <= 0;
		else if (last_horiz_position & last_vertical_position & VideoValid) VState <= 0;
		else if (last_horiz_position & (&vertical_pixel_count[4:0]) & VideoValid) VState <= ~VState;

	always @(*)
		if (~HState & ~VState) OrigVideo = Q1_color;
		else if (HState & ~VState) OrigVideo = Q2_color;
		else if (~HState & VState) OrigVideo = Q3_color;
		else OrigVideo = Q4_color;

	assign Video = invert ? OrigVideo : ~OrigVideo;

endmodule
