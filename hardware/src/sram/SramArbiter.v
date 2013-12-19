//==============================================================================
//  File:   SramArbiter.v
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
//  Module: SramArbiter
//
//  Desc: Skeleton for a 2-Read 2-Write port round-robin arbiter.
//
//  Params: None
//------------------------------------------------------------------------------


module SramArbiter(
  // Application interface
  input reset,

  // W0
  input         w0_clock,
  output        w0_din_ready,
  input         w0_din_valid,
  input [53:0]  w0_din,// {mask,addr,data}

  // W1
  input         w1_clock,
  output        w1_din_ready,
  input         w1_din_valid,
  input [53:0]  w1_din,// {mask,addr,data}

  // R0
  input         r0_clock,
  output        r0_din_ready,
  input         r0_din_valid,
  input  [17:0] r0_din, // addr
  input         r0_dout_ready,
  output        r0_dout_valid,
  output [31:0] r0_dout, // data

  // R1
  input         r1_clock,
  output        r1_din_ready,
  input         r1_din_valid,
  input  [17:0] r1_din, // addr
  input         r1_dout_ready,
  output        r1_dout_valid,
  output [31:0] r1_dout, // data

  // SRAM Interface
  input         sram_clock,
  output        sram_addr_valid,
  input         sram_ready,
  output [17:0] sram_addr,
  output [31:0] sram_data_in,
  output  [3:0] sram_write_mask,
  input  [31:0] sram_data_out,
  input         sram_data_out_valid);

// Clock crossing FIFOs --------------------------------------------------------

// The SRAM_WRITE_FIFOis have been instantiated for you, but you must wire it
// correctly

SRAM_WRITE_FIFO w0_fifo(
  .rst(),
  .wr_clk(),
  .din(),
  .wr_en(),
  .full(),

  .rd_clk(),
  .rd_en(),
  .valid(),
  .dout(),
  .empty());

SRAM_WRITE_FIFO w1_fifo(
  .rst(),
  .wr_clk(),
  .din(),
  .wr_en(),
  .full(),

  .rd_clk(),
  .rd_en(),
  .valid(),
  .dout(),
  .empty());

// Instantiate the Read FIFOs here

// Arbiter Logic ---------------------------------------------------------------

// Put your round-robin arbitration logic here

endmodule
