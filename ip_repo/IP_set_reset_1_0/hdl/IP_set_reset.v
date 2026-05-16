
`timescale 1 ns / 1 ps

	module IP_set_reset #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface ip_setreset
		parameter integer C_ip_setreset_DATA_WIDTH	= 32,
		parameter integer C_ip_setreset_ADDR_WIDTH	= 5
	)
	(
		// Users to add ports here
        output wire [8*32-1:0] data_output,
        input wire [8*32-1:0] reset,
        input wire [8*32-1:0] set,        
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface ip_setreset
		input wire  ip_setreset_aclk,
		input wire  ip_setreset_aresetn,
		input wire [C_ip_setreset_ADDR_WIDTH-1 : 0] ip_setreset_awaddr,
		input wire [2 : 0] ip_setreset_awprot,
		input wire  ip_setreset_awvalid,
		output wire  ip_setreset_awready,
		input wire [C_ip_setreset_DATA_WIDTH-1 : 0] ip_setreset_wdata,
		input wire [(C_ip_setreset_DATA_WIDTH/8)-1 : 0] ip_setreset_wstrb,
		input wire  ip_setreset_wvalid,
		output wire  ip_setreset_wready,
		output wire [1 : 0] ip_setreset_bresp,
		output wire  ip_setreset_bvalid,
		input wire  ip_setreset_bready,
		input wire [C_ip_setreset_ADDR_WIDTH-1 : 0] ip_setreset_araddr,
		input wire [2 : 0] ip_setreset_arprot,
		input wire  ip_setreset_arvalid,
		output wire  ip_setreset_arready,
		output wire [C_ip_setreset_DATA_WIDTH-1 : 0] ip_setreset_rdata,
		output wire [1 : 0] ip_setreset_rresp,
		output wire  ip_setreset_rvalid,
		input wire  ip_setreset_rready
	);
// Instantiation of Axi Bus Interface ip_setreset
	IP_set_reset_slave_lite_v1_0_ip_setreset # ( 
		.C_S_AXI_DATA_WIDTH(C_ip_setreset_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_ip_setreset_ADDR_WIDTH)
	) IP_set_reset_slave_lite_v1_0_ip_setreset_inst (
		.S_AXI_ACLK(ip_setreset_aclk),
		.S_AXI_ARESETN(ip_setreset_aresetn),
		.S_AXI_AWADDR(ip_setreset_awaddr),
		.S_AXI_AWPROT(ip_setreset_awprot),
		.S_AXI_AWVALID(ip_setreset_awvalid),
		.S_AXI_AWREADY(ip_setreset_awready),
		.S_AXI_WDATA(ip_setreset_wdata),
		.S_AXI_WSTRB(ip_setreset_wstrb),
		.S_AXI_WVALID(ip_setreset_wvalid),
		.S_AXI_WREADY(ip_setreset_wready),
		.S_AXI_BRESP(ip_setreset_bresp),
		.S_AXI_BVALID(ip_setreset_bvalid),
		.S_AXI_BREADY(ip_setreset_bready),
		.S_AXI_ARADDR(ip_setreset_araddr),
		.S_AXI_ARPROT(ip_setreset_arprot),
		.S_AXI_ARVALID(ip_setreset_arvalid),
		.S_AXI_ARREADY(ip_setreset_arready),
		.S_AXI_RDATA(ip_setreset_rdata),
		.S_AXI_RRESP(ip_setreset_rresp),
		.S_AXI_RVALID(ip_setreset_rvalid),
		.S_AXI_RREADY(ip_setreset_rready),
		.data_output(data_output),
		.write_enable(write_enable),
		.reset(reset),
		.set(set)
	);

	// Add user logic here

	// User logic ends

	endmodule
