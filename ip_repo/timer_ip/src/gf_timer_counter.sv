`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: gf_timer_counter
// Description: Lowest-level counter core for GF timer.
//              Handles: 32b up-counter, overflow detection, cycle counting (TMODE 1),
//              automatic stop, and BUSY status.
//              Does NOT handle: enable source selection (EMODE), output compare/waveform.
//
// Ports:
//   clk          - system clock
//   rst_n        - active-low async reset
//   effective_ena- combined enable signal (already resolved by upper layer per EMODE)
//   tmode        - 0: continuous, 1: NCYCLES limited
//   ncycles      - number of cycles to execute in TMODE 1 (0 = stop immediately)
//   ovf_val      - overflow (period) value; counter counts 0 .. ovf_val, then wraps
//   cnt          - current counter value (output)
//   overflow     - single-cycle pulse on overflow event
//   busy         - timer is actively running
//   ena_clear    - single-cycle pulse: request upper layer to clear ENA bit
//                  (asserted when TMODE 1 finishes NCYCLES cycles)
//////////////////////////////////////////////////////////////////////////////////
module gf_timer_counter (
    input  logic        clk,
    input  logic        rst_n,

    // Resolved enable (from EMODE mux in upper layer)
    input  logic        effective_ena,

    // Timer configuration
    input  logic        tmode,          // 0 = continuous, 1 = NCYCLES
    input  logic [15:0] ncycles,        // cycle count for TMODE 1
    input  logic [31:0] ovf_val,        // overflow / period value

    // Outputs
    output logic [31:0] cnt,            // current counter value
    output logic        overflow,       // 1-cycle pulse at counter wrap
    output logic        busy,           // timer is running
    output logic        ena_clear       // request to clear ENA bit in CTRL register
);

    // -------------------------------------------------------------------------
    // Internal signals
    // -------------------------------------------------------------------------
    logic [15:0] cycle_cnt;             // number of completed cycles (TMODE 1)
    logic        running;               // internal run state (latched)
    logic        last_cycle;            // currently executing the last allowed cycle
    logic        cnt_at_ovf;           // combinational: counter has reached overflow value
    logic        stop_after_ovf;        // should stop after this overflow

    // -------------------------------------------------------------------------
    // cnt_at_ovf: counter reached overflow value
    // -------------------------------------------------------------------------
    assign cnt_at_ovf = (cnt == ovf_val);

    // -------------------------------------------------------------------------
    // Determine if this overflow is the final one (TMODE 1 only)
    // -------------------------------------------------------------------------
    // In TMODE 1: stop when cycle_cnt + 1 == ncycles (0-based counting)
    // Note: ncycles == 0 is handled at start - timer stops immediately without
    //       ever entering the running state (see running FF below).
    assign stop_after_ovf = tmode & (cycle_cnt == (ncycles - 16'd1));

    // -------------------------------------------------------------------------
    // overflow: single-cycle pulse
    // -------------------------------------------------------------------------
    assign overflow = running & cnt_at_ovf;

    // -------------------------------------------------------------------------
    // ena_clear: pulse to upper layer to clear ENA/AENA when TMODE 1 finishes
    // -------------------------------------------------------------------------
    assign ena_clear = overflow & stop_after_ovf;

    // -------------------------------------------------------------------------
    // running FF
    // Rules per spec:
    //   TMODE 0: run while effective_ena; if ENA drops mid-cycle, finish cycle first
    //            => stay running until the overflow that follows ENA de-assertion
    //   TMODE 1: run until NCYCLES overflows; stop earlier if effective_ena drops
    //            (also finish current cycle then stop per spec)
    //   TMODE 1, ncycles == 0: stop immediately without any cycle
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            running <= 1'b0;
        end else begin
            if (!running) begin
                // Start condition: effective_ena asserted AND (tmode==1 => ncycles > 0)
                if (effective_ena && !(tmode && (ncycles == 16'd0)))
                    running <= 1'b1;
            end else begin
                // Stop condition: overflow event AND one of:
                //   a) TMODE 0: ENA was already de-asserted (finish-cycle behaviour)
                //   b) TMODE 1: final cycle completed  OR  ENA de-asserted (finish cycle)
                if (overflow) begin
                    if (tmode) begin
                        // TMODE 1: stop on last cycle OR if ena was removed
                        if (stop_after_ovf || !effective_ena)
                            running <= 1'b0;
                    end else begin
                        // TMODE 0: stop only if ena no longer asserted
                        if (!effective_ena)
                            running <= 1'b0;
                    end
                end
            end
        end
    end

    // -------------------------------------------------------------------------
    // Counter FF
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 32'd0;
        end else begin
            if (!running) begin
                cnt <= 32'd0;       // hold at 0 while stopped
            end else if (cnt_at_ovf) begin
                cnt <= 32'd0;       // wrap on overflow
            end else begin
                cnt <= cnt + 32'd1;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Cycle counter FF (TMODE 1 only)
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycle_cnt <= 16'd0;
        end else begin
            if (!running) begin
                cycle_cnt <= 16'd0;     // reset when stopped
            end else if (overflow) begin
                if (stop_after_ovf || !effective_ena)
                    cycle_cnt <= 16'd0; // reset on final cycle too
                else
                    cycle_cnt <= cycle_cnt + 16'd1;
            end
        end
    end

    // -------------------------------------------------------------------------
    // busy = running (mirrors internal state, combinationally)
    // Per spec: BUSY reflects whether timer is truly working, not ENA directly.
    // -------------------------------------------------------------------------
    assign busy = running;

endmodule

