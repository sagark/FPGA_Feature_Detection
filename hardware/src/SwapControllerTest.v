// Module: SwapControllerTest
// Desc: SwapController Testbench
`timescale 1ns / 1ps


module SwapControllerTest();
    // Clock generation

endmodule
/*
    parameter Halfcycle = 1; // half period is 1 nanosecond
    localparam Cycle = 2*Halfcycle;
    reg Clock;
    initial Clock = 0;
    always #(Halfcycle) Clock = ~Clock;

    // dut test wires
    wire swap, bg_start, ol_start, bg_done, ol_done;
    reg rst, swap_ack, bg_start_ack, ol_start_ack, bg_done_ack, ol_done_ack;



    // prep dut for first run
    task initGenerator;
        begin
            rst = 1;
            swap_ack = 0;
            bg_start_ack = 0;
            ol_start_ack = 0;
            bg_done_ack = 0;
            ol_done_ack = 0;
            #2 // wait a cycle
            rst = 0;
        end
    endtask

    // test exp output / real output, report err
    task checkOutput;
        begin
            //if (ExpVidSignalIn !== video) begin
            $display("test: swap: %d, bg_start: %d, ol_start: %d, bg_done: %d, ol_done: %d", swap, bg_start, ol_start, bg_done, ol_done)
            //    $finish();
            //end
        end
    endtask

    // device under test
    SwapController dut(
        .reset(rst), 
        .clock(Clock),
        .swap(swap),
        .swap_ack(swap_ack),
        .bg_start(bg_start),
        .bg_start_ack(bg_start_ack),
        .ol_start(ol_start),
        .ol_start_ack(ol_start_ack),
        .bg_done(bg_done),
        .bg_done_ack(bg_done_ack),
        .ol_done(ol_done),
        .ol_done_ack(ol_done_ack)
    );


    initial begin 
        initGenerator();
        begin: testerWrap
            #2
            initGenerator();

            checkOutput();

            #1



            $finish(); // stop running, all tests pass
        end
    end
endmodule

*/
