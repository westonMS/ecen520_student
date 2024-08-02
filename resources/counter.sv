//////////////////////////////////////////////////////////////////////////////////
// Filename: counter.sv
//////////////////////////////////////////////////////////////////////////////////


module counter(input logic clk, rst, inc, load,
               input logic [7:0] din,
               output logic [7:0] cnt);

    // Simple counter
    always@(posedge clk) begin
        if (rst) begin
            cnt <= 0;
        end
        else if (load) begin
            cnt <= din;
            $display("Counter loaded with 0x%h", din);
        end
        else if (inc) begin
            cnt <= cnt + 1;
            $display("Counter incremented to 0x%h",  cnt + 1);
        end
    end


endmodule

