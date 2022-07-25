`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2022 07:42:31 PM
// Design Name: 
// Module Name: Aligner
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

module Aligner #(
    parameter PARM_EXP  = 8,
    parameter PARM_MANT = 23,
    parameter PARM_BIAS = 127
) (
    input A_sign_i,
    input B_sign_i,
    input C_sign_i,
    input [PARM_EXP - 1 : 0] A_Exp_i,
    input [PARM_EXP - 1 : 0] B_Exp_i,
    input [PARM_EXP - 1 : 0] C_Exp_i,
    input [PARM_MANT : 0] A_Mant_i,
    input [2*PARM_MANT + 2 : 0] Wallace_sum_i,
    input [2*PARM_MANT + 2 : 0] Wallace_carry_i,
    input sign_change_i,//this is unknown,

    output Sub_o,
    output [74 : 0] A_Mant_aligned_o,
    output [PARM_EXP + 1: 0] Exp_aligned_o,
    output Sign_aligned_o,

    output Exp_mv_sign_o, //done, Sign_amt_DO
    output Mv_halt_o, //, Sft_stop_SO

    output [2*PARM_MANT + 2 : 0] PP_sum_postcal_o,
    output [2*PARM_MANT + 2 : 0] PP_carry_postcal_o,
    output [PARM_EXP + 1 : 0] Exp_mv_neg, //done ,Minus_sft_amt_DO
    output Mant_sticky_sht_out_o);
    
    wire [PARM_EXP + 1 : 0] Exp_d;
    wire [PARM_EXP + 1 : 0] Exp_mv;

    assign Sub_o = A_sign_i ^ B_sign_i ^ C_sign_i;
    
    assign Exp_d = A_Exp_i - B_Exp_i - C_Exp_i + PARM_BIAS; // d = expA - (expB + expC - 127)
    assign Exp_mv = 27 - A_Exp_i + B_Exp_i + C_Exp_i - PARM_BIAS; // mv = 27 - d 
    assign Exp_mv_neg = -27 + A_Exp_i - B_Exp_i - C_Exp_i + PARM_BIAS;
    assign Exp_mv_sign_o = Exp_mv[PARM_EXP + 1]; // the sign bit of the mv parameter

    assign Mv_halt_o = (~Exp_mv_sign_o) && (Exp_mv[PARM_EXP : 0] > 73) //right shift is out of range, which is 74 or more
    



endmodule
