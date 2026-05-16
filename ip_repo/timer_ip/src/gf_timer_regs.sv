`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: gf_timer_regs
// Description: Register file for one GF timer instance.
//              18 x Rejestrv2 wired to gf_timer ports.
//
// Register map:
//   Reg  0  0x0000  CTRL   [31:16]=NCYCLES [15:8]=INVERT [7]=AENA3 [6]=AENA2
//                          [5]=AENA1 [4:3]=EMODE [2]=TMODE [1]=BUSY(RO) [0]=ENA
//   Reg  1  0x0004  OVF
//   Reg  2-17       CxCMS/CxCMR
//
// ena_in port: OR'd with CTRL[0] so timer can be started from AXI or external pin
// aena_in port: OR'd with CTRL AENA bits for EMODE 3
//////////////////////////////////////////////////////////////////////////////////
module gf_timer_regs #(
    parameter int N_CHANNELS = 8
) (
    input  logic        clk,
    input  logic        rst_n,

    // AXI layer interface
    input  logic [31:0]       reg_wdata,
    input  logic [17:0]       reg_we,
    output logic [18*32-1:0]  reg_rdata,

    // External control inputs
    input  logic        ena_in,           // OR'd with CTRL[0] - start from pin or AXI
    input  logic        aena_in,          // OR'd with CTRL AENA bits - for EMODE 3
    input  logic        ext_trigger_in,   // for EMODE 1/2

    // AENA outputs (CTRL[7:5]) → connect to other timers' aena_in
    output logic        aena1_out,
    output logic        aena2_out,
    output logic        aena3_out,

    // Status
    output logic        busy_out,

    // Waveform
    output logic [N_CHANNELS-1:0] waveform_out
);

    // active-high reset for Rejestrv2
    logic global_reset;
    assign global_reset = ~rst_n;

    // raw register outputs
    logic [31:0] ctrl_out;
    logic [31:0] ovf_out;
    logic [31:0] cms_out [N_CHANNELS];
    logic [31:0] cmr_out [N_CHANNELS];

    // ena_clear from timer - resets ENA bit in CTRL
    logic ena_clear;

    // CTRL reset vector:
    //   [0] ENA  ← ena_clear (timer auto-clears after NCYCLES)
    //   rest     ← 0 (software clears via AXI write)
    logic [31:0] ctrl_reset;
    assign ctrl_reset = {31'b0, ena_clear};

    // ------------------------------------------------------------------
    // Reg 0: CTRL
    // ------------------------------------------------------------------
    Rejestrv2 u_ctrl (
        .clk          (clk),
        .global_reset (global_reset),
        .data         (reg_wdata),
        .write_enable (reg_we[0]),
        .reset        (ctrl_reset),
        .out          (ctrl_out)
    );

    // BUSY read-only: substitute bit [1] with live busy_out
    always_comb begin
        reg_rdata[0*32+31:0*32] = ctrl_out;
        reg_rdata[0*32+1]       = busy_out;
    end

    // ------------------------------------------------------------------
    // Reg 1: OVF
    // ------------------------------------------------------------------
    Rejestrv2 u_ovf (
        .clk          (clk),
        .global_reset (global_reset),
        .data         (reg_wdata),
        .write_enable (reg_we[1]),
        .reset        (32'b0),
        .out          (ovf_out)
    );
    assign reg_rdata[1*32+31:1*32] = ovf_out;

    // ------------------------------------------------------------------
    // Regs 2-17: CxCMS / CxCMR
    // ------------------------------------------------------------------
    genvar ch;
    generate
        for (ch = 0; ch < N_CHANNELS; ch++) begin : gen_ch_regs
            Rejestrv2 u_cms (
                .clk          (clk),
                .global_reset (global_reset),
                .data         (reg_wdata),
                .write_enable (reg_we[2 + ch*2]),
                .reset        (32'b0),
                .out          (cms_out[ch])
            );
            assign reg_rdata[(2+ch*2)*32+31:(2+ch*2)*32] = cms_out[ch];

            Rejestrv2 u_cmr (
                .clk          (clk),
                .global_reset (global_reset),
                .data         (reg_wdata),
                .write_enable (reg_we[3 + ch*2]),
                .reset        (32'b0),
                .out          (cmr_out[ch])
            );
            assign reg_rdata[(3+ch*2)*32+31:(3+ch*2)*32] = cmr_out[ch];
        end
    endgenerate

    // ------------------------------------------------------------------
    // CTRL field extraction
    // ------------------------------------------------------------------
    logic        ena_reg;    // ENA bit from register
    logic        tmode;
    logic [1:0]  emode;
    logic [15:0] ncycles;
    logic [7:0]  invert;
    logic        aena1_reg, aena2_reg, aena3_reg;

    assign ena_reg    = ctrl_out[0];
    // bit[1] = BUSY - RO
    assign tmode      = ctrl_out[2];
    assign emode      = ctrl_out[4:3];
    assign aena1_reg  = ctrl_out[5];
    assign aena2_reg  = ctrl_out[6];
    assign aena3_reg  = ctrl_out[7];
    assign invert     = ctrl_out[15:8];
    assign ncycles    = ctrl_out[31:16];

    // AENA outputs - directly from CTRL register bits
    assign aena1_out = aena1_reg;
    assign aena2_out = aena2_reg;
    assign aena3_out = aena3_reg;

    // ------------------------------------------------------------------
    // gf_timer instantiation
    // ENA:  OR of register bit and external pin
    // AENA: OR of register AENA bits and external aena_in port
    // ------------------------------------------------------------------
    gf_timer #(
        .N_CHANNELS (N_CHANNELS)
    ) u_timer (
        .clk            (clk),
        .rst_n          (rst_n),
        .ena_in         (ena_reg | ena_in),
        .tmode_in       (tmode),
        .emode_in       (emode),
        .ncycles_in     (ncycles),
        .invert_in      (invert),
        .ext_trigger_in (ext_trigger_in),
        .aena_in        (aena1_reg | aena2_reg | aena3_reg | aena_in),
        .ovf_in         (ovf_out),
        .cms_in         (cms_out),
        .cmr_in         (cmr_out),
        .busy_out       (busy_out),
        .ena_clear_out  (ena_clear),
        .waveform_out   (waveform_out)
    );

endmodule