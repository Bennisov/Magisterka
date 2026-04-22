`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: gf_timer_enable
// Description: Enable source selection for GF timer (EMODE logic).
//
// Resolves the effective_ena signal that is fed into gf_timer_counter.
//
// EMODE 0: effective_ena = ena_in  (ENA bit in CTRL register)
//
// EMODE 1: Timer is started by a rising edge on ext_trigger_in, provided
//          ena_in is asserted at that moment.
//          Once started, timer keeps running as long as ena_in remains high.
//          Timer can also be stopped mid-cycle by de-asserting ena_in
//          (counter will finish current cycle per counter module rules).
//          A new rising edge re-starts the timer only after it has stopped
//          and ena_in is still (or again) asserted.
//
// EMODE 2: effective_ena = ext_trigger_in  (level, replaces ENA entirely)
//
// EMODE 3: effective_ena = aena_in
//          aena_in is driven by AENAx bit in timer 0 CTRL register.
//          For timer 0 itself, EMODE 3 == EMODE 0 (aena_in tied to ena_in above).
//
// Ports:
//   clk            - system clock
//   rst_n          - active-low async reset
//   emode          - EMODE[1:0] from CTRL register
//   ena_in         - ENA bit from CTRL register
//   ext_trigger_in - external trigger input (EMODE 1: edge, EMODE 2: level)
//   aena_in        - atomic enable from timer 0 CTRL (EMODE 3)
//   busy_in        - BUSY from counter (used in EMODE 1 to block re-trigger while running)
//   effective_ena  - resolved enable output → gf_timer_counter
//////////////////////////////////////////////////////////////////////////////////
module gf_timer_enable (
    input  logic       clk,
    input  logic       rst_n,

    // Configuration
    input  logic [1:0] emode,

    // Enable sources
    input  logic       ena_in,          // ENA bit (CTRL register)
    input  logic       ext_trigger_in,  // external trigger
    input  logic       aena_in,         // atomic enable (from timer 0, EMODE 3)

    // Status feedback
    input  logic       busy_in,         // counter is currently running

    // Output
    output logic       effective_ena    // resolved enable → gf_timer_counter
);

    // -------------------------------------------------------------------------
    // Edge detection for ext_trigger_in (used in EMODE 1)
    // Detect rising edge: current high, previous low
    // -------------------------------------------------------------------------
    logic trigger_q;
    logic trigger_rise;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            trigger_q <= 1'b0;
        else
            trigger_q <= ext_trigger_in;
    end

    assign trigger_rise = ext_trigger_in & ~trigger_q;

    // -------------------------------------------------------------------------
    // EMODE 1 latch: set on rising trigger edge (if ena_in high and not busy),
    //                cleared when ena_in is de-asserted or timer stops.
    //
    // The latch models "timer started by trigger, kept alive by ENA":
    //   - Set:   rising edge on trigger AND ena_in==1 AND timer not already running
    //   - Clear: ena_in de-asserted  OR  timer finished (busy drops while latch is set)
    //
    // effective_ena in EMODE 1 = trigger_latch & ena_in
    // (ena_in gate ensures that if ENA drops, counter finishes cycle then stops)
    // -------------------------------------------------------------------------
    logic trigger_latch;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            trigger_latch <= 1'b0;
        end else begin
            if (trigger_latch) begin
                // Clear when ENA is withdrawn or counter has stopped
                if (!ena_in || !busy_in)
                    trigger_latch <= 1'b0;
            end else begin
                // Set on rising trigger edge, only when ENA is asserted and not busy
                if (trigger_rise && ena_in && !busy_in)
                    trigger_latch <= 1'b1;
            end
        end
    end

    // -------------------------------------------------------------------------
    // EMODE mux
    // -------------------------------------------------------------------------
    always_comb begin
        case (emode)
            2'b00: effective_ena = ena_in;
            2'b01: effective_ena = trigger_latch & ena_in;
            2'b10: effective_ena = ext_trigger_in;
            2'b11: effective_ena = aena_in;
            default: effective_ena = 1'b0;
        endcase
    end

endmodule