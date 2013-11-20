// Module: PatternGeneratorTest
// Desc: Testbench for DVI Pattern Generator
`timescale 1ns / 1ps


module DownsamplerTest();
    // Clock generation
    parameter Halfcycle = 1; // half period is 5 nanoseconds
    localparam Cycle = 2*Halfcycle;
    reg Clock;
    initial Clock = 0;
    always #(Halfcycle) Clock = ~Clock;

    // dut test wires
    reg rst;
    reg validin;
    reg [7:0] datain;
    wire [7:0] dataout;
    wire validout;
    wire blankingregion;


    // prep dut for first run
    task initGenerator;
        begin
            rst = 1;
            validin = 0;
            datain = 0; 
        end
    endtask

    // test exp output / real output, report err
    task checkOutput;
        begin
            if (validout == 1'b1) begin
                $display("dataout: %h, validout: %b, blankingregion %b", 
                                     dataout, validout, blankingregion);
                //$finish();
            end
        end
    endtask

    // device under test
    Downsampler dut(
        .reset(rst), 
        .clock(Clock),

        .valid(validin),
        .data(datain),

        .dataout(dataout),
        .validout(validout),
        .blankingregion(blankingregion)
    );


    initial begin 
        initGenerator();
        #2
        rst = 0;
        begin: testerWrap
            integer x, y;
            for (y = 0; y < 1000; y = y + 1) begin // loop over frame
                for (x = 0; x < 1000; x = x + 1) begin
                    if (x < 800 && y < 600) validin = 1;
                    else validin = 0;
                    datain = x + y;
                    //$display("(%d, %d)", x,  y);
                    checkOutput();
                    #2;
                end
            end
            //$display("ALL TESTS PASS. SUCCESSFULLY GENERATED %d FRAMES.", numFrames);
            $finish(); // stop running, all tests pass
        end
    end
endmodule


