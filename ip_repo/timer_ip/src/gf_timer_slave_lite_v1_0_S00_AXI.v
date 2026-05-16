`timescale 1 ns / 1 ps

    module gf_timer_slave_lite_v1_0_S00_AXI #
    (
        parameter integer C_S_AXI_DATA_WIDTH = 32,
        parameter integer C_S_AXI_ADDR_WIDTH = 7
    )
    (
        // Users to add ports here
        input  wire        ena_in,          // OR'd with CTRL[0] - start from pin or AXI
        input  wire        aena_in,         // OR'd with CTRL AENA bits - for EMODE 3
        input  wire        ext_trigger_in,  // for EMODE 1/2
        output wire        aena1_out,       // CTRL[5] → timer1/aena_in
        output wire        aena2_out,       // CTRL[6] → timer2/aena_in
        output wire        aena3_out,       // CTRL[7] → timer3/aena_in
        output wire        busy_out,
        output wire [7:0]  waveform_out,
        // User ports ends

        input wire  S_AXI_ACLK,
        input wire  S_AXI_ARESETN,
        input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
        input wire [2 : 0] S_AXI_AWPROT,
        input wire  S_AXI_AWVALID,
        output wire S_AXI_AWREADY,
        input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
        input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
        input wire  S_AXI_WVALID,
        output wire S_AXI_WREADY,
        output wire [1 : 0] S_AXI_BRESP,
        output wire S_AXI_BVALID,
        input wire  S_AXI_BREADY,
        input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
        input wire [2 : 0] S_AXI_ARPROT,
        input wire  S_AXI_ARVALID,
        output wire S_AXI_ARREADY,
        output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
        output wire [1 : 0] S_AXI_RRESP,
        output wire S_AXI_RVALID,
        input wire  S_AXI_RREADY
    );

    reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_awaddr;
    reg  axi_awready;
    reg  axi_wready;
    reg [1 : 0] axi_bresp;
    reg  axi_bvalid;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_araddr;
    reg  axi_arready;
    reg [1 : 0] axi_rresp;
    reg  axi_rvalid;
    reg [C_S_AXI_DATA_WIDTH-1 : 0] axi_rdata;

    localparam integer ADDR_LSB          = 2;
    localparam integer OPT_MEM_ADDR_BITS = 4;

    reg [1:0] state_write;
    reg [1:0] state_read;
    localparam Idle  = 2'b00;
    localparam Waddr = 2'b10;
    localparam Wdata = 2'b11;
    localparam Raddr = 2'b10;
    localparam Rdata = 2'b11;

    reg [17:0]       write_enable_reg;
    wire [17:0]      write_enable;
    assign write_enable = write_enable_reg;

    wire [18*32-1:0] reg_rdata_flat;

    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY  = axi_wready;
    assign S_AXI_BRESP   = axi_bresp;
    assign S_AXI_BVALID  = axi_bvalid;
    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RRESP   = axi_rresp;
    assign S_AXI_RVALID  = axi_rvalid;
    assign S_AXI_RDATA   = axi_rdata;

    // ------------------------------------------------------------------
    // Write state machine
    // ------------------------------------------------------------------
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_awready <= 0; axi_wready <= 0; axi_bvalid <= 0;
            axi_bresp   <= 0; axi_awaddr <= 0; state_write <= Idle;
        end else begin
            case (state_write)
                Idle: begin
                    axi_awready <= 1'b1; axi_wready <= 1'b1;
                    state_write <= Waddr;
                end
                Waddr: begin
                    if (S_AXI_AWVALID && S_AXI_AWREADY) begin
                        axi_awaddr <= S_AXI_AWADDR;
                        if (S_AXI_WVALID) begin
                            axi_awready <= 1'b1; state_write <= Waddr; axi_bvalid <= 1'b1;
                        end else begin
                            axi_awready <= 1'b0; state_write <= Wdata;
                            if (S_AXI_BREADY && axi_bvalid) axi_bvalid <= 1'b0;
                        end
                    end else begin
                        if (S_AXI_BREADY && axi_bvalid) axi_bvalid <= 1'b0;
                    end
                end
                Wdata: begin
                    if (S_AXI_WVALID) begin
                        state_write <= Waddr; axi_bvalid <= 1'b1; axi_awready <= 1'b1;
                    end else begin
                        if (S_AXI_BREADY && axi_bvalid) axi_bvalid <= 1'b0;
                    end
                end
            endcase
        end
    end

    // ------------------------------------------------------------------
    // Write enable - combinational, uses latched address
    // ------------------------------------------------------------------
    reg [4:0] wr_addr_sel;
    always @(*) begin
        wr_addr_sel = axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB];
    end

    always @(*) begin
        write_enable_reg = 18'b0;
        if (S_AXI_ARESETN && S_AXI_WVALID && S_AXI_WREADY) begin
            case (wr_addr_sel)
                5'd0:  write_enable_reg[0]  = 1'b1;
                5'd1:  write_enable_reg[1]  = 1'b1;
                5'd2:  write_enable_reg[2]  = 1'b1;
                5'd3:  write_enable_reg[3]  = 1'b1;
                5'd4:  write_enable_reg[4]  = 1'b1;
                5'd5:  write_enable_reg[5]  = 1'b1;
                5'd6:  write_enable_reg[6]  = 1'b1;
                5'd7:  write_enable_reg[7]  = 1'b1;
                5'd8:  write_enable_reg[8]  = 1'b1;
                5'd9:  write_enable_reg[9]  = 1'b1;
                5'd10: write_enable_reg[10] = 1'b1;
                5'd11: write_enable_reg[11] = 1'b1;
                5'd12: write_enable_reg[12] = 1'b1;
                5'd13: write_enable_reg[13] = 1'b1;
                5'd14: write_enable_reg[14] = 1'b1;
                5'd15: write_enable_reg[15] = 1'b1;
                5'd16: write_enable_reg[16] = 1'b1;
                5'd17: write_enable_reg[17] = 1'b1;
                default: write_enable_reg   = 18'b0;
            endcase
        end
    end

    // ------------------------------------------------------------------
    // Read state machine
    // ------------------------------------------------------------------
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_arready <= 1'b0; axi_rvalid <= 1'b0;
            axi_rresp   <= 1'b0; state_read <= Idle;
        end else begin
            case (state_read)
                Idle: begin
                    state_read <= Raddr; axi_arready <= 1'b1;
                end
                Raddr: begin
                    if (S_AXI_ARVALID && S_AXI_ARREADY) begin
                        state_read  <= Rdata; axi_araddr  <= S_AXI_ARADDR;
                        axi_rvalid  <= 1'b1;  axi_arready <= 1'b0;
                    end
                end
                Rdata: begin
                    if (S_AXI_RVALID && S_AXI_RREADY) begin
                        axi_rvalid  <= 1'b0; axi_arready <= 1'b1;
                        state_read  <= Raddr;
                    end
                end
            endcase
        end
    end

    // ------------------------------------------------------------------
    // Read data mux - combinational to avoid 1-cycle readback delay
    // ------------------------------------------------------------------
    reg [C_S_AXI_DATA_WIDTH-1:0] rdata_mux;
    always @(*) begin
        case (S_AXI_ARVALID ? S_AXI_ARADDR[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] 
                    : axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
            5'd0:  rdata_mux = reg_rdata_flat[0*32+31:0*32];
            5'd1:  rdata_mux = reg_rdata_flat[1*32+31:1*32];
            5'd2:  rdata_mux = reg_rdata_flat[2*32+31:2*32];
            5'd3:  rdata_mux = reg_rdata_flat[3*32+31:3*32];
            5'd4:  rdata_mux = reg_rdata_flat[4*32+31:4*32];
            5'd5:  rdata_mux = reg_rdata_flat[5*32+31:5*32];
            5'd6:  rdata_mux = reg_rdata_flat[6*32+31:6*32];
            5'd7:  rdata_mux = reg_rdata_flat[7*32+31:7*32];
            5'd8:  rdata_mux = reg_rdata_flat[8*32+31:8*32];
            5'd9:  rdata_mux = reg_rdata_flat[9*32+31:9*32];
            5'd10: rdata_mux = reg_rdata_flat[10*32+31:10*32];
            5'd11: rdata_mux = reg_rdata_flat[11*32+31:11*32];
            5'd12: rdata_mux = reg_rdata_flat[12*32+31:12*32];
            5'd13: rdata_mux = reg_rdata_flat[13*32+31:13*32];
            5'd14: rdata_mux = reg_rdata_flat[14*32+31:14*32];
            5'd15: rdata_mux = reg_rdata_flat[15*32+31:15*32];
            5'd16: rdata_mux = reg_rdata_flat[16*32+31:16*32];
            5'd17: rdata_mux = reg_rdata_flat[17*32+31:17*32];
            default: rdata_mux = 32'b0;
        endcase
    end

    // Register rdata only when transaction completes
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN)
            axi_rdata <= 32'b0;
        else if (S_AXI_ARVALID && S_AXI_ARREADY)
            axi_rdata <= rdata_mux;
    end

    // ------------------------------------------------------------------
    // gf_timer_regs instantiation
    // ------------------------------------------------------------------
    gf_timer_regs #(
        .N_CHANNELS(8)
    ) u_timer_regs (
        .clk            (S_AXI_ACLK),
        .rst_n          (S_AXI_ARESETN),
        .reg_wdata      (S_AXI_WDATA),
        .reg_we         (write_enable),
        .reg_rdata      (reg_rdata_flat),
        .ena_in         (ena_in),
        .aena_in        (aena_in),
        .ext_trigger_in (ext_trigger_in),
        .aena1_out      (aena1_out),
        .aena2_out      (aena2_out),
        .aena3_out      (aena3_out),
        .busy_out       (busy_out),
        .waveform_out   (waveform_out)
    );

    endmodule