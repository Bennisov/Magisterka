//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
//Date        : Sat May 16 14:05:29 2026
//Host        : LAPTOP-H5N3SV97 running 64-bit major release  (build 9200)
//Command     : generate_target gf_timer_dual_wrapper.bd
//Design      : gf_timer_dual_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module gf_timer_dual_wrapper
   (aclk,
    aena1_out_1,
    aena2_out_0,
    aena2_out_1,
    aena3_out_0,
    aena3_out_1,
    aena_in_0,
    aresetn,
    busy_t0,
    busy_t1,
    ena_in_0,
    ena_in_1,
    ext_trigger_t0,
    ext_trigger_t1,
    waveform_t0,
    waveform_t1);
  input aclk;
  output aena1_out_1;
  output aena2_out_0;
  output aena2_out_1;
  output aena3_out_0;
  output aena3_out_1;
  input aena_in_0;
  input aresetn;
  output busy_t0;
  output busy_t1;
  input ena_in_0;
  input ena_in_1;
  input ext_trigger_t0;
  input ext_trigger_t1;
  output [7:0]waveform_t0;
  output [7:0]waveform_t1;

  wire aclk;
  wire aena1_out_1;
  wire aena2_out_0;
  wire aena2_out_1;
  wire aena3_out_0;
  wire aena3_out_1;
  wire aena_in_0;
  wire aresetn;
  wire busy_t0;
  wire busy_t1;
  wire ena_in_0;
  wire ena_in_1;
  wire ext_trigger_t0;
  wire ext_trigger_t1;
  wire [7:0]waveform_t0;
  wire [7:0]waveform_t1;

  gf_timer_dual gf_timer_dual_i
       (.aclk(aclk),
        .aena1_out_1(aena1_out_1),
        .aena2_out_0(aena2_out_0),
        .aena2_out_1(aena2_out_1),
        .aena3_out_0(aena3_out_0),
        .aena3_out_1(aena3_out_1),
        .aena_in_0(aena_in_0),
        .aresetn(aresetn),
        .busy_t0(busy_t0),
        .busy_t1(busy_t1),
        .ena_in_0(ena_in_0),
        .ena_in_1(ena_in_1),
        .ext_trigger_t0(ext_trigger_t0),
        .ext_trigger_t1(ext_trigger_t1),
        .waveform_t0(waveform_t0),
        .waveform_t1(waveform_t1));
endmodule
