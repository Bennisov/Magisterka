`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.09.2025 17:22:01
// Design Name: 
// Module Name: Rejestrv2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Rejestrv2(
    input logic [31:0] data,
    input logic write_enable,
    input logic clk,
    input logic [31:0] reset,
    output logic [31:0] out,
    input logic global_reset
    );
    genvar i;
    generate
        for(i=0; i<32; i++) begin : Bitv2
            Bitv2 single_bitv2(
            .global_reset(global_reset),
            .data(data[i]),
            .write_enable(write_enable),
            .clk(clk),
            .reset(reset[i]),
            .out(out[i])
            );
        end
    endgenerate
endmodule
