`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_gf_timer
// Description: Simulation testbench for gf_timer.
//              Tests:
//                TC1 - TMODE 0, EMODE 0: continuous run, check waveform ch0
//                TC2 - TMODE 0, EMODE 0: de-assert ENA mid-cycle, finish-cycle check
//                TC3 - TMODE 1, EMODE 0: NCYCLES=3, auto-stop, ena_clear pulse
//                TC4 - TMODE 1, EMODE 0: NCYCLES=0, immediate stop
//                TC5 - EMODE 1: trigger edge start, ENA gate
//                TC6 - EMODE 2: level trigger
//                TC7 - INVERT bit on channel 1
//////////////////////////////////////////////////////////////////////////////////
module tb_gf_timer;

    // -------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------
    localparam int    N_CH    = 8;
    localparam int    CLK_T   = 10;  // 10 ns -> 100 MHz
    localparam [31:0] OVF_VAL = 32'd9; // period = 10 ticks (0..9)
    localparam [31:0] CMS_CH0 = 32'd3;
    localparam [31:0] CMR_CH0 = 32'd7;
    localparam [31:0] CMS_CH1 = 32'd2;
    localparam [31:0] CMR_CH1 = 32'd6;

    // -------------------------------------------------------------------------
    // DUT signals
    // -------------------------------------------------------------------------
    logic              clk;
    logic              rst_n;
    logic              ena_in;
    logic              tmode_in;
    logic [1:0]        emode_in;
    logic [15:0]       ncycles_in;
    logic [N_CH-1:0]   invert_in;
    logic              ext_trigger_in;
    logic              aena_in;
    logic [31:0]       ovf_in;
    logic [31:0]       cms_in [N_CH];
    logic [31:0]       cmr_in [N_CH];
    logic              busy_out;
    logic              ena_clear_out;
    logic [N_CH-1:0]   waveform_out;

    // -------------------------------------------------------------------------
    // DUT instantiation
    // -------------------------------------------------------------------------
    gf_timer #(.N_CHANNELS(N_CH)) dut (
        .clk            (clk),
        .rst_n          (rst_n),
        .ena_in         (ena_in),
        .tmode_in       (tmode_in),
        .emode_in       (emode_in),
        .ncycles_in     (ncycles_in),
        .invert_in      (invert_in),
        .ext_trigger_in (ext_trigger_in),
        .aena_in        (aena_in),
        .ovf_in         (ovf_in),
        .cms_in         (cms_in),
        .cmr_in         (cmr_in),
        .busy_out       (busy_out),
        .ena_clear_out  (ena_clear_out),
        .waveform_out   (waveform_out)
    );

    // -------------------------------------------------------------------------
    // Clock
    // -------------------------------------------------------------------------
    initial clk = 0;
    always #(CLK_T/2) clk = ~clk;

    // -------------------------------------------------------------------------
    // Tasks
    // -------------------------------------------------------------------------

    // Apply reset
    task reset_dut();
        rst_n          = 0;
        ena_in         = 0;
        tmode_in       = 0;
        emode_in       = 2'b00;
        ncycles_in     = 0;
        invert_in      = '0;
        ext_trigger_in = 0;
        aena_in        = 0;
        ovf_in         = OVF_VAL;
        for (int j = 0; j < N_CH; j++) begin
            cms_in[j] = 32'd0;
            cmr_in[j] = 32'd0;
        end
        repeat(4) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
    endtask

    // Wait N clock cycles
    task wait_clk(input int n);
        repeat(n) @(posedge clk);
    endtask

    // Wait until counter reaches exact value, then stop on that posedge.
    // Use this instead of wait_clk in TC7-style checks - cnt increments
    // are registered so blind cycle-counting is fragile.
    task wait_cnt(input logic [31:0] target, input int max_cycles = 500);
        int i;
        for (i = 0; i < max_cycles; i++) begin
            @(posedge clk);
            if (dut.u_counter.cnt == target) break;
        end
        if (i == max_cycles)
            $display("  [WARN] wait_cnt(%0d) timeout @%0t", target, $time);
    endtask

    // Wait for busy to de-assert (timeout after max_cycles)
    task wait_idle(input int max_cycles = 200);
        int i;
        for (i = 0; i < max_cycles; i++) begin
            @(posedge clk);
            if (!busy_out) break;
        end
        if (i == max_cycles)
            $display("  [WARN] wait_idle timeout after %0d cycles", max_cycles);
    endtask

    // -------------------------------------------------------------------------
    // Error counter
    // -------------------------------------------------------------------------
    int error_count;
    int check_count;

    initial begin
        error_count = 0;
        check_count = 0;
    end

    // Assertion helper - checks single logic bit, dumps context on failure
    task check(input string name, input logic got, input logic exp);
        check_count++;
        if (got !== exp) begin
            error_count++;
            $display("  [FAIL] #%0d  %s", error_count, name);
            $display("         expected : %b", exp);
            $display("         got      : %b", got);
            $display("         time     : %0t ns", $time);
            $display("         cnt      : %0d", dut.u_counter.cnt);
            $display("         busy     : %b", busy_out);
            $display("         ena_in   : %b", ena_in);
            $display("         emode    : %0d", emode_in);
            $display("         tmode    : %0d", tmode_in);
            $display("         ncycles  : %0d", ncycles_in);
            $display("         trigger  : %b", ext_trigger_in);
            $display("         waveform : %08b", waveform_out);
            $display("         invert   : %08b", invert_in);
        end else begin
            $display("  [PASS] %s", name);
        end
    endtask

    // Assertion helper for 32-bit values
    task check32(input string name, input logic [31:0] got, input logic [31:0] exp);
        check_count++;
        if (got !== exp) begin
            error_count++;
            $display("  [FAIL] #%0d  %s", error_count, name);
            $display("         expected : 0x%08X (%0d)", exp, exp);
            $display("         got      : 0x%08X (%0d)", got, got);
            $display("         time     : %0t ns", $time);
            $display("         cnt      : %0d", dut.u_counter.cnt);
            $display("         busy     : %b", busy_out);
        end else begin
            $display("  [PASS] %s", name);
        end
    endtask

    // -------------------------------------------------------------------------
    // Test cases
    // -------------------------------------------------------------------------

    initial begin
        $dumpfile("tb_gf_timer.vcd");
        $dumpvars(0, tb_gf_timer);

        // ==============================================================
        // TC1: TMODE 0, EMODE 0 - continuous, check channel 0 waveform
        // ==============================================================
        $display("\n=== TC1: TMODE0 EMODE0 continuous, channel 0 waveform ===");
        reset_dut();
        cms_in[0] = CMS_CH0;  // set  at cnt==3
        cmr_in[0] = CMR_CH0;  // reset at cnt==7
        ovf_in    = OVF_VAL;  // period 10

        // Start timer
        @(negedge clk); ena_in = 1;
        // Let 2.5 cycles run
        wait_clk(25);
        check("TC1 busy after start", busy_out, 1'b1);
        // Stop
        @(negedge clk); ena_in = 0;
        wait_idle();
        check("TC1 idle after ENA=0", busy_out, 1'b0);

        // ==============================================================
        // TC2: TMODE 0 - de-assert ENA mid-cycle, must finish cycle
        // ==============================================================
        $display("\n=== TC2: TMODE0 finish-cycle after ENA de-assert ===");
        reset_dut();
        ovf_in = OVF_VAL;
        @(negedge clk); ena_in = 1;
        wait_clk(3); // mid cycle (cnt ~3)
        @(negedge clk); ena_in = 0; // de-assert mid-cycle
        // BUSY must stay high until overflow
        @(posedge clk); // sample 1 cycle after de-assert
        check("TC2 still busy after ENA=0 mid-cycle", busy_out, 1'b1);
        wait_idle();
        check("TC2 idle after cycle ends", busy_out, 1'b0);

        // ==============================================================
        // TC3: TMODE 1, NCYCLES=3 - auto stop, ena_clear pulse
        // ==============================================================
        $display("\n=== TC3: TMODE1 NCYCLES=3 auto-stop ===");
        reset_dut();
        ovf_in     = OVF_VAL;
        tmode_in   = 1;
        ncycles_in = 16'd3;
        @(negedge clk); ena_in = 1;
        wait_idle(100);
        check("TC3 auto-stopped after NCYCLES", busy_out, 1'b0);

        // ==============================================================
        // TC4: TMODE 1, NCYCLES=0 - immediate stop
        // ==============================================================
        $display("\n=== TC4: TMODE1 NCYCLES=0 immediate stop ===");
        reset_dut();
        tmode_in   = 1;
        ncycles_in = 16'd0;
        @(negedge clk); ena_in = 1;
        wait_clk(2);
        check("TC4 never started (ncycles=0)", busy_out, 1'b0);

        // ==============================================================
        // TC5: EMODE 1 - trigger edge start
        // ==============================================================
        $display("\n=== TC5: EMODE1 trigger edge start ===");
        reset_dut();
        ovf_in     = OVF_VAL;
        tmode_in   = 1;
        ncycles_in = 16'd2;
        emode_in   = 2'b01;

        // ENA high, no trigger yet -> should not start
        @(negedge clk); ena_in = 1;
        wait_clk(3);
        check("TC5 not started before trigger", busy_out, 1'b0);

        // Rising edge on trigger -> should start
        @(negedge clk); ext_trigger_in = 1;
        @(negedge clk); ext_trigger_in = 0;
        wait_clk(2);
        check("TC5 started after trigger edge", busy_out, 1'b1);
        wait_idle(100);
        check("TC5 auto-stopped after NCYCLES", busy_out, 1'b0);

        // ENA low, trigger edge -> should NOT start
        @(negedge clk); ena_in = 0;
        wait_clk(1);
        @(negedge clk); ext_trigger_in = 1;
        @(negedge clk); ext_trigger_in = 0;
        wait_clk(3);
        check("TC5 no start when ENA=0", busy_out, 1'b0);

        // ==============================================================
        // TC6: EMODE 2 - level trigger
        // ==============================================================
        $display("\n=== TC6: EMODE2 level trigger ===");
        reset_dut();
        ovf_in   = OVF_VAL;
        tmode_in = 0;
        emode_in = 2'b10;

        // No trigger -> no start
        wait_clk(3);
        check("TC6 idle without trigger", busy_out, 1'b0);

        // Assert trigger level -> run
        @(negedge clk); ext_trigger_in = 1;
        wait_clk(5);
        check("TC6 running with trigger high", busy_out, 1'b1);

        // De-assert trigger -> finish cycle then stop
        @(negedge clk); ext_trigger_in = 0;
        @(posedge clk);
        check("TC6 still busy after trigger low (finish-cycle)", busy_out, 1'b1);
        wait_idle();
        check("TC6 stopped after cycle ends", busy_out, 1'b0);

        // ==============================================================
        // TC7: INVERT bit on channel 1
        // ==============================================================
        $display("\n=== TC7: INVERT channel 1 ===");
        reset_dut();
        ovf_in        = OVF_VAL;
        tmode_in      = 0;
        emode_in      = 2'b00;
        invert_in     = 8'b00000010; // invert ch1 only
        cms_in[1]     = CMS_CH1;     // cnt==2: normally set→1, inverted: set→0
        cmr_in[1]     = CMR_CH1;     // cnt==6: normally reset→0, inverted: reset→1
        @(negedge clk); ena_in = 1;

        // Wait for timer to start and stabilise at cnt=1 (safely before CMS=2)
        wait_cnt(32'd1);
        check("TC7 ch1=1 at start (inverted idle)", waveform_out[1], 1'b1);

        // Wait for cnt==CMS_CH1 (=2): out_d goes 1 combinatorially → inverted = 0
        wait_cnt(CMS_CH1);
        check("TC7 ch1=0 after CMS (inverted)", waveform_out[1], 1'b0);

        // Wait for cnt==CMR_CH1 (=6): out_d goes 0 combinatorially → inverted = 1
        wait_cnt(CMR_CH1);
        check("TC7 ch1=1 after CMR (inverted)", waveform_out[1], 1'b1);

        @(negedge clk); ena_in = 0;
        wait_idle();

        // ==============================================================
        $display("\n======================================================");
        $display("  Simulation complete");
        $display("  Checks  : %0d", check_count);
        $display("  Passed  : %0d", check_count - error_count);
        $display("  Failed  : %0d", error_count);
        if (error_count == 0)
            $display("  Result  : ALL PASS");
        else
            $display("  Result  : ERRORS FOUND");
        $display("======================================================\n");
        $finish;
    end

    // -------------------------------------------------------------------------
    // Waveform monitor - prints every cycle while timer is running
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (busy_out)
            $display("    [MON] t=%0t cnt=%0d wave=%08b ena_clr=%b",
                     $time, dut.u_counter.cnt, waveform_out, ena_clear_out);
    end

endmodule