`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/26/2022 07:51:44 PM
// Design Name: 
// Module Name: GrandAdder
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

module GrandAdder #(
    parameter PARM_EXP  = 8,
    parameter PARM_MANT = 23
) (
   input [2*PARM_MANT + 1 : 0]      CSA_sum_i,  // The sum of the former unit  
   input [2*PARM_MANT + 1 : 0]      CSA_carry_i,  // The carry-out of the former unit
   input                            Sub_SI,
   input [2 : 0]                    Sign_cor_i,//strange name
   input                            Exp_mv_sign_i,
   input                            Mv_halt_i,
   input [PARM_MANT + 3 : 0]        BH_i, //strange name
   input                            Sign_aligned_i,
   input [PARM_EXP + 1 : 0]         Exp_mv_neg_i, 
   
   input                            B_Inf_i,
   input                            C_Inf_i,
   input                            B_Zero_i,
   input                            C_Zero_i, 
   input                            B_NaN_i,
   input                            C_Nan_i,
   

   output [3 * PARM_MANT + 4 : 0]    PosSum_o,
   output                            Sign_o,
   output [3 * PARM_MANT + 4 : 0]    A_LZA_o,
   output [3 * PARM_MANT + 4 : 0]    B_LZA_o,
   output                            Minus_sticky_bit_o,
   output                            Sign_change_o);

//Adjustments to the LSB

wire Carry_postcor = (Exp_mv_sign_i)? 0 : (~(|Sign_cor_i) ^ CSA_carry_i[2*PARM_MANT + 1]);




endmodule