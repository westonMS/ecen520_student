//////////////////////////////////////////////////////////////////////////////////
// Filename: counter_test.sv
//////////////////////////////////////////////////////////////////////////////////


module counter_tb ();

    logic clk, rst, inc, load;
    logic [7:0] din, cnt;

    // instance counter
    counter counter_inst(.clk(clk), .rst(rst), .inc(inc), .load(load), .din(din), .cnt(cnt));

    // Free running Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Counter test inputs
    initial begin
        #50 rst = 1;
        load = 0;
        inc = 0;
        din = 0;
        repeat(10) @(negedge clk);
        rst = 0;
        for (int i = 0; i < 10; i = i + 1) begin
            repeat(6) @(negedge clk);
            inc = 1;
            @(negedge clk);
            inc = 0;
        end
        @(negedge clk);
        load = 1;
        din = 8'h5a;
        @(negedge clk);
        load = 0;
        for (int i = 0; i < 10; i = i + 1) begin
            repeat(6) @(negedge clk);
            inc = 1;
            @(negedge clk);
            inc = 0;
        end
        @(negedge clk);
        rst = 1;
        for (int i = 0; i < 10; i = i + 1) begin
            repeat(3) @(negedge clk);
            inc = 1;
            @(negedge clk);
            inc = 0;
        end
        @(negedge clk);
        rst = 0;
        for (int i = 0; i < 10; i = i + 1) begin
            repeat(6) @(negedge clk);
            inc = 1;
            @(negedge clk);
            inc = 0;
        end
        $stop;
    end

endmodule

