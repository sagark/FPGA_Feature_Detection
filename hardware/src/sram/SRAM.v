//==============================================================================
//  File:   SRAM.v
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
//  Module: SRAM
//
//  Desc: Interfaces with IS61NLP25636A ZBT SRAM. Buffers information to
//    compensate for delay between address submit and data ready.
//
//  Params: None
//------------------------------------------------------------------------------

module SRAM (
  // Application interface
  input clock,
  input reset,

  input   addr_valid,
  output  ready,
  input      [17:0] addr,
  input      [31:0] data_in,
  input       [3:0] write_mask,
  output reg [31:0] data_out,
  output reg        data_out_valid,

  // Physical Interface
  input       sram_clk_fb,
  output      sram_clk,
  output      sram_cs_l,
  output      sram_we_l,
  output      sram_mode,
  output      sram_adv_ld_l,
  output      sram_oe_l,
  inout      [31:0] sram_data,
  output reg [17:0] sram_addr,
  output reg  [3:0] sram_bw_l);

  // Shift registers (number of "r"s indicates delay
  reg [31:0] data_in_r,data_in_rr,data_in_rrr;
  reg valid_r,valid_rr,valid_rrr;
  reg read_rr, read_rrr;
  
  assign sram_clk = clock;

  assign sram_cs_l = 0; // Always enable SRAM
  assign sram_mode = 0; // Mode is unused since we don't do burst reads
  assign sram_adv_ld_l = 0; // Advance/Load always asserted to output data
  assign sram_oe_l = 0; // Output enable always on, chip figures out drive
  assign ready = 1; // Always ready

  assign sram_we_l = &sram_bw_l; // Write if any bits asserted in mask

  // SRAM data is bidirectional, don't drive on write operation
  assign sram_data = read_rrr ? 32'dz : data_in_rrr;

  always @(posedge clock) begin
    if (reset) begin
      valid_r <= 0;
      valid_rr <= 0;
      valid_rrr <= 0;
      data_out_valid <= 0;
    end else begin
      // Register inputs and outputs to avoid combinational stackup
      data_out <= sram_data;
      sram_addr <= addr;
      sram_bw_l <= addr_valid ? ~write_mask : 4'hF;
      
      // Assign shift register levels
      {valid_r, data_in_r} <= {addr_valid,data_in};
      {valid_rr, read_rr, data_in_rr} <= {valid_r,sram_we_l,data_in_r};
      {valid_rrr, read_rrr, data_in_rrr} <= {valid_rr,read_rr,data_in_rr};
      data_out_valid <= valid_rrr & read_rrr;
    end
  end
endmodule
