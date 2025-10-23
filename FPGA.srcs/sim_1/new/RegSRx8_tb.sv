`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2025 19:16:24
// Design Name: 
// Module Name: RegSRx8_tb
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
    logic exp_output;
    
    RegSRx8_veri_wrapper DUT(.*);
    
    logic [255:0] data;
    integer i;
    integer errs = 0;
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
    
    initial begin
        wait(aresetn == 1);
    
        // Randomize data, setuj, resetuj
        for (i = 0; i < 256; i++) begin
            data[i]   = $urandom_range(0, 1);
            setuj[i]  = $urandom_range(0, 1);
            resetuj[i]= $urandom_range(0, 1);
        end
    
        // Write phase (each 32-bit word)
        for (i = 0; i < 8; i++)
            #500 write(i, data[i*32 +: 32]);
    
        // Read phase
        for (i = 0; i < 8; i++)
            #500 read(i, data_read[i*32 +: 32]);
    
        // Verification phase
        for (i = 0; i < (8*32-1); i++) begin
            if (resetuj[i])
                exp_output = 0;
            else if (setuj[i])
                exp_output <= 1;
            else
                exp_output <= data[i];
    
            if ((exp_output != slv_regs[i]) || (exp_output != data_read[i]))
                errs++;
        end
    
        #500 $finish;
    end
    
endmodule
