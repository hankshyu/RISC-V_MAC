`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2022 10:34:02 AM
// Design Name: 
// Module Name: Compressor42
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


module Compressor42 #(
    parameter XLEN = 49
) (
    input [XLEN - 1 : 0] A_i,
    input [XLEN - 1 : 0] B_i,
    input [XLEN - 1 : 0] C_i,
    input [XLEN - 1 : 0] D_i,
    output [XLEN - 1 : 0] Sum_o,
    output [XLEN - 1 : 0] Carry_o
    );
endmodule
