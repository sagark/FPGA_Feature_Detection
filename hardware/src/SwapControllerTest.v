// Module: SwapControllerTest
// Desc: SwapController Testbench
`timescale 1ns / 1ps


module SwapControllerTest();
    // Clock generation

    parameter Halfcycle = 1; // half period is 1 nanosecond
    localparam Cycle = 2*Halfcycle;
    reg Clock;
    initial Clock = 0;
    always #(Halfcycle) Clock = ~Clock;

    // dut test wires
    wire swap, bg_start, ol_start, bg_done_ack, ol_done_ack;
    reg rst, swap_ack, bg_start_ack, ol_start_ack, bg_done, ol_done;
    
    localparam N_test = 10;
    localparam inWidth = 6;
    localparam outWidth = 5;

    // Arrays loaded from input files
    // test inputs organized as:
    // { reset, swap_ack, bg_start_ack, ol_start_ack, bg_done, ol_done }
    reg [inWidth-1:0] swap_in [N_test-1:0]; // test inputs

    // test outputs organized as:
    // { swap, bg_start, ol_start, bg_done_ack, ol_done_ack }
    reg [outWidth-1:0] swap_out [N_test-1:0]; // expected outputs

    // test exp output / real output, report err
    task checkOutput;
        input [inWidth-1:0] inputarr;
        input [outWidth-1:0] checkoutarr;
        begin
            rst = inputarr[5];
            swap_ack = inputarr[4];
            bg_start_ack = inputarr[3];
            ol_start_ack = inputarr[2];
            bg_done = inputarr[1];
            ol_done = inputarr[0];
            #2
            // display happens at the end of the current sim step so ok
            if (checkoutarr == {swap, bg_start, ol_start, bg_done_ack, ol_done_ack}) begin
                $display("passed");
                $display("expected   : swap: %d, bg_start: %d, ol_start: %d, bg_done_ack: %d, ol_done_ack: %d", checkoutarr[4], checkoutarr[3], checkoutarr[2], checkoutarr[1], checkoutarr[0]);
                $display("test result: swap: %d, bg_start: %d, ol_start: %d, bg_done_ack: %d, ol_done_ack: %d", swap, bg_start, ol_start, bg_done_ack, ol_done_ack);
            end
            else begin 
                $display("next failed:");
                $display("expected   : swap: %d, bg_start: %d, ol_start: %d, bg_done_ack: %d, ol_done_ack: %d", checkoutarr[4], checkoutarr[3], checkoutarr[2], checkoutarr[1], checkoutarr[0]);
                $display("test result: swap: %d, bg_start: %d, ol_start: %d, bg_done_ack: %d, ol_done_ack: %d", swap, bg_start, ol_start, bg_done_ack, ol_done_ack);
            end
        end
    endtask

    task resetController;
        begin
            rst = 1;
            swap_ack = 0;
            bg_start_ack = 0;
            ol_start_ack = 0;
            bg_done = 0;
            ol_done = 0;
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
        $readmemh("swapcontroller_in.hex", swap_in);
        $readmemh("swapcontroller_out.hex", swap_out);

        begin: testerWrap
            integer i;
            resetController();
            #10 // warmup after reset, should be in state BackgroundStart
            for (i = 0; i < N_test; i = i + 1) begin
                checkOutput(swap_in[i], swap_out[i]);
            end
            $finish(); // stop running, all tests pass
        end
    end
endmodule
