// Module: PatternGeneratorTest
// Desc: Testbench for DVI Pattern Generator
`timescale 1ns / 1ps


module UpsamplerTest();
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
    wire fifo_read;

    wire [9:0] current_rowcount;
    wire [9:0] current_colcount;
 
// plan: first test one row
// give it 420 pixels
// by doing: pixel 
// wait
// pixel 
// wait etc to simulate a fifo input

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
            //if (validout == 1'b1) begin
                $display("dataout: %h, validout: %b, fifo_read %b, current_rowcount %d, current_colcount %d", 
                                     dataout, validout, fifo_read, current_rowcount, current_colcount);
                //$finish();
            //end
        end
    endtask

    // device under test
    Upsampler dut(
        .reset(rst), 
        .clock(Clock),

        .valid(validin),
        .data(datain),

        .current_rowcount(current_rowcount),
        .current_colcount(current_colcount),

        .dataout(dataout),
        .validout(validout),
        .fifo_read(fifo_read)
    );


    initial begin 
        initGenerator();
        #2
        rst = 0;
        begin: testerWrap
            integer x, y;
            for (y = 0; y < 4; y = y + 1) begin // output will skip rows starting with odd y's
                // EACH ITERATION DOES TWO
                for (x = 0; x < 420; x = x + 1) begin
                    validin = 1;
                    datain = x+y;
                    //$display("(%d, %d)", x,  y);
                    checkOutput();
                    #2;
                    checkOutput();
                    #2;
                end
            end
            //$display("ALL TESTS PASS. SUCCESSFULLY GENERATED %d FRAMES.", numFrames);
            $finish(); // stop running, all tests pass
        end
    end
endmodule
