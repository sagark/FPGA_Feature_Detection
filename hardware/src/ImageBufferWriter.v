//==============================================================================
//  File:   ImageBufferWriter.v
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
//  Module: ImageBufferWriter
//
//  Desc: Accepts streaming video information via vga interface, or produces
//    horizontal gradient test pattern with optional scrolling animation. This
//    data is packed into 4-byte chunks for submission to SRAM frame buffer.
//
//  Params: -N_PIXEl: number of pixels in frame
//------------------------------------------------------------------------------

module ImageBufferWriter #(
  parameter N_PIXEL = 480000)
(
  input clock,
  input reset,

  // Source and behavior control
  input scroll,
  input vga_enable,

  input start,
  output reg start_ack,

  output reg done,
  input done_ack,
  
  // SRAM interface
  output [53:0] dout,
  output valid,
  input ready,
  
  // Video source interface
  output  reg vga_start,
  input   vga_start_ack,
  input [7:0] vga_video,
  input   vga_video_valid);


reg vga_enable_r;
reg [1:0] pixel_idx;
reg [23:0] pixel_store;
wire [31:0] vga_pixel_data;
wire vga_pixel_data_valid;

assign vga_pixel_data = {vga_video, pixel_store};
assign vga_pixel_data_valid = (pixel_idx == 2'd3);

wire start_edge;

always @(posedge clock) begin
  if (reset) begin
    vga_enable_r <= 1'b0;
    pixel_idx <= 2'd0;
    vga_start <= 1'b0;
  end else begin
    if(start_edge)
      vga_enable_r <= vga_enable;
    
    if (vga_start & vga_start_ack)
      vga_start <= 1'b0;
    else if (start_edge)
      vga_start <= 1'b1;

    if(start_edge)
      pixel_idx <= 3'd0;
    else if (vga_video_valid)
      pixel_idx <= pixel_idx + 1;

    case (pixel_idx)
      2'd0: pixel_store[7:0]    <= vga_video;
      2'd1: pixel_store[15:8]   <= vga_video;
      2'd2: pixel_store[23:16]  <= vga_video; 
    endcase
  end
end

localparam MAX_ADDR = (N_PIXEL/4)-1;

reg frame;
reg [16:0] addr;
reg [7:0] video;
reg [9:0] row;

// Generate Horizontal gradient of pixels
reg [7:0] count;
wire [31:0] pixel;
assign pixel = {count + {video[5:0], 2'd3},
                count + {video[5:0], 2'd2},
                count + {video[5:0], 2'd1},
                count + {video[5:0], 2'd0}};

// Concatenate mask, frame, addr, and pixel data
assign dout = {4'hF, frame, addr, vga_enable_r ? vga_pixel_data : pixel};

assign valid = vga_enable_r ? vga_pixel_data_valid : addr <= MAX_ADDR;

reg start_ack_r;

// Have a signal for when the output is incremented
wire inc;
assign inc = valid & ready;

// Simple edge dector on start condition
assign start_edge = start_ack & ~start_ack_r;

always @(posedge clock) begin
  if(reset) begin
    addr <= MAX_ADDR+1;
    frame <= 1'b1;
    done <= 1'b0;
    start_ack <= 1'b0;
    start_ack_r <= 1'b0;
    video <= 8'd0;
    count <= 8'd0;
  end else begin
    if (done & done_ack)
      done <= 1'b0;
    else if ((addr == MAX_ADDR) & ready) begin
      done <= 1'b1;

      // Since addr will be incremented, we avoid switching frames 
      // twice
      frame <= ~frame;

      // If selected, produce dynamic horizontal scrolling output
      if(scroll)
        count <= count + 1;
      else
        count <= 8'd0;
    end

    // Synchronize start
    start_ack <= start;
    start_ack_r <= start_ack;

    // Use edge signal so we don't submit multiple at the same addr
    if (start_edge) begin
      video <= 8'd0;
      addr <= 17'd0;
      row <= 8'd0;
    end else if (inc) begin
      addr <= addr + 17'd1;
      if (video == 8'd199) begin
        video <= 8'd0;
        row <= row + 10'd1;
      end else
        video <= video + 1;
    end
  end
end

endmodule
