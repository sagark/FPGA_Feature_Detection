// Module: PatternGeneratorTest
// Desc: Testbench for DVI Pattern Generator
`timescale 1ns / 1ps


module Check4Test();
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
                if (validout) begin
                $display("dataout: %h, validout: %b", 
                                     dataout, validout);
                end
                //$finish();
        end
    endtask

//device under test
Check4 dut(
    .clock1(Clock),
    .clock2(Clock),
    .clock3(Clock),
    .reset(rst),
    
    .din(datain),
    .valid(validin),

    .dout(dataout),
    .validout(validout)
);



    initial begin 
        initGenerator();
        #2
        rst = 0;
        begin: testerWrap
            integer x, y, z;
            for (z = 0; z < 2; z = z + 1) begin
                for (y = 0; y < 600; y = y + 1) begin // loop over frame
                    for (x = 0; x < 800; x = x + 1) begin
                        datain = 400;
                        validin = 1;
                        checkOutput();
                        #2;
                    end
                    for (x = 0; x < 100; x = x + 1) begin
                        datain = 400;
                        validin = 0;
                        checkOutput();
                        #2;
                    end

                end
                for (y = 0; y < 100; y = y + 1) begin 
                    for (x = 0; x < 900; x = x + 1) begin
                        datain = 400;
                        validin = 0;
                        checkOutput();
                        #2;
                    end
                end
                $display("DONE FRAME %d", z);
            end
            //$display("ALL TESTS PASS. SUCCESSFULLY GENERATED %d FRAMES.", numFrames);
            $finish(); // stop running, all tests pass
        end
    end
endmodule


