//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
//Date        : Wed Jun  3 01:28:55 2026
//Host        : LAPTOP-H5N3SV97 running 64-bit major release  (build 9200)
//Command     : generate_target GFCore_Zynq_wrapper.bd
//Design      : GFCore_Zynq_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module GFCore_Zynq_wrapper
   (CLK,
    PMOD_SHIFTER_DIR_12,
    PMOD_SHIFTER_DIR_34,
    PMOD_SHIFTER_DIR_78,
    PMOD_SHIFTER_DIR_910,
    busy_out_0,
    ena_in_0,
    waveform_out_0);
  input CLK;
  output [0:0]PMOD_SHIFTER_DIR_12;
  output [0:0]PMOD_SHIFTER_DIR_34;
  output [0:0]PMOD_SHIFTER_DIR_78;
  output [0:0]PMOD_SHIFTER_DIR_910;
  output busy_out_0;
  input ena_in_0;
  output [5:0]waveform_out_0;

  wire CLK;
  wire [0:0]PMOD_SHIFTER_DIR_12;
  wire [0:0]PMOD_SHIFTER_DIR_34;
  wire [0:0]PMOD_SHIFTER_DIR_78;
  wire [0:0]PMOD_SHIFTER_DIR_910;
  wire busy_out_0;
  wire ena_in_0;
  wire [5:0]waveform_out_0;

  GFCore_Zynq GFCore_Zynq_i
       (.CLK(CLK),
        .PMOD_SHIFTER_DIR_12(PMOD_SHIFTER_DIR_12),
        .PMOD_SHIFTER_DIR_34(PMOD_SHIFTER_DIR_34),
        .PMOD_SHIFTER_DIR_78(PMOD_SHIFTER_DIR_78),
        .PMOD_SHIFTER_DIR_910(PMOD_SHIFTER_DIR_910),
        .busy_out_0(busy_out_0),
        .ena_in_0(ena_in_0),
        .waveform_out_0(waveform_out_0));
endmodule
