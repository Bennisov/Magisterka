`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2025 03:49:16 PM
// Design Name: 
// Module Name: tb_simple_axi_register
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
import axi_register_verification_axi_vip_0_0_pkg::*;
xil_axi_resp_t 	resp;

module tb_simple_axi_register();
	localparam logic[31:0] AXI_REGISTER_BANK_ADDRESS = 32'h44A0_0000;

	// ------ UUT ------
	logic aclk;
	logic aresetn;

	axi_register_verification_wrapper uut ( .* );
	
	// ------- AXI master agent ------	
	axi_register_verification_axi_vip_0_0_mst_t      master_agent;
	
	// ------ clock generator ------
	always #5 aclk = ~aclk;
	
	// ------ initialization and reset ------
	initial begin
		aclk = 1;
		aresetn = 0;
		
		master_agent = new( "master vip agent", uut.axi_register_verification_i.axi_vip_0.inst.IF );
		master_agent.start_master();
		
		#500 aresetn = 1;
	end
	
	// ************************************ Tasks ************************************
	// ------ write AXI register task ------
	task write_axi_register(
		input logic [1:0] register_number,
		input	logic [31:0]	register_data
	); begin
			// ARM has byte-oriented addressing, so 32b word of register value occupies four addresses.
			// Therefore register 0 has address 0, register 1 - address 4, etc.
			// Register address have to be added to the AXI perypheral base address, set in Address Editor tab of IP integrator
			master_agent.AXI4LITE_WRITE_BURST( AXI_REGISTER_BANK_ADDRESS + { register_number, 2'b0 }, 0, register_data, resp );
		
		end
	endtask
	
	// ------ read AXI register task ------
	task read_axi_register(
		input logic [1:0] register_number
	); begin
			logic [31:0]	register_data;
			
			master_agent.AXI4LITE_READ_BURST( AXI_REGISTER_BANK_ADDRESS + { register_number, 2'b0 }, 0, register_data, resp );
			$display( "%0t - register 0x%0H (%d) read value 0x%0H (%d)", $time, register_number, register_number, register_data, register_data );
		end
	endtask
	
	// ************************************ TB ************************************
	// ------ main TB ------
	initial begin
		wait( aresetn === 1 );
		
		#500 write_axi_register( 0, 13 );
		#500 write_axi_register( 1, 26 );
		#500 write_axi_register( 2, 157 );
		#500 write_axi_register( 3, 228 );
		
		#500 read_axi_register( 0 );
		#500 read_axi_register( 1 );
		#500 read_axi_register( 2 );
		#500 read_axi_register( 3 );
		
		#500 $finish;
	end

endmodule
