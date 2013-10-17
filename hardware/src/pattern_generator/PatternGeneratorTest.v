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


    task checkOutput;
        input [23:0] ExpVidSignalIn;
        begin : tester
            integer c;
            rst = 1;
            vidRed = 0;
            #2

            rst = 0;
            vidRed = 1;

            for (c = 0; c < 800*600*72-100; c = c + 1) begin
                #2 // give it 10ns to start generating output
                //$display("Expected: 0x%h, Got: 0x%h, VidValid: 0x%h, PixelNum: %d", ExpVidSignalIn, video, videoValid, c);
                ;
            end              

            for (c = 800*600*72-100; c < 800*600*72+10; c = c + 1) begin
                #2 // give it 10ns to start generating output
                $display("Expected: 0x%h, Got: 0x%h, VidValid: 0x%h, PixelNum: %d", ExpVidSignalIn, video, videoValid, c);
            end
            $finish();
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
        checkOutput(0);

    end
endmodule


