`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.09.2025 17:22:28
// Design Name: 
// Module Name: Bitv2
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


module Bitv2(
    input logic data,
    input logic write_enable,
    input logic reset,
    input logic clk,
    output logic out,
    input logic global_reset
    );
    always_ff @(posedge clk) begin
        if (global_reset)
            out <= 0;
        else if (reset)
            out <= 0;
        else if (write_enable && data)
            out <= 1;
    end
endmodule
