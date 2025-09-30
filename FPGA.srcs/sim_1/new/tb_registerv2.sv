`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.09.2025 17:33:41
// Design Name: 
// Module Name: tb_registerv2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_registerv2;

    logic [31:0] data;
    logic [31:0] reset;
    logic write_enable;
    logic [31:0] out;
    logic global_reset;
    logic [31:0] exp_out;

    int errors = 0;
    logic clk = 0;
    int i;

    always #5 clk = ~clk;

    Rejestrv2 dut(.*);

    task check_out();
        forever begin
            @(posedge clk);
            for (i = 0; i < 32; i++) begin
                if (reset[i])
                    exp_out[i] = 1'b0;
                else if (write_enable && data[i])
                    exp_out[i] = 1'b1;
            end
            if (exp_out[i] !== out[i]) begin
                errors++;
                $display("[%0t] ERROR: expected %h, got %h", $time, exp_out, out);
            end
        end
    endtask

    task set_out();
        forever begin
            @(negedge clk);
            data         = $urandom;
            reset        = $urandom;
            write_enable = $urandom_range(0,1);
            global_reset = $urandom_range(0,1);

            #1;
        end
    endtask

    initial begin
        data         = 0;
        reset        = 0;
        write_enable = 0;
        exp_out      = 0;
        global_reset = 0;

        fork
            check_out();
            set_out();
        join_any

        #1000;
        $display("Simulation finished. Errors = %0d", errors);
        $finish;
    end

endmodule
