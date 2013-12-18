//==============================================================================
//  File:   StaticImage.v
//  Author: Austin Buchan (abuchan@eecs.berkeley.edu)
//  Copyright:  Copyright 2005-2014 UC Berkeley
//  Version: Updated for UC Berkeley CS150 Fall 2013 Course
//==============================================================================

//==============================================================================
//  Section:  License
//==============================================================================
//  Copyright (c) 2005-2014, Regents of the University of California
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//    - Redistributions of source code must retain the above copyright notice,
//      this list of conditions and the following disclaimer.
//    - Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer
//      in the documentation and/or other materials provided with the
//      distribution.
//    - Neither the name of the University of California, Berkeley nor the
//      names of its contributors may be used to endorse or promote
//      products derived from this software without specific prior
//      written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
//  POSSIBILITY OF SUCH DAMAGE.
//
//==============================================================================

//------------------------------------------------------------------------------
//  Module: StaticImage
//
//  Desc: Stream frame information using static source image in Block RAM.
//    Produces black border if image is smaller than 800x600 frame.
//
//  Params: -IMG_WIDTH: source image width in pixels
//          -IMG_HEIGHT: source image height in pixels
//------------------------------------------------------------------------------

module StaticImage #(
  parameter IMG_WIDTH = 200,
  parameter IMG_HEIGHT = 150)
(
  input clock,
  input reset,

  input start,
  output reg start_ack,

  input ready,
  output valid,
  output [7:0] pixel);

localparam  OUT_WIDTH = 800,
            OUT_HEIGHT = 600;

localparam  IMG_N_PIXEL = IMG_WIDTH * IMG_HEIGHT,
            IMG_X_START = (OUT_WIDTH-IMG_WIDTH)/2,
            IMG_Y_START = (OUT_HEIGHT-IMG_HEIGHT)/2;

wire [7:0] pixel_data;
reg [9:0] img_row, img_col;
reg [14:0] img_pxl;
wire row_active, col_active, pxl_active;

assign col_active = (img_col > (IMG_X_START-1)) & 
        (img_col < (IMG_X_START+IMG_WIDTH));
assign row_active = (img_row > (IMG_Y_START-1)) & 
        (img_row < (IMG_Y_START+IMG_HEIGHT));
assign pxl_active = row_active & col_active;

IMG_MEM img_mem(
  .clka(clock),
  .addra(img_pxl),
  .douta(pixel_data));

assign pixel = pxl_active ? pixel_data : 8'd0;
assign valid = (img_row < OUT_HEIGHT);

wire start_edge;
reg start_ack_r;
assign start_edge = start_ack_r & ~start_ack;

always @(posedge clock) begin
  if(reset) begin
    img_row <= OUT_HEIGHT;
    img_col <= OUT_WIDTH;
    img_pxl <= 15'd0;
    start_ack <= 1'b0;
    start_ack_r <= 1'b0;
  end else begin
    start_ack <= start;
    start_ack_r <= start_ack;

    if (start_edge) begin
      img_row <= 10'd0;
      img_col <= 10'd0;
    end else if (valid & ready) begin
      if (img_col == (OUT_WIDTH-1)) begin
        img_col <= 10'd0;
        img_row <= img_row + 10'd1;
      end else
        img_col <= img_col + 10'd1;
    end

    if (start_edge)
      img_pxl <= 15'd0;
    else if (pxl_active)
      img_pxl <= img_pxl + 15'd1;
  end
end

endmodule
