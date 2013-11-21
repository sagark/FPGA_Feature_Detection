module DownsamplerWrap(
    input clock1,
    input clock2,
    input reset,

    input valid,
    input [7:0] data,

    output [7:0] dataout,
    output blankingregion, 
    output validout
);

wire [7:0] data_to_fifo_d;
wire [8:0] data_to_fifo;
wire blanking;
wire fifo_wren;
wire [8:0] fifoout;

Downsampler down(
    .clock(clock1),
    .reset(reset),
    .valid(valid),
    .data(data),
    .dataout(data_to_fifo_d),
    .validout(fifo_wren),
    .blankingregion(blanking)
);

assign data_to_fifo = {data_to_fifo_d, blanking};

down_fifo fifo2(
  .rst(reset),
  .wr_clk(clock1),
  .rd_clk(clock2),
  .din(data_to_fifo),
  .wr_en(fifo_wren),
  .rd_en(1'b1),
  .dout(fifoout),
  .valid(validout)
);

assign blankingregion = fifoout[0];
assign dataout = fifoout[8:1];

endmodule
