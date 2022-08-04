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
    parameter PARM_XLEN         = 32,
    parameter PARM_EXP          = 8,
    parameter PARM_MANT         = 23

) (
    input [PARM_XLEN - 1 : 0] A_i,
    input [PARM_XLEN - 1 : 0] B_i,
    input [PARM_XLEN - 1 : 0] C_i,
    input A_Leadingbit_i,
    input B_Leadingbit_i,
    input C_Leadingbit_i,
    
    output A_Inf_o,
    output B_Inf_o,
    output C_Inf_o,
    output A_Zero_o,
    output B_Zero_o,
    output C_Zero_o,
    output A_NaN_o,
    output B_NaN_o,
    output C_NaN_o,
    output A_DeN_o,
    output B_DeN_o,
    output C_DeN_o);


    wire [PARM_EXP - 1: 0] PARM_EXP_FULL = {PARM_EXP{1'b1}}; // parameter of exponent full of 1s

    
    wire A_ExpZero = ~A_Leadingbit_i;
    wire B_ExpZero = ~B_Leadingbit_i;
    wire C_ExpZero = ~C_Leadingbit_i;

    wire A_ExpFull = (A_i[PARM_XLEN - 2 : PARM_MANT] == PARM_EXP_FULL);
    wire B_ExpFull = (B_i[PARM_XLEN - 2 : PARM_MANT] == PARM_EXP_FULL);
    wire C_ExpFull = (C_i[PARM_XLEN - 2 : PARM_MANT] == PARM_EXP_FULL);

    wire A_MantZero = (A_i[PARM_MANT - 1 : 0] == 0);
    wire B_MantZero = (B_i[PARM_MANT - 1 : 0] == 0);
    wire C_MantZero = (C_i[PARM_MANT - 1 : 0] == 0);



    assign A_Zero_o = A_ExpZero & A_MantZero;
    assign B_Zero_o = B_ExpZero & B_MantZero;
    assign C_Zero_o = C_ExpZero & C_MantZero;

    assign A_Inf_o = A_ExpFull & A_MantZero;
    assign B_Inf_o = B_ExpFull & B_MantZero;
    assign C_Inf_o = C_ExpFull & C_MantZero;

    assign A_NaN_o = A_ExpFull & (~A_MantZero);
    assign B_NaN_o = B_ExpFull & (~B_MantZero);
    assign C_NaN_o = C_ExpFull & (~C_MantZero);

    assign A_DeN_o  = A_ExpZero & (~A_MantZero);
    assign B_DeN_o  = B_ExpZero & (~B_MantZero);
    assign C_DeN_o  = C_ExpZero & (~C_MantZero);

    
endmodule