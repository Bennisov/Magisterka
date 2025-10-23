//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
//Date        : Thu Oct 23 19:46:51 2025
//Host        : LAPTOP-H5N3SV97 running 64-bit major release  (build 9200)
//Command     : generate_target RegSRx8_veri_wrapper.bd
//Design      : RegSRx8_veri_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module RegSRx8_veri_wrapper
   (aclk,
    aresetn,
    resetuj,
    setuj,
    slv_regs);
  input aclk;
  input aresetn;
  input [255:0]resetuj;
  input [255:0]setuj;
  output [255:0]slv_regs;

  wire aclk;
  wire aresetn;
  wire [255:0]resetuj;
  wire [255:0]setuj;
  wire [255:0]slv_regs;

  RegSRx8_veri RegSRx8_veri_i
       (.aclk(aclk),
        .aresetn(aresetn),
        .resetuj(resetuj),
        .setuj(setuj),
        .slv_regs(slv_regs));
endmodule
