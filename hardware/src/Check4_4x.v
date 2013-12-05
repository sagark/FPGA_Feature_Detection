module Check4_4x (
    input clock1,
    input clock2,
    input clock3,
    input reset,
    
    input [7:0] din,
    input valid,

    input [4:0] selector,

    output [9:0] rowcount,
    output [9:0] colcount,


    output [7:0] dout,
    output validout
);

wire [7:0] down_to_five_data;
wire down_to_five_blank;
wire down_to_five_valid;

reg [7:0] five_to_up_data;
wire five_to_up_blank;
reg five_to_up_valid;

wire [7:0] g0_dout;
wire g0_valid;

wire [7:0] g1_dout;
wire g1_valid;

wire [7:0] g2_dout;
wire g2_valid;

wire [7:0] g3_dout;
wire g3_valid;

wire [7:0] g4_dout;
wire g4_valid;

wire [7:0] d0_dout;
wire d0_valid;

wire [7:0] d1_dout;
wire d1_valid;

wire [7:0] d2_dout;
wire d2_valid;

wire [7:0] d3_dout;
wire d3_valid;

Downsampler4xWrap down(
    .clock1(clock1),
    .clock2(clock2),
    .reset(reset),

    .valid(valid),
    .data(din),

    .dataout(down_to_five_data),
    .blankingregion(down_to_five_blank), 
    .validout(down_to_five_valid)
);

octave #(
    .width(210)
) oct(
    .reset(reset),
    .clock(clock2),
    .din(down_to_five_data),
    .blanking_in(down_to_five_blank),
    .validin(down_to_five_valid),

    .g0_dout(g0_dout),
    .g0_valid(g0_valid),

    .g1_dout(g1_dout),
    .g1_valid(g1_valid),

    .g2_dout(g2_dout),
    .g2_valid(g2_valid),

    .g3_dout(g3_dout),
    .g3_valid(g3_valid),

    .g4_dout(g4_dout),
    .g4_valid(g4_valid),

    .d0_dout(d0_dout),
    .d0_valid(d0_valid),

    .d1_dout(d1_dout),
    .d1_valid(d1_valid),

    .d2_dout(d2_dout),
    .d2_valid(d2_valid),

    .d3_dout(d3_dout),
    .d3_valid(d3_valid)  
);

Upsampler4xWrap up(
    .clock1(clock2),
    .clock2(clock3),
    .reset(reset),

    .din(five_to_up_data),
    .valid(five_to_up_valid),

    .dataout(dout),
    .validout(validout)
);

// select input
always@* begin
    if (selector == 0) begin
        five_to_up_valid = g0_valid;
        five_to_up_data = g0_dout;
    end else if (selector == 1) begin
        five_to_up_valid = g1_valid;
        five_to_up_data = g1_dout;
    end else if (selector == 2) begin
        five_to_up_valid = g2_valid;
        five_to_up_data = g2_dout;
    end else if (selector == 3) begin
        five_to_up_valid = g3_valid;
        five_to_up_data = g3_dout;
    end else if (selector == 4) begin
        five_to_up_valid = g4_valid;
        five_to_up_data = g4_dout;
    end else if (selector == 5) begin
        five_to_up_valid = d0_valid;
        five_to_up_data = d0_dout;
    end else if (selector == 6) begin
        five_to_up_valid = d1_valid;
        five_to_up_data = d1_dout;
    end else if (selector == 7) begin
        five_to_up_valid = d2_valid;
        five_to_up_data = d2_dout;
    end else if (selector == 8) begin
        five_to_up_valid = d3_valid;
        five_to_up_data = d3_dout;
    end else begin
        five_to_up_valid = 0;
        five_to_up_data = 0;
    end
end

endmodule
