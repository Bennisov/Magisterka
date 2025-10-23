`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.09.2025 17:52:13
// Design Name: 
// Module Name: Bit
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


module Bit(
    input logic data,
    input logic write_enable,
    input logic set,
    input logic reset,
    input logic clk,
    output logic out,
    input logic global_reset
    );
    always @(posedge clk)
    begin
    if(global_reset)
        out <= 0;
    else if (reset)
        out <= 0;
    else if (set)
        out <= 1;
    else if (write_enable)
        out <= data;
    end
endmodule
