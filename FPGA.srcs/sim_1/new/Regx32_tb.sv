`timescale 1ns / 1ps

import axi_vip_pkg::*;
import Regx32_veri_axi_vip_0_0_pkg::*;
xil_axi_resp_t 	resp;

module Regx32_tb();
    logic aclk;
    logic aresetn;
    logic [32*32-1:0] data_output;
    logic [32*32-1:0] data_read;
    Regx32_veri_wrapper DUT(.*);
    
    logic [32*32-1:0] data;
    integer i;
    integer j;
    integer k;
    integer errs = 0; // Initialized to 0, this is good.
    localparam logic[31:0] ADR = 32'h44A0_0000;
    
    always #10 aclk = ~aclk;
    
    Regx32_veri_axi_vip_0_0_mst_t master_agent;
    
    initial begin
        aclk = 1;
        aresetn = 0;
        master_agent = new("master vip agent", DUT.Regx32_veri_i.axi_vip_0.inst.IF);
        master_agent.start_master();
        #500 aresetn = 1;
    end
    
    task write(
        input logic [5:0] register_number,
        input logic [31:0] register_data
    );  begin
            master_agent.AXI4LITE_WRITE_BURST(ADR+{register_number, 2'b0}, 0, register_data, resp);
        end
    endtask
    
    task read(
        input logic [5:0] register_number,
        output logic [31:0] register_data    
    );  begin
            master_agent.AXI4LITE_READ_BURST(ADR+{register_number, 2'b0}, 0, register_data, resp);
        end
    endtask

    // ### ZMODYFIKOWANY TASK COMPARE ###
    task compare(
        input logic [32*32-1:0] data,
        output logic [32*32-1:0] data_read,
        inout integer errors 
    );  

        for (i = 0; i < 32; i++)
            #500 write(i, data[i*32 +: 32]);
        
        // 3. Odczytaj dane z powrotem (stan "PO")
        for (i = 0; i < 32; i++)
            #500 read(i, data_read[i*32 +: 32]);
        #500;

        // 5. Poczekaj na zegar, aby zaktualizował się stan "PO" na slv_regs
        @ (posedge aclk);
        #1;
        
        // 6. Porównaj oczekiwany stan "PO" z rzeczywistym stanem "PO"
        for (i = 0; i < 32*32; i++) begin
            if((data[i] != data_output[i]) || (data[i] != data_read[i]))
            begin
                errors = errors + 1;
                $display("Error on bit %d, data = %b, value(slv_regs) = %b, data_read = %b\n",
                         i, data[i], data[i], data_output[i], data_read[i]);                
            end
        end
    endtask
    
    initial begin
        wait(aresetn == 1);
        
        for (k=0; k<100; k++)
        begin
            for (j = 0; j < 32*32; j++) begin
                data[j]    = $urandom_range(0,1);
            end
            
            compare(data, data_read, errs);
        end
        
        #500;
        
        if (errs == 0) begin
            $display("--- TEST PASSED ---");
            $display("All %0d scenarios passed with 0 errors.", k);
        end else begin
            $display("--- TEST FAILED ---");
            $display("Found %0d errors in %0d scenarios.", errs, k);
        end

        $finish;
    end
    
endmodule