//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
//Date        : Sat Nov  8 18:33:44 2025
//Host        : LAPTOP-H5N3SV97 running 64-bit major release  (build 9200)
//Command     : generate_target Regx32_veri_wrapper.bd
//Design      : Regx32_veri_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module Regx32_veri_wrapper
   (aclk,
    aresetn,
    data_output);
  input aclk;
  input aresetn;
  output [1023:0]data_output;

  wire aclk;
  wire aresetn;
  wire [1023:0]data_output;

  Regx32_veri Regx32_veri_i
       (.aclk(aclk),
        .aresetn(aresetn),
        .data_output(data_output));
endmodule
