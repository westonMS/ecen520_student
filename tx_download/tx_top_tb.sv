`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// TX top-level testbench
//////////////////////////////////////////////////////////////////////////////////

module tx_top_tb ();

    logic clk, rst_n, rst, btnc, btnc_bouncy;
    logic [7:0] sw;
    logic [7:0] led_i;
    logic [7:0] led_sw;
    logic tx_out;
    logic rx_busy;
    logic tx_busy;
    logic [7:0] rx_data;
    logic [7:0] char_to_send = 0;

    parameter integer DEBOUNCE_TIME_US = 100;
    parameter logic PARITY = 1'd1;
    parameter integer BAUD_RATE = 19_200;
    parameter integer NUMBER_OF_CHARS = 3;
    localparam integer CLK_FREQUENCY = 100_000_000;
    localparam integer BOUNCE_CLOCKS = CLK_FREQUENCY / 1_000_000 * DEBOUNCE_TIME_US;

    // Clock Generator
    always begin
        clk <=1; #5ns;
        clk <=0; #5ns;
    end

    // reset
    assign rst = ~rst_n;

    // Debounce generator
    gen_bounce #(.BOUNCE_CLOCKS_LOW_RANGE(2), .BOUNCE_CLOCKS_HIGH_RANGE(20)) 
    bounce_btnc(
        .clk(clk),
        .sig_in(btnc),
        .bounce_out(btnc_bouncy)
    );

    // Instantiate Top-level design
    tx_top #(.DEBOUNCE_TIME_US(DEBOUNCE_TIME_US), .PARITY(PARITY), .BAUD_RATE(BAUD_RATE))
    tx_top(
        .CLK100MHZ(clk),
        .CPU_RESETN(rst_n),
        .SW(sw),
        .BTNC(btnc_bouncy),
        .LED(led_i),
        .UART_RXD_OUT(tx_out),
        .LED16_B(tx_busy)
    );

    // Instantiate RX simulation model
    rx_model #(.PARITY(PARITY), .BAUD_RATE(BAUD_RATE))
    rx_model(
        .clk(clk),
        .rst(rst),
        .rx_in(tx_out),
        .busy(rx_busy),
        .dout(rx_data)
    );

    // LEDs
    assign led_sw = led_i[7:0];

    task test_led( input [7:0] sw_val);
        sw = sw_val;
        repeat(3) @(negedge clk);
        if (led_sw != sw)
            $display("[%0tns] ERROR: LEDs do not follow switches LED=%h != SW=%h", $time/1000, led_sw, sw_val);
        repeat(3) @(negedge clk);
    endtask

    // Task for initiating a transfer
    task initiate_tx( input [7:0] char_value );

        // set switches
        sw = char_value;
        repeat(100)
            @(negedge clk)

        // Press the button and wait enough clocks to get it to go through the debouncer
        btnc = 1;
        repeat(BOUNCE_CLOCKS)
            @(negedge clk);
        // Wait until busy goes high
        wait (rx_busy == 1'b1);
        // Create a bouncy signal
        $display("[%0tns] Transmitting 0x%h", $time/1000.0, char_value);

        // Wait long enough for the zero to propagate through the debouncer
        btnc = 0;
        repeat(BOUNCE_CLOCKS*1.2)
            @(negedge clk);
        // Wait until busy goes low
        wait (rx_busy == 1'b0);

    endtask

    //////////////////////////////////
    // Main Test Bench Process
    //////////////////////////////////
    initial begin
        int clocks_to_delay;
        $display("===== TX Top TB =====");
        $display("BAUD_RATE %d PARITY %d DEBOUNCE_TIME_US %d BOUNCE_CLOCKS %d",
            BAUD_RATE, PARITY, DEBOUNCE_TIME_US, BOUNCE_CLOCKS);

        // Simulate some time with no stimulus/reset
        #100ns

        // Set some defaults
        rst_n = 1;
        btnc = 0;
        sw = 8'h00;
        #100ns

        //Test Reset
        $display("[%0tns] Reset", $time/1000.0);
        rst_n = 0;
        #80ns;
        // Un reset on negative edge
        @(negedge clk)
        rst_n = 1;

        // Make sure the LEDs follow the switches
        #100ns;
        test_led(8'ha5);
        #100ns;
        test_led(8'h5a);
        #100ns;
        sw = 8'h00;

        // Send a short signal that doesn't make it throught the debouncer
        $display("[%0tns] Sending some bounces. Should not transmit", $time/1000.0);
        btnc = 1;
        repeat(BOUNCE_CLOCKS/2)
            @(negedge clk);
        btnc = 0;
        repeat(10)
            @(negedge clk);

        //	Transmit a few characters to design
        #10us;
        for(int i = 0; i < NUMBER_OF_CHARS; i++) begin
            char_to_send = $urandom_range(0,255);
            initiate_tx(char_to_send);
            repeat(10000)
                @(negedge clk);
        end

        $stop;
    end

endmodule
