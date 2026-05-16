`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: gf_timer_enable
// Description: Enable source selection for GF timer (EMODE logic).
//
// EMODE 0: effective_ena = ena_in  (level)
// EMODE 1: started by rising edge on ext_trigger_in (if ena_in=1), kept alive by ena_in
// EMODE 2: effective_ena = ext_trigger_in (level)
// EMODE 3: started by rising edge on aena_in, runs until NCYCLES done
//          (same latch pattern as EMODE 1 but for aena_in)
//////////////////////////////////////////////////////////////////////////////////
module gf_timer_enable (
    input  logic       clk,
    input  logic       rst_n,

    input  logic [1:0] emode,
    input  logic       ena_in,
    input  logic       ext_trigger_in,
    input  logic       aena_in,
    input  logic       busy_in,

    output logic       effective_ena
);

    // -------------------------------------------------------------------------
    // Edge detection for ext_trigger_in (EMODE 1)
    // -------------------------------------------------------------------------
    logic trigger_q;
    logic trigger_rise;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) trigger_q <= 1'b0;
        else        trigger_q <= ext_trigger_in;
    end
    assign trigger_rise = ext_trigger_in & ~trigger_q;

    // -------------------------------------------------------------------------
    // EMODE 1 latch - set on trigger rising edge, cleared when done
    // -------------------------------------------------------------------------
    logic trigger_latch;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            trigger_latch <= 1'b0;
        end else begin
            if (trigger_latch) begin
                if (!ena_in || !busy_in)
                    trigger_latch <= 1'b0;
            end else begin
                if (trigger_rise && ena_in && !busy_in)
                    trigger_latch <= 1'b1;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Edge detection for aena_in (EMODE 3)
    // -------------------------------------------------------------------------
    logic aena_q;
    logic aena_rise;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) aena_q <= 1'b0;
        else        aena_q <= aena_in;
    end
    assign aena_rise = aena_in & ~aena_q;

    // -------------------------------------------------------------------------
    // EMODE 3 latch - set on aena_in rising edge, cleared when timer finishes
    // Timer runs for NCYCLES then stops - latch cleared when busy drops
    // -------------------------------------------------------------------------
    logic aena_latch;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            aena_latch <= 1'b0;
        end else begin
            if (aena_latch) begin
                // Clear when timer finishes (busy drops)
                if (!busy_in)
                    aena_latch <= 1'b0;
            end else begin
                // Set on rising edge of aena_in, only when not already running
                if (aena_rise && !busy_in)
                    aena_latch <= 1'b1;
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
            2'b11: effective_ena = aena_latch;
            default: effective_ena = 1'b0;
        endcase
    end

endmodule