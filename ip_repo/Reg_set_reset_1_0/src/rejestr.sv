`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.09.2025 18:09:53
// Design Name: 
// Module Name: rejestr
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


module rejestr(
    input logic [31:0] data,
    input logic write_enable,
    input logic clk,
    input logic [31:0] reset,
    input logic [31:0] set,
    output logic [31:0] out,
    input logic global_reset
    );
    genvar i;
    generate
        for(i=0; i<32; i++) begin : Bit
            Bit single_bit(
            .global_reset(global_reset),
            .data(data[i]),
            .write_enable(write_enable),
            .clk(clk),
            .reset(reset[i]),
            .set(set[i]),
            .out(out[i])
            );
        end
    endgenerate
endmodule
