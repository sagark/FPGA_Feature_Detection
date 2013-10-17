// Module: PatternGeneratorTest
// Desc: Testbench for DVI Pattern Generator
`timescale 1ns / 1ps


module PatternGeneratorTest();
    // Clock generation
    parameter Halfcycle = 1; // half period is 5 nanoseconds
    localparam Cycle = 2*Halfcycle;
    reg Clock;
    initial Clock = 0;
    always #(Halfcycle) Clock = ~Clock;

    // dut test wires
    reg rst;
    reg vidRed;
    wire [23:0] video;
    wire videoValid;

    // prep dut for first run
    task initGenerator;
        begin
            rst = 1;
            vidRed = 0;
            #2
            rst = 0;
            vidRed = 1;
        end
    endtask

    // test exp output / real output, report err
    task checkOutput;
        input [23:0] ExpVidSignalIn;
        input [32:0] countInput;
        begin
            #2 // give it 10ns to start generating output
            if (ExpVidSignalIn !== video) begin
                $display("FAILURE: Expected: 0x%h, Got: 0x%h, VidValid: 0x%h, PixelNum: %d", 
                                     ExpVidSignalIn, video, videoValid, countInput);
                $finish();
            end
        end
    endtask

    // device under test
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
            integer y1, y2;
            integer f, numFrames;
            integer c1, c2, c3, c4;
            numFrames = 100; // test 72 inverted frames and the first non-inverted frame

            c1 = 24'h00CC00;
            c2 = 24'h00CCCC;
            c3 = 24'hFF9A26;
            c4 = 24'h9D26FF;
 
            for (f = 0; f < numFrames; f = f + 1) begin // loop over frame

                if (f % 72 === 0) begin // invert testing colors every 72 frames
                    c1 = ~c1;
                    c2 = ~c2;
                    c3 = ~c3;
                    c4 = ~c4;
                end

                // start loop that generates full frame
                for (y = 0; y < 600; y = y + 64) begin // move vertically
                    for (y1 = 0; (y1 < 32) && (y+y1 < 600); y1 = y1 + 1) begin // alternate between row 1
                        for (x = 0; x < 800; x = x + 128) begin // move horizontally
                            for (x1 = 0; (x1 < 64) && (x+x1 < 800); x1 = x1 + 1) begin // alternate between Q1
                                checkOutput(c1, (y+y1)*800+x+x1);
                            end
                            for (x1 = 64; (x1 < 128) && (x+x1 < 800); x1 = x1 + 1) begin // and Q2
                                checkOutput(c2, (y+y1)*800+x+x1); 
                            end
                        end
                    end
                    for (y1 = 32; (y1 < 64) && (y+y1 < 600); y1 = y1 + 1) begin // alternate between row 1
                        for (x = 0; x < 800; x = x + 128) begin // move horizontally
                            for (x1 = 0; (x1 < 64) && (x+x1 < 800); x1 = x1 + 1) begin // alternate between Q1
                                checkOutput(c3, (y+y1)*800+x+x1);
                            end
                            for (x1 = 64; (x1 < 128) && (x+x1 < 800); x1 = x1 + 1) begin // and Q2
                                checkOutput(c4, (y+y1)*800+x+x1); 
                            end
                        end
                    end
                end // end loop that generates full frame
                $display("done frame #%d", f);

                $display("now testing video_ready on/off");
                vidRed = 0;
                #10 // simulate DVI pausing for 5 clock cycles
                vidRed = 1;

            end
            $display("ALL TESTS PASS. SUCCESSFULLY GENERATED %d FRAMES.", numFrames);
            $finish(); // stop running, all tests pass
        end
    end
endmodule


