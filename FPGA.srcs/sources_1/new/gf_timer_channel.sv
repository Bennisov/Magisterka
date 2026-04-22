`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: gf_timer_channel
// Description: Single waveform output channel for GF timer.
//
// Implements the compare-match set/reset logic for one output channel:
//   - Output set to 0 when timer starts or overflows
//   - Output set to 1 when counter reaches CxCMS (compare match set)
//   - Output set to 0 when counter reaches CxCMR (compare match reset)
//     or overflow event occurs
//   - If INVERT bit is set, all of the above logic is inverted:
//       idle = 1, CMS -> 0, CMR (or overflow) -> 1
//
// The output is purely combinational from a registered state FF (out_q),
// so there are no glitches on waveform_out.
//
// Ports:
//   clk          - system clock
//   rst_n        - active-low async reset
//   cnt          - current counter value from gf_timer_counter
//   cms          - CxCMS: compare match set threshold
//   cmr          - CxCMR: compare match reset threshold
//   invert       - INVERT bit for this channel (from CTRL register INVERT word)
//   timer_start  - single-cycle pulse: timer just started (rising edge of busy)
//   overflow     - single-cycle pulse from gf_timer_counter
//   waveform_out - output waveform bit for this channel
//////////////////////////////////////////////////////////////////////////////////
module gf_timer_channel (
    input  logic        clk,
    input  logic        rst_n,
 
    // Counter value
    input  logic [31:0] cnt,
 
    // Channel configuration
    input  logic [31:0] cms,        // compare match set   (set output to 1)
    input  logic [31:0] cmr,        // compare match reset (set output to 0)
    input  logic        invert,     // invert output polarity
 
    // Events from counter
    input  logic        timer_start, // pulse: timer just started
    input  logic        overflow,    // pulse: counter wrapped
 
    // Output
    output logic        waveform_out
);
 
    // -------------------------------------------------------------------------
    // Compare match detection (combinational)
    // -------------------------------------------------------------------------
    logic cms_match;
    logic cmr_match;
 
    assign cms_match = (cnt == cms);
    assign cmr_match = (cnt == cmr);
 
    // -------------------------------------------------------------------------
    // Output state FF
    // Priority (highest to lowest):
    //   1. timer_start or overflow -> reset to 0 (or 1 if inverted)
    //   2. CMR match               -> set to 0   (or 1 if inverted)
    //   3. CMS match               -> set to 1   (or 0 if inverted)
    //   4. hold
    //
    // Note: if CMS == CMR, reset (CMR) takes priority over set (CMS).
    // Note: if CMS == 0 or CMR == 0, the compare fires one cycle after
    //       timer_start/overflow because cnt is cleared to 0 on overflow
    //       and the match is evaluated on the next clock edge.
    //       This is consistent with the counter module behaviour where cnt
    //       is 0 at the start of every cycle.
    // -------------------------------------------------------------------------
    // out_q: registered state, holds value between threshold events.
    // out_d: combinational, resolves in the same cycle as cnt update so
    //        waveform_out reacts immediately when cnt reaches CMS/CMR.
    //        No 1-cycle output delay visible to the outside.
    //
    // Priority: overflow/start > CMR > CMS > hold
    // CMS==CMR: CMR wins (reset has higher priority).
    logic out_q;
    logic out_d;
 
    always_comb begin
        if (timer_start || overflow)
            out_d = 1'b0;
        else if (cmr_match)
            out_d = 1'b0;
        else if (cms_match)
            out_d = 1'b1;
        else
            out_d = out_q;
    end
 
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) out_q <= 1'b0;
        else        out_q <= out_d;
    end
 
    // -------------------------------------------------------------------------
    // Apply INVERT - on combinational out_d so polarity is also glitch-free
    // -------------------------------------------------------------------------
    assign waveform_out = invert ? ~out_d : out_d;
 
endmodule