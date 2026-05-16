`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: gf_timer
// Description: Single GF timer instance.
//              Assembles gf_timer_enable, gf_timer_counter, and N_CHANNELS
//              instances of gf_timer_channel.
//              Register interface is flat (plain signals) - no bus.
//              Intended for simulation and later wrapping with AXI-Lite regs.
//
// Parameter:
//   N_CHANNELS - number of waveform output channels (default 8)
//////////////////////////////////////////////////////////////////////////////////
module gf_timer #(
    parameter int N_CHANNELS = 8
) (
    input  logic clk,
    input  logic rst_n,

    // ---------- Control register fields ----------
    input  logic              ena_in,       // ENA bit
    input  logic              tmode_in,     // TMODE: 0=continuous, 1=NCYCLES
    input  logic [1:0]        emode_in,     // EMODE[1:0]
    input  logic [15:0]       ncycles_in,   // NCYCLES (TMODE 1)
    input  logic [N_CHANNELS-1:0] invert_in,// INVERT word (one bit per channel)

    // ---------- Enable sources ----------
    input  logic              ext_trigger_in, // external trigger (EMODE 1/2)
    input  logic              aena_in,        // atomic enable from timer 0 (EMODE 3)

    // ---------- Timer value registers ----------
    input  logic [31:0]       ovf_in,         // OVF: overflow/period value

    // ---------- Channel compare registers ----------
    input  logic [31:0]       cms_in [N_CHANNELS], // CxCMS per channel
    input  logic [31:0]       cmr_in [N_CHANNELS], // CxCMR per channel

    // ---------- Status outputs ----------
    output logic              busy_out,       // BUSY bit (read-only)
    output logic              ena_clear_out,  // pulse: clear ENA in CTRL register

    // ---------- Waveform outputs ----------
    output logic [N_CHANNELS-1:0] waveform_out
);

    // -------------------------------------------------------------------------
    // Internal wires
    // -------------------------------------------------------------------------
    logic        effective_ena;
    logic [31:0] cnt;
    logic        overflow;
    logic        busy;
    logic        ena_clear;

    // timer_start: single-cycle pulse on rising edge of busy
    logic        busy_q;
    logic        timer_start;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) busy_q <= 1'b0;
        else        busy_q <= busy;
    end

    assign timer_start = busy & ~busy_q;

    // -------------------------------------------------------------------------
    // Enable logic
    // -------------------------------------------------------------------------
    gf_timer_enable u_enable (
        .clk            (clk),
        .rst_n          (rst_n),
        .emode          (emode_in),
        .ena_in         (ena_in),
        .ext_trigger_in (ext_trigger_in),
        .aena_in        (aena_in),
        .busy_in        (busy),
        .effective_ena  (effective_ena)
    );

    // -------------------------------------------------------------------------
    // Counter core
    // -------------------------------------------------------------------------
    gf_timer_counter u_counter (
        .clk          (clk),
        .rst_n        (rst_n),
        .effective_ena(effective_ena),
        .tmode        (tmode_in),
        .ncycles      (ncycles_in),
        .ovf_val      (ovf_in),
        .cnt          (cnt),
        .overflow     (overflow),
        .busy         (busy),
        .ena_clear    (ena_clear)
    );

    // -------------------------------------------------------------------------
    // Waveform channels
    // -------------------------------------------------------------------------
    genvar i;
    generate
        for (i = 0; i < N_CHANNELS; i++) begin : gen_channels
            gf_timer_channel u_channel (
                .clk         (clk),
                .rst_n       (rst_n),
                .cnt         (cnt),
                .cms         (cms_in[i]),
                .cmr         (cmr_in[i]),
                .invert      (invert_in[i]),
                .timer_start (timer_start),
                .overflow    (overflow),
                .waveform_out(waveform_out[i])
            );
        end
    endgenerate

    // -------------------------------------------------------------------------
    // Status outputs
    // -------------------------------------------------------------------------
    assign busy_out      = busy;
    assign ena_clear_out = ena_clear;

endmodule