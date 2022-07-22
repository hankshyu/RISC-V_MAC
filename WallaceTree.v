`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2022 03:15:31 PM
// Design Name: 
// Module Name: WallaceTree
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


module WallaceTree#(
    parameter PARM_MANT = 23
) (
    input [2*PARM_MANT + 2 : 0] pp_00_i,
    input [2*PARM_MANT + 2 : 0] pp_01_i,
    input [2*PARM_MANT + 2 : 0] pp_02_i,
    input [2*PARM_MANT + 2 : 0] pp_03_i,
    input [2*PARM_MANT + 2 : 0] pp_04_i,
    input [2*PARM_MANT + 2 : 0] pp_05_i,
    input [2*PARM_MANT + 2 : 0] pp_06_i,
    input [2*PARM_MANT + 2 : 0] pp_07_i,
    input [2*PARM_MANT + 2 : 0] pp_08_i,
    input [2*PARM_MANT + 2 : 0] pp_09_i,
    input [2*PARM_MANT + 2 : 0] pp_10_i,
    input [2*PARM_MANT + 2 : 0] pp_11_i,
    input [2*PARM_MANT + 2 : 0] pp_12_i,
    
    output [2*PARM_MANT + 2 : 0] pp_sum_o,
    output [2*PARM_MANT + 2 : 0] pp_carry_o,
    output msb_cor_o
    );



endmodule
