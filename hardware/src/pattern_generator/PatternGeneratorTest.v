// Module: PatternGeneratorTest
// Desc: Testbench for DVI Pattern Generator
`timescale 1ns / 1ps


module PatternGeneratorTest();


    parameter Halfcycle = 1; // half period is 5 nanoseconds

    localparam Cycle = 2*Halfcycle;

    reg Clock;

    // Clock generation
    initial Clock = 0;
    always #(Halfcycle) Clock = ~Clock;


    // dut test wires
    reg rst;
    reg vidRed;
    wire [23:0] video;
    wire videoValid;

    task initGenerator;
        begin
            rst = 1;
            vidRed = 0;
            #2
            rst = 0;
            vidRed = 1;
        end
    endtask

    task checkOutput;
        input [23:0] ExpVidSignalIn;
        input [32:0] countInput;
        begin
            #2 // give it 10ns to start generating output
            $display("Expected: 0x%h, Got: 0x%h, VidValid: 0x%h, PixelNum: %d", ExpVidSignalIn, video, videoValid, countInput);
            //$finish();
        end
    endtask


    PatternGenerator dut(
        .reset(rst), 
        .clock(Clock),
        .VideoReady(vidRed),
        .VideoValid(videoValid),
        .Video(video)
    );


    initial begin 
        initGenerator();

        begin: testerWrap
            integer x, y;
            integer x1, x2;
            for (y = 0; y < 1; y = y + 1) begin // move vertically
                for (x = 0; x < 800; x = x + 128) begin // move horizontally
                    for (x1 = 0; (x1 < 64) && (x+x1 < 800); x1 = x1 + 1) begin // alternate between Q1
                        checkOutput(24'hFF33FF, y*800+x+x1);
                    end
                    for (x1 = 64; (x1 < 128) && (x+x1 < 800); x1 = x1 + 1) begin // and Q2
                        checkOutput(24'hFF3333, y*800+x+x1); 
                    end
                end
            end

        end

    end
endmodule


