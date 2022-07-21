`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/21/2022 07:41:57 PM
// Design Name: 
// Module Name: SpecialCaseDetector
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


module SpecialCaseDetector #(
    parameter PARM_XLEN     = 32,
    parameter PARM_EXP      = 8,
    parameter PARM_MANT     = 23,
    parameter PARM_EXP_ONE  = 8'h01
) (
    input [PARM_XLEN - 1 : 0] A_i,
    input [PARM_XLEN - 1 : 0] B_i,
    input [PARM_XLEN - 1 : 0] C_i,
    
    output A_Inf_o,
    output A_Zero_o,
    output A_NaN_o,
    output A_DeN_o,
    output B_Inf_o,
    output B_Zero_o,
    output B_NaN_o,
    output B_DeN_o,
    output C_Inf_o,
    output C_Zero_o,
    output C_NaN_o,
    output C_DeN_o);

    wire A_Leadingbit = A_i[PARM_XLEN - 2 : PARM_MANT]; //leading 1, if not exp field == 0
    wire B_Leadingbit = B_i[PARM_XLEN - 2 : PARM_MANT];
    wire C_Leadingbit = C_i[PARM_XLEN - 2 : PARM_MANT];

    wire A_Sign = A_i[PARM_XLEN - 1];
    wire B_Sign = B_i[PARM_XLEN - 1];
    wire C_Sign = C_i[PARM_XLEN - 1];
    wire [PARM_EXP - 1: 0] A_Exp = A_DeN_o? PARM_EXP_ONE : A_i[PARM_XLEN - 2 : PARM_MANT];
    wire [PARM_EXP - 1: 0] B_Exp = B_DeN_o? PARM_EXP_ONE : B_i[PARM_XLEN - 2 : PARM_MANT];
    wire [PARM_EXP - 1: 0] C_Exp = C_DeN_o? PARM_EXP_ONE : B_i[PARM_XLEN - 2 : PARM_MANT];
    wire [PARM_MANT : 0] A_Mant;
    wire [PARM_MANT : 0] B_Mant;
    wire [PARM_MANT : 0] C_Mant;




    
endmodule