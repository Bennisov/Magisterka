`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.09.2025 18:26:46
// Design Name: 
// Module Name: tb_register
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


module tb_register;

    // DUT signals
    logic [31:0] data;
    logic [31:0] set;
    logic [31:0] reset;
    logic        write_enable;
    logic [31:0] out;
    logic global_reset;

    // reference model
    logic [31:0] exp_out;

    // bookkeeping
    int errors = 0;
    logic clk = 0;
    int i;

    // clock
    always #5 clk = ~clk;

    // DUT instance (assume module is named rejestr)
    rejestr dut(.*);

    // Reference model update
    task check_out();
        forever begin
            @(posedge clk);
            for (i = 0; i < 32; i++) begin
                if (reset[i])
                    exp_out[i] = 1'b0;
                else if (set[i])
                    exp_out[i] = 1'b1;
                else if (write_enable)
                    exp_out[i] = data[i];
                // else keep previous value
            end

            // compare against DUT output
            if (exp_out[i] !== out[i]) begin
                errors++;
                $display("[%0t] ERROR: expected %h, got %h", $time, exp_out, out);
            end
        end
    endtask

    // Stimulus
    task set_out();
        forever begin
            @(negedge clk);
            // generate random values
            data         = $urandom;
            set          = $urandom;
            reset        = $urandom;
            write_enable = $urandom_range(0,1);
            global_reset = $urandom_range(0,1);

            // small delay so DUT sees values before next clk edge
            #1;
        end
    endtask

    // Test control
    initial begin
        // init
        data         = 0;
        set          = 0;
        reset        = 0;
        write_enable = 0;
        exp_out      = 0;
        global_reset = 0;

        fork
            check_out();
            set_out();
        join_any

        #1000; // run for some time
        $display("Simulation finished. Errors = %0d", errors);
        $finish;
    end

endmodule

