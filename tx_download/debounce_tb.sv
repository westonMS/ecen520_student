`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// TX top-level testbench
//////////////////////////////////////////////////////////////////////////////////

module debounce_tb ();

    logic clk, rst;
    logic sig_in, debounce_out;

    parameter integer DEBOUNCE_DELAY_US = 100;
    parameter integer NUM_TRANSITIONS = 10;
    parameter integer CLOCK_FREQUENCY = 100_000_000;

    localparam integer BOUNCE_CLOCKS = (DEBOUNCE_DELAY_US * CLOCK_FREQUENCY) / 1_000_000;

    // Task for toggling input
    task toggle_sig_in();
        @(negedge clk);
        if (sig_in == debounce_out)
            sig_in = ~debounce_out;
        else begin
            sig_in = debounce_out; // change the input to reset the debounce counter
            @(posedge clk);
            sig_in = ~debounce_out;
        end
        @(negedge clk);
    endtask

    // Task for checking the debounce output
    task check_debounce(logic expected_value, integer clocks);
        // Wait for the debounce to propagate and check to see that it doesn't propagate too early
        repeat(clocks) begin
            @(negedge clk);
            if (expected_value != debounce_out) begin
                $display("[%0tns] Error: Bounce signal error %d %d", $time/1000.0, expected_value, debounce_out);
                $stop;
            end
        end
    endtask

    task expect_debounce_change(logic expected_value, integer clocks);
        // Wait for the debounce transition to propagate
        for (int i = 0; i < clocks; i++) begin
            if (expected_value == debounce_out) begin
                //$display("[%0tns] Expected bounce signal change", $time/1000.0);
                return;
            end
            @(negedge clk);
        end
        $display("[%0tns] Error: Bounce signal did not change in time", $time/1000.0);
        $stop;
    endtask

    // Task for generating a bounce delay. 
    task simple_toggle_delay_test();
        automatic logic initial_debounce_out = debounce_out;
        $display("[%0tns] Long signal test", $time/1000.0);
        toggle_sig_in();
        // Wait for the debounce to propagatsim:/debounce_tb/#INITIAL#110(#ublk#203632578#110)e and check to see that it doesn't propagate too early
        check_debounce(initial_debounce_out,BOUNCE_CLOCKS-2);
        expect_debounce_change(~initial_debounce_out,10);
    endtask

    // Send a short runt pulse and check to make sure nothing has changed
    task runt_pulse_test();
        automatic logic initial_debounce_out = debounce_out;
        $display("[%0tns] Runt pulse test", $time/1000.0);
        toggle_sig_in();
        @(negedge clk);
        sig_in = debounce_out;
        @(negedge clk);
        // Wait and make sure runt does not propagate
        check_debounce(initial_debounce_out,BOUNCE_CLOCKS+10);
    endtask

    // Send a short runt pulse and check to make sure nothing has changed
    task runt_pulse_accumulate_test();
        automatic logic initial_debounce_out = debounce_out;
        $display("[%0tns] Runt accumulate test", $time/1000.0);
        @(negedge clk);
        sig_in = debounce_out;
        for (int i = 0; i < 2 * BOUNCE_CLOCKS+10; i++) begin
            if (initial_debounce_out != debounce_out) begin
                $display("[%0tns] Bounce signal changed too early", $time/1000.0);
                $stop;
            end
            @(negedge clk);
            sig_in = ~debounce_out;
            @(negedge clk);
            sig_in = debounce_out;
        end
    endtask

    // Clock Generator
    always begin
        clk <=1; #5ns;
        clk <=0; #5ns;
    end

    // Debouncer generator
    debounce #( .DEBOUNCE_CLKS(BOUNCE_CLOCKS) )
    debounce(
        .clk(clk),
        .rst(rst),
        .async_in(sig_in),
        .debounce_out(debounce_out)
    );

    //////////////////////////////////
    // Main Test Bench Process
    //////////////////////////////////
    initial begin
        // Tests
        // - provide a long pulse without any bounces and make sure the output changes approximately after the debounce clock times
        //   - Do this again for the opposite value
        // - provide a single runt pulse and make sure nothing changes after the full debounce clocks time
        // - provide a lot of runt pulses such that the sum is enough for the debounce clock. Make sure the output does not change for the full debounce clock times
        // - Provide a long pulse without any pulses and make sure the output changes approximately after the debounce clock times
        //  - Do this again for the opposite value

        int clocks_to_delay;
        $display("===== Debounce Testbench =====");

        // Simulate some time with no stimulus/reset
        #100ns

        // Set some defaults
        rst = 0;
        sig_in = 0;
        #100ns

        //Test Reset
        $display("[%0tns] Reset", $time/1000.0);
        rst = 1;
        #80ns;
        // Unreset on negative edge
        @(negedge clk)
        rst = 0;
        repeat (10) @(posedge clk);

        // Run the tests
        repeat (1000) @(posedge clk);
        simple_toggle_delay_test();
        repeat (1000) @(posedge clk);
        runt_pulse_test();
        repeat (1000) @(posedge clk);
        simple_toggle_delay_test();
        repeat (1000) @(posedge clk);
        runt_pulse_test();
        repeat (1000) @(posedge clk);
        runt_pulse_accumulate_test();
        repeat (1000) @(posedge clk);
        simple_toggle_delay_test();
        repeat (1000) @(posedge clk);
        runt_pulse_accumulate_test();
        repeat (1000) @(posedge clk);
        simple_toggle_delay_test();
        repeat (1000) @(posedge clk);
        $display("[%0tns] Finished without any errors", $time/1000.0);
        $stop;
    end

endmodule
