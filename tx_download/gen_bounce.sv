`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// gen_bounce: generate a bounce signal
//////////////////////////////////////////////////////////////////////////////////

module gen_bounce (clk, sig_in, bounce_out);

    input clk, sig_in;
    output bounce_out;

    int bounce_delay_clocks, bounces;

    parameter int BOUNCE_CLOCKS_LOW_RANGE = 10;         // The minimum bounce in clocks
    parameter int BOUNCE_CLOCKS_HIGH_RANGE = 1000;      // The maximum bounce in clocks
    parameter int NUM_BOUNCES_LOW_RANGE = 2;            // The minimum number of bounces
    parameter int NUM_BOUNCES_HIGH_RANGE = 5;           // The maximum number of bounces

    // Task for generating a bouncy signal
    task bounce_btnc(input end_result);
        //$display("[%0tns] Starting bouncy btnc", $time/1000.0);
        bounces = $urandom_range(NUM_BOUNCES_LOW_RANGE,NUM_BOUNCES_HIGH_RANGE);
        for(int i = 0; i < bounces; i++) begin
            // Bounce to end result
            btnc = end_result;
            bounce_delay_clocks = $urandom_range(BOUNCE_CLOCKS_LOW_RANGE,BOUNCE_CLOCKS_HIGH_RANGE);
            repeat(bounce_delay_clocks)
                @(negedge clk);
            // Bounce to opposite of end result
            btnc = ~end_result;
            bounce_delay_clocks = $urandom_range(BOUNCE_CLOCKS_LOW_RANGE,BOUNCE_CLOCKS_HIGH_RANGE);
            repeat(bounce_delay_clocks)
                @(negedge clk);
        end
        // Done bouncing. Set to end result
        btnc = end_result;
    endtask


    // Task for initiating a transfer
    task initiate_tx( input [7:0] char_value );

        // set switches
        sw = char_value;
        repeat(10)
            @(negedge clk)

        // Make sure btnc is low
        if (btnc != 0) begin
            bounce_btnc(0);
            // repeat(BOUNCE_CLOCKS)
            //     @(negedge clk);
        end

        // Create a bouncy signal
        $display("[%0tns] Transmitting 0x%h", $time/1000.0, char_value);
        bounce_btnc(1);

        // Wait until busy goes high
        wait (rx_busy == 1'b1);

    endtask


endmodule
