`timescale 1ns / 1ps

// Import AXI VIP packages
import axi_vip_pkg::*;
import gf_timer_dual_axi_vip_0_0_pkg::*;

module tb_gf_timer_dual();

    // ----------------------------------------------------------------
    // Clock and reset
    // ----------------------------------------------------------------
    bit clk;
    bit resetn;

    always #5 clk = ~clk;  // 100 MHz

    // ----------------------------------------------------------------
    // DUT - BD wrapper
    // ----------------------------------------------------------------
    bit ena_in_t0 = 1'b0;  // direct ENA pin - drives timer 0 start

    gf_timer_dual_wrapper DUT (
        .aclk           (clk),
        .aresetn        (resetn),
        // timer 0
        .ena_in_0       (ena_in_t0),  // driven by TB to start both timers
        .aena_in_0      (1'b0),       // not used - timer 0 is master
        .ext_trigger_t0 (1'b0),
        .busy_t0        (),
        .waveform_t0    (),
        .aena2_out_0    (),
        .aena3_out_0    (),
        // timer 1
        .ena_in_1       (1'b0),       // started via aena_in (from timer0 aena1_out)
        .ext_trigger_t1 (1'b0),
        .busy_t1        (),
        .waveform_t1    (),
        .aena1_out_1    (),
        .aena2_out_1    (),
        .aena3_out_1    ()
    );

    // ----------------------------------------------------------------
    // AXI VIP master agent
    // ----------------------------------------------------------------
    gf_timer_dual_axi_vip_0_0_mst_t mst_agent;

    // ----------------------------------------------------------------
    // AXI VIP helper signals
    // ----------------------------------------------------------------
    xil_axi_prot_t  prot  = 3'b000;
    xil_axi_resp_t  bresp;
    xil_axi_resp_t  rresp;
    bit [31:0]      rdata;

    // ----------------------------------------------------------------
    // Timer base addresses
    // ----------------------------------------------------------------
    localparam TIMER0_BASE = 32'h0000_0000;
    localparam TIMER1_BASE = 32'h0001_0000;

    // Register offsets
    localparam CTRL   = 32'h00;
    localparam OVF    = 32'h04;
    localparam C0CMS  = 32'h08;
    localparam C0CMR  = 32'h0C;
    localparam C1CMS  = 32'h10;
    localparam C1CMR  = 32'h14;

    // ----------------------------------------------------------------
    // Error counter
    // ----------------------------------------------------------------
    int error_count = 0;
    int check_count = 0;

    // ----------------------------------------------------------------
    // AXI write/read tasks
    // ----------------------------------------------------------------
    task axi_write(input bit [31:0] addr, input bit [31:0] data);
        bit [63:0] wdata;
        wdata = {32'b0, data};
        mst_agent.AXI4LITE_WRITE_BURST(addr, prot, wdata, bresp);
    endtask

    task axi_read(input bit [31:0] addr, output bit [31:0] data);
        bit [63:0] rdata64;
        mst_agent.AXI4LITE_READ_BURST(addr, prot, rdata64, rresp);
        @(posedge clk); // wait one cycle for axi_rdata FF to update
        data = rdata64[31:0];
    endtask

    // ----------------------------------------------------------------
    // Check task
    // ----------------------------------------------------------------
    task check(input string name, input bit [31:0] got, input bit [31:0] exp,
               input bit [31:0] mask = 32'hFFFF_FFFF);
        check_count++;
        if ((got & mask) !== (exp & mask)) begin
            error_count++;
            $display("  [FAIL] #%0d  %s", error_count, name);
            $display("         expected : 0x%08X (masked: 0x%08X)", exp, exp & mask);
            $display("         got      : 0x%08X (masked: 0x%08X)", got, got & mask);
            $display("         time     : %0t ns", $time);
        end else begin
            $display("  [PASS] %s", name);
        end
    endtask

    // ----------------------------------------------------------------
    // Wait for BUSY bit to be set/cleared (timeout protection)
    // ----------------------------------------------------------------
    task wait_busy(input bit [31:0] base, input bit expected_busy,
                   input int timeout_us = 100);
        bit [31:0] ctrl_val;
        int cycles = 0;
        int max_cycles = timeout_us * 100; // 100 cycles per us at 100MHz
        do begin
            @(posedge clk);
            axi_read(base + CTRL, ctrl_val);
            cycles++;
        end while (ctrl_val[1] !== expected_busy && cycles < max_cycles);
        if (cycles >= max_cycles)
            $display("  [WARN] wait_busy timeout after %0d us", timeout_us);
    endtask

    // ----------------------------------------------------------------
    // Main test
    // ----------------------------------------------------------------
    initial begin
        // Init agent
        mst_agent = new("AXI VIP master", 
                        DUT.gf_timer_dual_i.axi_vip_0.inst.IF);
        mst_agent.vif_proxy.set_dummy_drive_type(XIL_AXI_VIF_DRIVE_NONE);
        mst_agent.set_agent_tag("Master VIP");
        mst_agent.set_verbosity(0);
        mst_agent.start_master();

        // Reset sequence - minimum 16 cycles required by AXI VIP (UG1037)
        resetn = 1'b0;
        repeat(20) @(posedge clk);
        resetn = 1'b1;
        repeat(20) @(posedge clk); // extra settling time after reset

        $display("\n================================================================");
        $display(" TEST: Timer 0 ena_in PIN starts both timers simultaneously");
        $display("================================================================\n");

        // ============================================================
        // Step 1: Configure Timer 0
        //   TMODE=1 (NCYCLES), NCYCLES=4, EMODE=0, period=99 ticks
        //   Channel 0: pulse from tick 20 to tick 60
        // ============================================================
        $display("--- Step 1: Configure Timer 0 ---");
        axi_write(TIMER0_BASE + OVF,   32'd99);    // period = 100 ticks
        axi_write(TIMER0_BASE + C0CMS, 32'd20);    // ch0 high at cnt==20
        axi_write(TIMER0_BASE + C0CMR, 32'd60);    // ch0 low  at cnt==60

        // Readback and verify
        axi_read(TIMER0_BASE + OVF,  rdata); check("T0 OVF readback",   rdata, 32'd99);
        axi_read(TIMER0_BASE + C0CMS, rdata); check("T0 C0CMS readback", rdata, 32'd20);
        axi_read(TIMER0_BASE + C0CMR, rdata); check("T0 C0CMR readback", rdata, 32'd60);

        // ============================================================
        // Step 2: Configure Timer 1
        //   TMODE=1 (NCYCLES), NCYCLES=4, EMODE=3 (AENA),
        //   period=99 ticks, channel 1: pulse from tick 30 to tick 70
        // ============================================================
        $display("--- Step 2: Configure Timer 1 ---");
        axi_write(TIMER1_BASE + OVF,   32'd99);
        axi_write(TIMER1_BASE + C1CMS, 32'd30);
        axi_write(TIMER1_BASE + C1CMR, 32'd70);

        // CTRL timer 1: EMODE=3 (bits [4:3]=2'b11), TMODE=1 (bit2), NCYCLES=4
        // [31:16]=NCYCLES=4, [4:3]=EMODE=3, [2]=TMODE=1
        // = 0x0004_001C  (4<<16 | 0b11<<3 | 1<<2 = 0x1C)
        axi_write(TIMER1_BASE + CTRL, 32'h0004_001C);

        axi_read(TIMER1_BASE + OVF,   rdata); check("T1 OVF readback",   rdata, 32'd99);
        axi_read(TIMER1_BASE + C1CMS, rdata); check("T1 C1CMS readback", rdata, 32'd30);
        axi_read(TIMER1_BASE + C1CMR, rdata); check("T1 C1CMR readback", rdata, 32'd70);

        // Verify CTRL written correctly (mask out BUSY bit [1])
        axi_read(TIMER1_BASE + CTRL,  rdata);
        check("T1 CTRL readback (no ENA)", rdata, 32'h0004_001C, 32'hFFFF_FFFD);

        $display("  [DBG] T1 NCYCLES=%0d EMODE=%0d TMODE=%0d", rdata[31:16], rdata[4:3], rdata[2]);
        // ============================================================
        // Step 3: Verify both timers are idle before start
        // ============================================================
        $display("--- Step 3: Verify both timers idle ---");
        axi_read(TIMER0_BASE + CTRL, rdata);
        check("T0 BUSY=0 before start", rdata & 32'h2, 32'h0);
        axi_read(TIMER1_BASE + CTRL, rdata);
        check("T1 BUSY=0 before start", rdata & 32'h2, 32'h0);

        // ============================================================
        // Step 4: Verify idle, then set AENA1 in timer 0 CTRL
        // ============================================================
        $display("--- Step 4: Set AENA1 in timer 0 CTRL (no ENA yet) ---");

        // Check BUSY before writing AENA1
        axi_read(TIMER0_BASE + CTRL, rdata);
        check("T0 BUSY=0 before pin assert", rdata & 32'h2, 32'h0);
        axi_read(TIMER1_BASE + CTRL, rdata);
        check("T1 BUSY=0 before pin assert", rdata & 32'h2, 32'h0);

        // Now write AENA1 - this will immediately start timer 1 via aena1_out
        // CTRL: NCYCLES=4, TMODE=1, AENA1=1 = 0x0004_0024
        axi_write(TIMER0_BASE + CTRL, 32'h0004_0024);
        repeat(3) @(posedge clk);

        // ============================================================
        // Step 5: Assert ena_in_t0 pin - starts timer 0 immediately,
        //         aena1_out goes high → timer 1 starts via EMODE 3
        // ============================================================
        $display("--- Step 5: Assert ena_in pin → both timers start ---");
        @(negedge clk);
        ena_in_t0 = 1'b1;
        repeat(5) @(posedge clk);

        // Verify both timers running
        axi_read(TIMER0_BASE + CTRL, rdata);
        check("T0 BUSY=1 after pin assert", rdata & 32'h2, 32'h2);
        axi_read(TIMER1_BASE + CTRL, rdata);
        check("T1 BUSY=1 after pin assert (AENA)", rdata & 32'h2, 32'h2);

        // De-assert pin (timer 0 in TMODE1 will auto-stop after NCYCLES)
        @(negedge clk);
        ena_in_t0 = 1'b0;

        // ============================================================
        // Step 6: Wait for both timers to finish (NCYCLES=4 x 100 ticks)
        // ============================================================
        $display("--- Step 6: Wait for timers to finish ---");
        repeat(600) @(posedge clk);

        axi_read(TIMER0_BASE + CTRL, rdata);
        check("T0 BUSY=0 after NCYCLES", rdata & 32'h2, 32'h0);
        check("T0 ENA=0 auto-cleared",   rdata & 32'h1, 32'h0);

        axi_read(TIMER1_BASE + CTRL, rdata);
        check("T1 BUSY=0 after NCYCLES", rdata & 32'h2, 32'h0);

        // ============================================================
        // Step 7: Verify AENA1 still set (no auto-clear in this config)
        // ============================================================
        $display("--- Step 7: Verify final state ---");
        axi_read(TIMER0_BASE + CTRL, rdata);
        check("T0 ENA=0 (auto-cleared after NCYCLES)", rdata & 32'h1, 32'h0);
        check("T0 AENA1=1 (not auto-cleared, clear via AXI)", rdata & 32'h20, 32'h20);

        // ============================================================
        // Summary
        // ============================================================
        $display("\n================================================================");
        $display("  Simulation complete");
        $display("  Checks : %0d", check_count);
        $display("  Passed : %0d", check_count - error_count);
        $display("  Failed : %0d", error_count);
        $display("  Result : %s", (error_count == 0) ? "ALL PASS" : "ERRORS FOUND");
        $display("================================================================\n");

        $finish;
    end

    // ----------------------------------------------------------------
    // Monitor -- prints CTRL of both timers every 100 cycles when busy
    // ----------------------------------------------------------------
    bit [31:0] mon_t0, mon_t1;
    int mon_cycle = 0;

    always @(posedge clk) begin
        if (resetn) begin
            mon_cycle++;
            if (mon_cycle % 50 == 0) begin
                // Direct hierarchical access to busy signals for monitoring
                // (doesn't use AXI - just wires for waveform display)
                $display("  [MON] t=%0t  busy_t0=%b  busy_t1=%b  wave_t0=%08b  wave_t1=%08b",
                    $time,
                    DUT.gf_timer_dual_i.gf_timer_0.inst.gf_timer_slave_lite_v1_0_S00_AXI_inst.u_timer_regs.busy_out,
                    DUT.gf_timer_dual_i.gf_timer_1.inst.gf_timer_slave_lite_v1_0_S00_AXI_inst.u_timer_regs.busy_out,
                    DUT.gf_timer_dual_i.gf_timer_0.inst.gf_timer_slave_lite_v1_0_S00_AXI_inst.u_timer_regs.waveform_out,
                    DUT.gf_timer_dual_i.gf_timer_1.inst.gf_timer_slave_lite_v1_0_S00_AXI_inst.u_timer_regs.waveform_out);
            end
        end
    end

endmodule