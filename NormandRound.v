`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/30/2022 10:47:12 AM
// Design Name: 
// Module Name: NormandRound
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


module NormandRound #(
    parameter PARM_LEADONE_WIDTH = 7,
    parameter PARM_EXP          = 8,
    parameter PARM_MANT         = 23,
    parameter PARM_RM            = 3,
    parameter PARM_RM_RNE       = 3'b000,
    parameter PARM_RM_RTZ       = 3'b001,
    parameter PARM_RM_RDN       = 3'b010,
    parameter PARM_RM_RUP       = 3'b011,
    parameter PARM_RM_RMM       = 3'b100,
    parameter PARM_MANT_NAN     = 23'b100_0000_0000_0000_0000_0000
) (
    input [3*PARM_MANT + 4 : 0]Mant_i,
    input [PARM_EXP + 1 : 0]Exp_i,
    input Sign_i,

    input [PARM_LEADONE_WIDTH - 1 : 0] Shift_num_i,
    input Allzero_i,
    input Exp_mv_sign_i,

    input Sub_Sign_i,
    input [PARM_EXP - 1 : 0] A_Exp_raw_i,
    input [PARM_MANT : 0] A_Mant_i,
    input A_Sign_i,
    input [PARM_RM - 1 : 0] Rounding_mode_i,

    input A_DeN_i,
    input A_Inf_i,
    input B_Inf_i,
    input C_Inf_i,
    input A_Zero_i,
    input B_Zero_i,
    input C_Zero_i,
    input A_NaN_i,
    input B_NaN_i,
    input c_NaN_i,

    input Mant_sticky_sht_out_i,
    input Minus_sticky_bit_i,

    output Sign_result_o,
    output [PARM_EXP - 1 : 0] Exp_result_o,
    output [PARM_MANT - 1 : 0] Mant_result_o,
    output  Invalid_o,
    output  Overflow_o,
    output  Underflow_o,
    output  Inexact_o 
    );


    
endmodule
