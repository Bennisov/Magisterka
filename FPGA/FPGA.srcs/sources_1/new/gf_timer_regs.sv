`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: gf_timer_regs
// Description: Register file for one GF timer instance.
//              Instantiates 18 x Rejestrv2 (one per register map entry) and
//              wires them to gf_timer ports.
//
// Intended to sit between the AXI slave (future gf_timer_axi) and gf_timer.
// The AXI layer drives: reg_wdata, reg_we[17:0], reg_global_reset
// The AXI layer reads:  reg_rdata[17:0]
//
// Register map (from spec PDF):
//   Reg  0  0x0000  CTRL
//   Reg  1  0x0004  OVF
//   Reg  2  0x0008  C0CMS
//   Reg  3  0x000C  C0CMR
//   Reg  4  0x0010  C1CMS
//   Reg  5  0x0014  C1CMR
//   Reg  6  0x0018  C2CMS
//   Reg  7  0x001C  C2CMR
//   Reg  8  0x0020  C3CMS
//   Reg  9  0x0024  C3CMR
//   Reg 10  0x0028  C4CMS
//   Reg 11  0x002C  C4CMR
//   Reg 12  0x0030  C5CMS
//   Reg 13  0x0034  C5CMR
//   Reg 14  0x0038  C6CMS
//   Reg 15  0x003C  C6CMR
//   Reg 16  0x0040  C7CMS
//   Reg 17  0x0044  C7CMR
//
// CTRL register bit layout (reg 0):
//   [31:16] NCYCLES[15:0]
//   [15:8]  INVERT[7:0]
//   [7]     AENA3  (active only in timer 0)
//   [6]     AENA2  (active only in timer 0)
//   [5]     AENA1  (active only in timer 0)
//   [4:3]   EMODE[1:0]
//   [2]     TMODE
//   [1]     BUSY   - read-only, driven by busy_out; write ignored
//   [0]     ENA
//
// Special reset wiring for CTRL:
//   reset[0]   <- ena_clear_out      (timer auto-clears ENA after NCYCLES)
//   reset[5]   <- aena1_clear_in     (timer 1 clears AENA1, future use)
//   reset[6]   <- aena2_clear_in     (timer 2 clears AENA2, future use)
//   reset[7]   <- aena3_clear_in     (timer 3 clears AENA3, future use)
//   reset[1]   <- 1'b0               (BUSY bit not reset by timer)
//   reset[31:8, 4:2] <- '0           (all other bits: no external reset)
//
// BUSY read-only:
//   reg_rdata[0] is the normal Rejestrv2 output for CTRL.
//   The AXI read layer must substitute bit [1] with busy_out.
//   This is done combinationally in the rdata_ctrl output below.
//////////////////////////////////////////////////////////////////////////////////

module gf_timer_regs #(
    parameter int N_CHANNELS = 8
) (
    input  logic        clk,
    input  logic        rst_n,          // active-low async reset (converted to global_reset)

    // ------------------------------------------------------------------
    // Interface toward AXI layer (future gf_timer_axi)
    // ------------------------------------------------------------------
    input  logic [31:0] reg_wdata,      // write data bus (shared across all regs)
    input  logic [17:0] reg_we,         // write enable, one bit per register
    output logic [31:0] reg_rdata [18], // read data per register

    // ------------------------------------------------------------------
    // External resets for AENA bits (from other timer instances)
    // Only used when this is timer 0; tie to 0 for timers 1-3.
    // ------------------------------------------------------------------
    input  logic        aena1_clear_in, // from timer 1 ena_clear_out
    input  logic        aena2_clear_in, // from timer 2 ena_clear_out
    input  logic        aena3_clear_in, // from timer 3 ena_clear_out

    // ------------------------------------------------------------------
    // Waveform outputs (pass-through from gf_timer)
    // ------------------------------------------------------------------
    output logic [N_CHANNELS-1:0] waveform_out,

    // ------------------------------------------------------------------
    // External trigger input (EMODE 1/2)
    // ------------------------------------------------------------------
    input  logic        ext_trigger_in
);

    // ------------------------------------------------------------------
    // global_reset: convert active-low rst_n to active-high for Rejestrv2
    // ------------------------------------------------------------------
    logic global_reset;
    assign global_reset = ~rst_n;

    // ------------------------------------------------------------------
    // Register outputs (raw from Rejestrv2)
    // ------------------------------------------------------------------
    logic [31:0] ctrl_out;   // reg 0
    logic [31:0] ovf_out;    // reg 1
    logic [31:0] cms_out [N_CHANNELS];
    logic [31:0] cmr_out [N_CHANNELS];

    // ------------------------------------------------------------------
    // Signals from gf_timer back to CTRL register
    // ------------------------------------------------------------------
    logic        busy_out;
    logic        ena_clear_out;

    // ------------------------------------------------------------------
    // CTRL reset vector
    // reset[0]  <- ena_clear_out    (ENA auto-clear)
    // reset[5]  <- aena1_clear_in
    // reset[6]  <- aena2_clear_in
    // reset[7]  <- aena3_clear_in
    // all others <- 0
    // ------------------------------------------------------------------
    logic [31:0] ctrl_reset;
    assign ctrl_reset = {
        24'b0,              // [31:8] no external reset
        aena3_clear_in,     // [7]  AENA3
        aena2_clear_in,     // [6]  AENA2
        aena1_clear_in,     // [5]  AENA1
        2'b00,              // [4:3] EMODE - no external reset
        1'b0,               // [2]  TMODE - no external reset
        1'b0,               // [1]  BUSY  - not reset by timer
        ena_clear_out       // [0]  ENA
    };

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

    // BUSY read-only: substitute bit [1] with live busy_out on reads
    // All other bits come directly from the register FF
    always_comb begin
        reg_rdata[0]    = ctrl_out;
        reg_rdata[0][1] = busy_out;   // override BUSY bit with live value
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
    assign reg_rdata[1] = ovf_out;

    // ------------------------------------------------------------------
    // Regs 2-17: CxCMS and CxCMR (8 channel pairs)
    // ------------------------------------------------------------------
    genvar ch;
    generate
        for (ch = 0; ch < N_CHANNELS; ch++) begin : gen_ch_regs

            // CxCMS - reg index: 2 + ch*2
            Rejestrv2 u_cms (
                .clk          (clk),
                .global_reset (global_reset),
                .data         (reg_wdata),
                .write_enable (reg_we[2 + ch*2]),
                .reset        (32'b0),
                .out          (cms_out[ch])
            );
            assign reg_rdata[2 + ch*2] = cms_out[ch];

            // CxCMR - reg index: 3 + ch*2
            Rejestrv2 u_cmr (
                .clk          (clk),
                .global_reset (global_reset),
                .data         (reg_wdata),
                .write_enable (reg_we[3 + ch*2]),
                .reset        (32'b0),
                .out          (cmr_out[ch])
            );
            assign reg_rdata[3 + ch*2] = cmr_out[ch];

        end
    endgenerate

    // ------------------------------------------------------------------
    // CTRL field extraction (wired to gf_timer inputs)
    // ------------------------------------------------------------------
    logic        ena;
    logic        tmode;
    logic [1:0]  emode;
    logic [15:0] ncycles;
    logic [7:0]  invert;
    logic        aena1, aena2, aena3;

    assign ena     = ctrl_out[0];
    assign tmode   = ctrl_out[2];
    assign emode   = ctrl_out[4:3];
    assign aena1   = ctrl_out[5];
    assign aena2   = ctrl_out[6];
    assign aena3   = ctrl_out[7];
    assign invert  = ctrl_out[15:8];
    assign ncycles = ctrl_out[31:16];

    // ------------------------------------------------------------------
    // gf_timer instantiation
    // ------------------------------------------------------------------
    gf_timer #(
        .N_CHANNELS (N_CHANNELS)
    ) u_timer (
        .clk            (clk),
        .rst_n          (rst_n),

        // CTRL fields
        .ena_in         (ena),
        .tmode_in       (tmode),
        .emode_in       (emode),
        .ncycles_in     (ncycles),
        .invert_in      (invert),

        // Enable sources
        .ext_trigger_in (ext_trigger_in),
        .aena_in        (aena1 | aena2 | aena3), // any AENA asserted starts timer in EMODE 3

        // Timer registers
        .ovf_in         (ovf_out),
        .cms_in         (cms_out),
        .cmr_in         (cmr_out),

        // Status
        .busy_out       (busy_out),
        .ena_clear_out  (ena_clear_out),

        // Waveform
        .waveform_out   (waveform_out)
    );

endmodule