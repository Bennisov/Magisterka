//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.1 (lin64) Build 6140274 Wed May 21 22:58:25 MDT 2025
//Date        : Fri Oct  3 16:03:48 2025
//Host        : lumifun running 64-bit Debian GNU/Linux 12 (bookworm)
//Command     : generate_target axi_register_verification_wrapper.bd
//Design      : axi_register_verification_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module axi_register_verification_wrapper
   (aclk,
    aresetn);
  input aclk;
  input aresetn;

  wire aclk;
  wire aresetn;

  axi_register_verification axi_register_verification_i
       (.aclk(aclk),
        .aresetn(aresetn));
endmodule
