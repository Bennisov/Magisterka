
`timescale 1 ns / 1 ps

	module Reg_reset_only #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface reset_only
		parameter integer C_reset_only_DATA_WIDTH	= 32,
		parameter integer C_reset_only_ADDR_WIDTH	= 5
	)
	(
		// Users to add ports here
        input wire [8*32-1:0] reset,
        output wire [8*32-1:0] reg_slvs,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface reset_only
		input wire  reset_only_aclk,
		input wire  reset_only_aresetn,
		input wire [C_reset_only_ADDR_WIDTH-1 : 0] reset_only_awaddr,
		input wire [2 : 0] reset_only_awprot,
		input wire  reset_only_awvalid,
		output wire  reset_only_awready,
		input wire [C_reset_only_DATA_WIDTH-1 : 0] reset_only_wdata,
		input wire [(C_reset_only_DATA_WIDTH/8)-1 : 0] reset_only_wstrb,
		input wire  reset_only_wvalid,
		output wire  reset_only_wready,
		output wire [1 : 0] reset_only_bresp,
		output wire  reset_only_bvalid,
		input wire  reset_only_bready,
		input wire [C_reset_only_ADDR_WIDTH-1 : 0] reset_only_araddr,
		input wire [2 : 0] reset_only_arprot,
		input wire  reset_only_arvalid,
		output wire  reset_only_arready,
		output wire [C_reset_only_DATA_WIDTH-1 : 0] reset_only_rdata,
		output wire [1 : 0] reset_only_rresp,
		output wire  reset_only_rvalid,
		input wire  reset_only_rready
	);
// Instantiation of Axi Bus Interface reset_only
	Reg_reset_only_slave_lite_v1_0_reset_only # ( 
		.C_S_AXI_DATA_WIDTH(C_reset_only_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_reset_only_ADDR_WIDTH)
	) Reg_reset_only_slave_lite_v1_0_reset_only_inst (
		.S_AXI_ACLK(reset_only_aclk),
		.S_AXI_ARESETN(reset_only_aresetn),
		.S_AXI_AWADDR(reset_only_awaddr),
		.S_AXI_AWPROT(reset_only_awprot),
		.S_AXI_AWVALID(reset_only_awvalid),
		.S_AXI_AWREADY(reset_only_awready),
		.S_AXI_WDATA(reset_only_wdata),
		.S_AXI_WSTRB(reset_only_wstrb),
		.S_AXI_WVALID(reset_only_wvalid),
		.S_AXI_WREADY(reset_only_wready),
		.S_AXI_BRESP(reset_only_bresp),
		.S_AXI_BVALID(reset_only_bvalid),
		.S_AXI_BREADY(reset_only_bready),
		.S_AXI_ARADDR(reset_only_araddr),
		.S_AXI_ARPROT(reset_only_arprot),
		.S_AXI_ARVALID(reset_only_arvalid),
		.S_AXI_ARREADY(reset_only_arready),
		.S_AXI_RDATA(reset_only_rdata),
		.S_AXI_RRESP(reset_only_rresp),
		.S_AXI_RVALID(reset_only_rvalid),
		.S_AXI_RREADY(reset_only_rready),
		.reset(reset),
		.slv_regs(slv_regs)
	);

	// Add user logic here

	// User logic ends

	endmodule
