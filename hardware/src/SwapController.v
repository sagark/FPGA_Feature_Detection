//==============================================================================
//  File:   SwapController.v
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
//  Module: SwapController
//
//  Desc: Coordinates double-buffer frame swap between video source and DVI
//    output. Makes no assumptions about clock domains of input and output
//    modules.
//
//  Params: None
//------------------------------------------------------------------------------

module SwapController(
  input clock,
  input reset,

  output reg swap,
  input swap_ack,

  output reg bg_start,
  input bg_start_ack,

  input bg_done,
  output reg bg_done_ack);

reg bg_done_ack_r;

wire bg_done_edge;
assign bg_done_edge = bg_done_ack & ~bg_done_ack_r;

always @(posedge clock) begin
  if(reset) begin
    swap <= 1'b0;
    bg_start <= 1'b1;
    bg_done_ack <= 1'b0;
    bg_done_ack_r <= 1'b0;
  end else begin
    if(bg_start & bg_start_ack)
      bg_start <= 1'b0;
    else if(swap & swap_ack)
      bg_start <= 1'b1;

    // Synchronize ack
    bg_done_ack <= bg_done;
    bg_done_ack_r <= bg_done_ack;

    if(swap & swap_ack)
      swap <= 1'b0;
    else if (bg_done_edge)
      swap <= 1'b1;

  end
end

endmodule
