`timescale 1ns / 1ps

import axi_vip_pkg::*;
import RegSRx8_veri_axi_vip_0_0_pkg::*;
xil_axi_resp_t 	resp;

module RegSRx8_tb();
    logic aclk;
    logic aresetn;
    logic [255:0] resetuj;
    logic [255:0] setuj;
    logic [255:0] slv_regs;
    logic [255:0] data_read;
    logic [255:0] exp_output;   
    RegSRx8_veri_wrapper DUT(.*);
    
    logic [255:0] data;
    integer i;
    integer j;
    integer k;
    integer errs = 0; // Initialized to 0, this is good.
    localparam logic[31:0] ADR = 32'h44A0_0000;
    
    always #10 aclk = ~aclk;
    
    RegSRx8_veri_axi_vip_0_0_mst_t master_agent;
    
    initial begin
        aclk = 1;
        aresetn = 0;
        master_agent = new("master vip agent", DUT.RegSRx8_veri_i.axi_vip_0.inst.IF);
        master_agent.start_master();
        #500 aresetn = 1;
    end
    
    task write(
        input logic [2:0] register_number,
        input logic [31:0] register_data
    );  begin
            master_agent.AXI4LITE_WRITE_BURST(ADR+{register_number, 2'b0}, 0, register_data, resp);
        end
    endtask
    
    task read(
        input logic [2:0] register_number,
        output logic [31:0] register_data    
    );  begin
            master_agent.AXI4LITE_READ_BURST(ADR+{register_number, 2'b0}, 0, register_data, resp);
        end
    endtask

    task compare(
        input logic [32*8-1:0] set,
        input logic [32*8-1:0] reset,
        input logic [32*8-1:0] data,
        output logic [255:0] data_read, 
        output logic [255:0] exp_output,
        inout integer errors 
    );  begin
            for (i = 0; i < 8; i++)
                #500 write(i, data[i*32 +: 32]);
            
            for (i = 0; i < 8; i++)
                #500 read(i, data_read[i*32 +: 32]);
            #500;

            exp_output = ~reset & (set | data);

            @ (posedge aclk);
            #1;
            
            for (i = 0; i < 256; i++) begin
                if((exp_output[i] != slv_regs[i]) || (exp_output[i] != data_read[i]))
                begin
                    errors = errors + 1;
                    $display("Error on bit %d, where rst = %b, set = %b, data = %b, exp = %b, value(slv_regs) = %b, data_read = %b\n",
                             i, reset[i], set[i], data[i], exp_output[i], slv_regs[i], data_read[i]);                
                end
            end
        end
    endtask
    
    initial begin
        wait(aresetn == 1);
        
        for (k=0; k<100; k++)
        begin
            for (j = 0; j < 256; j++) begin
                data[j]    = $urandom_range(0,1);
                setuj[j]   = $urandom_range(0,1);
                resetuj[j] = $urandom_range(0,1);
            end
            
            compare(setuj, resetuj, data, data_read, exp_output, errs);
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