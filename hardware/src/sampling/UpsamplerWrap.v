module UpsamplerWrap(
    input clock1,
    input clock2,
    input reset,

    input [7:0] din,
    input valid,

    output [9:0] rownum,
    output [9:0] colnum,


    output [7:0] dataout,
    output validout
);

wire validconnect;
wire [7:0] dout;
wire rd_en;

up_fifo fif1(
  .rst(reset),
  .wr_clk(clock1),
  .rd_clk(clock2),
  .din(din),
  .wr_en(valid),
  .rd_en(rd_en),
  .dout(dout),
  .valid(validconnect)
);


Upsampler2 up(
    .clock(clock2),
    .reset(reset),
    
    .valid(validconnect),
    .data(dout),

    .current_rowcount(rownum),
    .current_colcount(colnum),

    .fifo_read(rd_en),
    .dataout(dataout),
    .validout(validout)
);
endmodule
