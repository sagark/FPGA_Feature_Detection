module FPGA_TOP_ML505(
  input   USER_CLK,

  input   GPIO_SW_C,
  
  input   [7:0] GPIO_DIP,

  output [7:0] GPIO_LED,

  // DVI Controller
  output [11:0] DVI_D,
  output        DVI_DE,
  output        DVI_H,
  output        DVI_RESET_B,
  output        DVI_V,
  output        DVI_XCLK_N,
  output        DVI_XCLK_P,
  inout         IIC_SCL_VIDEO,
  inout         IIC_SDA_VIDEO,
  
  // ZBT SRAM Controller
  input   SRAM_CLK_FB,
  output  SRAM_CLK,
  output  SRAM_WE_B,
  output  SRAM_CS_B,
  output  SRAM_ADV_LD_B,
  output  SRAM_MODE,
  output  SRAM_OE_B,
  output  [3:0] SRAM_BW,
  output [17:0] SRAM_A,
  inout  [31:0] SRAM_D);

  //--|Parameters|--------------------------------------------------------------

  parameter   UserClockFreq = 100000000;  // 100 MHz
  parameter   DVIClockFreq  =  50000000;  // 50 MHz

  `ifdef MODELSIM
    initial $display("ModelSim Flag set at FGPA_TOP_ML505");
  `endif
  //--|Clock| -----------------------------------------------------------------

  `ifdef MODELSIM
    reg clk_100M_g;
    initial clk_100M_g = 0;
    always #5 clk_100M_g = ~clk_100M_g;
  `else
    wire clk_100M_g;
    IBUFG clk_buf_user  (.I(USER_CLK),.O(clk_100M_g));
  `endif // MODELSIM
  
  wire clk_50M_pre, clk_50M;
  wire clk_200M_pre, clk_200M;
  wire clk_10M_pre, clk_10M;
  wire pll_fb, pll_lock;

  PLL_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKFBOUT_MULT(24),
    .CLKFBOUT_PHASE(0.0),
    .CLKIN_PERIOD(10.0),
    .COMPENSATION("SYSTEM_SYNCHRONOUS"),
    .DIVCLK_DIVIDE(4),
    .REF_JITTER(0.100),

    .CLKOUT0_DIVIDE(12),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0.0),
    
    .CLKOUT1_DIVIDE(3),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT1_PHASE(0.0),
    
    .CLKOUT2_DIVIDE(60),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT2_PHASE(0.0))
  clk_pll (
    .RST(1'b0),
    .CLKIN(clk_100M_g),
    .CLKFBOUT(pll_fb),
    .CLKFBIN(pll_fb),
    .LOCKED(pll_lock),
    .CLKOUT0(clk_50M_pre),
    .CLKOUT1(clk_200M_pre),
    .CLKOUT2(clk_10M_pre));

  // Global buffers for output clocks
  BUFG  clk_buf_50M   (.I(clk_50M_pre),.O(clk_50M));
  BUFG  clk_buf_200M  (.I(clk_200M_pre),.O(clk_200M));
  BUFG  clk_buf_10M  (.I(clk_10M_pre),.O(clk_10M));

  // -- |Reset| ---------------------------------------------------------------
  
  
  `ifdef MODELSIM
    reg reset_in;
    initial begin
      reset_in = 1'b1;
      #1000 reset_in = 1'b0;
    end
  `else
    wire reset_in;
    Debouncer #(
      .Width(20))
    reset_debounce(
      .Clock(clk_10M),
      .Reset(1'b0),
      .Enable(1'b1),
      .In(GPIO_SW_C),
      .Out(reset_in));
  `endif // MODELSIM 

  wire reset;
  assign reset = reset_in | ~pll_lock;
  
  // -- |Swap Controller| ------------------------------------------------------
  
  wire dvi_swap, dvi_swap_ack;
  wire bg_start, bg_start_ack;
  wire bg_done, bg_done_ack;
  wire ol_start, ol_start_ack;
  wire ol_done, ol_done_ack;

  SwapController sc(
    .clock(clk_10M),
    .reset(reset),
    .swap(dvi_swap),
    .swap_ack(dvi_swap_ack),
    .bg_start(bg_start),
    .bg_start_ack(bg_start_ack),
    .bg_done(bg_done),
    .bg_done_ack(bg_done_ack),
    .ol_start(ol_start),
    .ol_start_ack(ol_start_ack),
    .ol_done(ol_done),
    .ol_done_ack(ol_done_ack));

  // -- |Image Buffer Writer| --------------------------------------------------
  `define IMAGE_WRITER_ENABLE
  
  `ifdef IMAGE_WRITER_ENABLE
    localparam N_PIXEL = 480000;

    wire bg_clock;
    assign bg_clock = clk_10M;

    wire [53:0] bg_dout;
    wire bg_valid,bg_ready;

    ImageBufferWriter #(
      .N_PIXEL(N_PIXEL))
    ibw (
      .clock(bg_clock),
      .reset(reset),
      .scroll(GPIO_DIP[0]),
      .start(bg_start),
      .start_ack(bg_start_ack),
      .done(bg_done),
      .done_ack(bg_done_ack),
      .dout(bg_dout),
      .valid(bg_valid),
      .ready(bg_ready));

  `endif // IMAGE_WRITER_ENABLE

  // -- |Overlay| --------------------------------------------------
  `define OVERLAY_ENABLE
  
  `ifdef OVERLAY_ENABLE
    localparam N_PIXEL_2 = 480000;

    wire ol_clock;
    assign ol_clock = clk_10M;

    wire [53:0] ol_dout;
    wire ol_valid,ol_ready;

    Overlay #(
      .N_PIXEL(N_PIXEL_2))
    over (
      .clock(ol_clock),
      .reset(reset),
      .scroll(GPIO_DIP[0]),
      .start(ol_start),
      .start_ack(ol_start_ack),
      .done(ol_done),
      .done_ack(ol_done_ack),
      .dout(ol_dout),
      .valid(ol_valid),
      .ready(ol_ready));

  `endif // OVERLAY_ENABLE

  // -- |Image Buffer Reader| --------------------------------------------------
  `define IMAGE_READER_ENABLE

  `ifdef IMAGE_READER_ENABLE
    wire dvi_clock;
    assign dvi_clock = clk_50M;

    wire [23:0] dvi_video;
    wire dvi_video_valid, dvi_video_ready;

    wire [17:0] dvi_addr;
    wire dvi_addr_valid, dvi_addr_ready;

    wire [31:0] dvi_data;
    wire dvi_data_valid, dvi_data_ready;

    ImageBufferReader #(
      .N_PIXEL(N_PIXEL))
    ibr (
      .clock(dvi_clock),
      .reset(reset),
      .swap(dvi_swap),
      .swap_ack(dvi_swap_ack),

      .video(dvi_video),
      .video_valid(dvi_video_valid),
      .video_ready(dvi_video_ready),

      .addr_valid(dvi_addr_valid),
      .addr(dvi_addr),
      .addr_ready(dvi_addr_ready),
      .data_ready(dvi_data_ready),
      .data(dvi_data),
      .data_valid(dvi_data_valid));
  `endif
  
  // -- |SRAM Arbiter| ---------------------------------------------------------
  `define SRAM_ARBITER_ENABLE

  `ifdef SRAM_ARBITER_ENABLE

    // SRAM controller wires
    wire sram_clock;
    assign sram_clock = clk_50M;

    wire sram_addr_valid,sram_ready,sram_data_out_valid;
    wire [17:0] sram_addr;
    wire [31:0] sram_data_in,sram_data_out;
    wire [3:0] sram_write_mask;

    SramArbiter sram_arbiter(
      // Application interface
      .reset(reset),

      // W0: Image Buffer Writer
      .w0_clock(bg_clock),
      .w0_din_ready(bg_ready),
      .w0_din_valid(bg_valid),
      .w0_din(bg_dout),// {mask,addr,data}

      // W1: Overlay Writer
      .w1_clock(1'b0),
      .w1_din_ready(),
      .w1_din_valid(),
      .w1_din(),// {mask,addr,data}

      // R0: Image Buffer Reader
      .r0_clock(dvi_clock),
      .r0_din_ready(dvi_addr_ready),
      .r0_din_valid(dvi_addr_valid),
      .r0_din(dvi_addr), // addr
      .r0_dout_ready(dvi_data_ready),
      .r0_dout_valid(dvi_data_valid),
      .r0_dout(dvi_data), // data

      // R1
      .r1_clock(1'b0),
      .r1_din_ready(),
      .r1_din_valid(),
      .r1_din(), // addr
      .r1_dout_ready(),
      .r1_dout_valid(),
      .r1_dout(), // data

      // SRAM Interface
      .sram_clock(sram_clock),
      .sram_addr_valid(sram_addr_valid),
      .sram_ready(sram_ready),
      .sram_addr(sram_addr),
      .sram_data_in(sram_data_in),
      .sram_write_mask(sram_write_mask),
      .sram_data_out(sram_data_out),
      .sram_data_out_valid(sram_data_out_valid));
  `endif // SRAM_ARBITER_ENABLE
  
  // -- [DVI Controller] ----------------------------------------------------
  `define DVI_ENABLE
  
  `ifdef DVI_ENABLE
   wire [23:0] video;
   wire video_ready,video_valid; 

    // REMOVE THESE WHEN TEST PATTERN GENERATOR IS DONE

    //assign video = {8'h0, 8'h0, 8'hFF};
    //assign video_valid = 1'b1;

    PatternGenerator pg(.reset(Reset), .clock(clk_50M), .VideoReady(video_ready), .VideoValid(video_valid), .Video(video));

    DVI #(
      .ClockFreq(                 DVIClockFreq),
      .Width(                     1040),
      .FrontH(                    56),
      .PulseH(                    120),
      .BackH(                     64),
      .Height(                    666),
      .FrontV(                    37),
      .PulseV(                    6),
      .BackV(                     23))
    dvi (
     .Clock(                     dvi_clock),
     .Reset(                     reset),
     .DVI_D(                     DVI_D),
     .DVI_DE(                    DVI_DE),
     .DVI_H(                     DVI_H),
     .DVI_V(                     DVI_V),
     .DVI_RESET_B(               DVI_RESET_B),
     .DVI_XCLK_N(                DVI_XCLK_N),
     .DVI_XCLK_P(                DVI_XCLK_P),
     .I2C_SCL_DVI(               IIC_SCL_VIDEO),
     .I2C_SDA_DVI(               IIC_SDA_VIDEO),
     /* Ready/Valid interface for 24-bit pixel values */
     .Video(dvi_video),
     .VideoReady(dvi_video_ready),
     .VideoValid(dvi_video_valid));
  `else
    assign DVI_D = 0;
    assign DVI_DE = 0;
    assign DVI_H = 0;
    assign DVI_V = 0;
    assign DVI_RESET_B = 1;
    assign DVI_XCLK_N = 0;
    assign DVI_XCLK_P = 0;
    assign IIC_SCL_VIDEO = 1;
    assign IIC_SDA_VIDEO = 1;
  `endif // DVI_ENABLE
  
  // -- |SRAM Controller| ------------------------------------------------------
  `define SRAM_ENABLE 
  
  `ifdef SRAM_ENABLE
    SRAM sram(
      .clock(sram_clock),
      .reset(reset),
      .addr_valid(sram_addr_valid),
      .ready(sram_ready),
      .addr(sram_addr),
      .data_in(sram_data_in),
      .write_mask(sram_write_mask),
      .data_out(sram_data_out),
      .data_out_valid(sram_data_out_valid),
      
      .sram_clk_fb(SRAM_CLK_FB),
      .sram_clk(SRAM_CLK),
      .sram_cs_l(SRAM_CS_B),
      .sram_we_l(SRAM_WE_B),
      .sram_mode(SRAM_MODE),
      .sram_adv_ld_l(SRAM_ADV_LD_B),
      .sram_oe_l(SRAM_OE_B),
      .sram_data(SRAM_D),
      .sram_addr(SRAM_A),
      .sram_bw_l(SRAM_BW));
  `else
    assign SRAM_CLK=0;
    assign SRAM_WE_B=1;
    assign SRAM_CS_B=1;
    assign SRAM_ADV_LD_B=1;
    assign SRAM_MODE=0;
    assign SRAM_OE_B=1;
    assign SRAM_BW=4'hF;
    assign SRAM_A=0;
    assign SRAM_D=32'dz;
  `endif // SRAM_ENABLE

  assign GPIO_LED = {~reset, GPIO_SW_C, pll_lock, 5'b0};
endmodule
