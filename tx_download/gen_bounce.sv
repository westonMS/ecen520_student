`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// gen_bounce: generate a bounce signal for simulating a debouncer
//////////////////////////////////////////////////////////////////////////////////

module gen_bounce (clk, sig_in, bounce_out);

    input clk, sig_in;
    output logic bounce_out;

    parameter integer BOUNCE_CLOCKS_LOW_RANGE = 10;         // The minimum bounce in clocks
    parameter integer BOUNCE_CLOCKS_HIGH_RANGE = 1000;      // The maximum bounce in clocks
    parameter integer NUM_BOUNCES_LOW_RANGE = 2;            // The minimum number of bounces per transition
    parameter integer NUM_BOUNCES_HIGH_RANGE = 5;           // The maximum number of bounces per transition
    parameter integer VERBOSE = 0;                          // Set verbose to 1 to print debug messages

    // Random number generator for bounce clocks
    function int get_bounce_clocks;
        get_bounc_clocks = $urandom_range(BOUNCE_CLOCKS_LOW_RANGE, BOUNCE_CLOCKS_HIGH_RANGE);
    endfunction

    // Random number generator for number of bounces
    function int get_bounce_number;
        get_bounc_clocks = $urandom_range(NUM_BOUNCES_LOW_RANGE, NUM_BOUNCES_HIGH_RANGE);
    endfunction

    // Task for generating a bounce delay. 
    task bounce_delay(input expected_sig_in);
        integer bounce_delay_clocks;
        bounce_delay_clocks = get_bounce_clocks();
        repeat(bounce_delay_clocks)
            @(posedge clk);
            if (sig_in != expected_sig_in)
                return;
    endtask

    initial begin
        // Wait until sig_in is stable ('0' or '1') before doing anything
        @(posedge clk)  // Wait a clock before checking sig_in
        while(sig_in != 0 && sig_in != 1)
            // Continue waiting until sig_in is stable
            @(posedge clk)
        // Set the stable value of sig_in after a stable value has been clocked
        bounce_out = sig_in;
        // Continuosly monitor sig_in for changes
        forever begin
            always_ff(posedge clk) begin
                if (sig_in != bounce_out) begin
                    bounce_btnc(sig_in);
                end
            end
        end
    end

    // Task for generating a bouncy signal. The end result is the final value of debounce_out.
    // The sig_in input should be the 'end_result'. If it is not, then abandone the bounce.
    task bounce(input end_result);
        integer bounces;
        bounces = get_bounce_number()
        for(int i = 0; i < bounces; i++) begin
            // Set bounce_out to the opposite of the end result
            bounce_out = ~end_result;
            // Delay before edge of bounce towards end result
            bounce_delay(end_result);
            // Check to see if the signal has changed back to the original value. If so, abandon the rest of the bounce
            if (sig_in != end_result)
                return;
            // Set bounce_out to end result
            bounce_out = end_result;
            // Delay before changing back away from end result
            if (i < bounces - 1) // Do not delay if this is the last bounce
                bounce_delay(end_result); 
        end
    endtask

endmodule
