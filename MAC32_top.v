`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/21/2022 03:34:32 PM
// Design Name: 
// Module Name: MAC32_top
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

//Floating-point control and status register:
//  |31     8|7                     5|4                            0|
//  |reserved|  Rounding Mode (frm)  |  Accured Exceptions(fflags)  |
//                                          NV  DZ  OF  UF  NX

//Rounding mode encoding:
//  Rounding Mode|    Mnemonic    |   Meaning
//---------------------------------------------------------------------------------------------
//       000     |    RNE         |   Round to Nearest, ties to Even
//       001     |    RTZ         |   Round towards Zero
//       010     |    RDN         |   Round Down    (towards -INFINITY)
//       011     |    RUP         |   Round UP      (towards +INFINITY)
//       100     |    RMM         |   Round to Nearest, ties Max Magnitude
//       101     |    ---         |   Invalid. Reserved for future use
//       110     |    ---         |   Invalid. Reserved for future use
//       111     |    DYN         |   In instruction's rm field, selects dynamic rounding mode;
//                                    In Rounding Mode register, Invalid

//Accrued exception flag encoding:
//  Flag Mnemonic   |   Flag Meaning
//----------------------------------------
//      NV          |   Invalid Operation
//      DZ          |   Divide by Zero
//      OF          |   Overflow
//      UF          |   Underflow
//      NX          |   Inexact

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

module MAC32_top #(
   parameter PARM_RM            = 3,
   parameter PARM_XLEN          = 32
) (
    //input clk_i,
    //input rst_i,
    //input stall_i,
    //input req_i,

    //input [PARM_RM - 1 : 0] rounding_mode_i,


    input [PARM_XLEN - 1 : 0] A_i,
    input [PARM_XLEN - 1 : 0] B_i,
    input [PARM_XLEN - 1 : 0] C_i,

    // T (result_o) = A + (B * C)
    output reg [PARM_XLEN - 1 : 0] result_o,
    //output ready_o,
    
    //Accrued exceptions (fflags)
    output reg NV_o,
    //output reg DZ_o,  //would not occur in Multiplication or Addition
    output reg OF_o,
    output reg UF_o,
    output reg NX_o
);

    parameter PARM_RM_RNE       = 3'd0;
    parameter PARM_RM_RTZ       = 3'd1;
    parameter PARM_RM_RDN       = 3'd2;
    parameter PARM_RM_RUP       = 3'd3;
    parameter PARM_PC            = 5; //?
    parameter PARM_EXP          = 8;
    parameter PARM_MANT         = 23;
    parameter PARM_MANT_PRENORM  = 24; //?
    parameter PARM_BIAS         = 127;
    parameter PARM_HALF_BIAS     = 63;
    parameter PARM_LEADONE_WIDTH = 7; //?
    parameter PARM_EXP_ZERO     = 8'h00;
    parameter PARM_EXP_ONE      = 8'h01; //used in this
    parameter PARM_EXP_INF      = 8'hff; //used in SpecialCaseDetector
    parameter PARM_MANT_NAN     = 23'b100_0000_0000_0000_0000_0000; //RISC-V defines canonical NaN to be 0x7fc0_0000
    parameter PARM_MANT_ZERO    = 23'd0; //used in SpecialCaseDetector


    //inputs wires of specialCaseDetectors
    wire A_Leadingbit = | A_i[PARM_XLEN - 2 : PARM_MANT]; //normalized number has leading 1, denormalized with leading 0
    wire B_Leadingbit = | B_i[PARM_XLEN - 2 : PARM_MANT];
    wire C_Leadingbit = | C_i[PARM_XLEN - 2 : PARM_MANT];
    //outputs wires of specialCaseDetectors
    wire A_Inf, B_Inf, C_Inf;
    wire A_Zero, B_Zero, C_Zero;
    wire A_NaN, B_NaN, C_NaN;
    wire A_DeN, B_DeN, C_DeN;

    
    SpecialCaseDetector specialCaseDetector(
        .A_i(A_i),
        .B_i(B_i),
        .C_i(C_i),
        .A_Leadingbit(A_Leadingbit),
        .B_Leadingbit(B_Leadingbit),
        .C_Leadingbit(C_Leadingbit),
        .A_Inf_o(A_Inf),
        .B_Inf_o(B_Inf),
        .C_Inf_o(C_Inf),
        .A_Zero_o(A_Zero),
        .B_Zero_o(B_Zero),
        .C_Zero_o(C_Zero),
        .A_NaN_o(A_NaN),
        .B_NaN_o(B_NaN),
        .C_NaN_o(C_NaN),
        .A_DeN_o(A_DeN),
        .B_DeN_o(B_DeN),
        .C_DeN_o(C_DeN)
    );


    wire A_Sign = A_i[PARM_XLEN - 1];
    wire B_Sign = B_i[PARM_XLEN - 1];
    wire C_Sign = C_i[PARM_XLEN - 1];
    wire Sub_Sign = A_Sign ^ B_Sign ^ C_Sign; // indicator of effective subtraction

    //denormalized number has exponent 1 
    wire [PARM_EXP - 1: 0] A_Exp = A_DeN? PARM_EXP_ONE : A_i[PARM_XLEN - 2 : PARM_MANT];
    wire [PARM_EXP - 1: 0] B_Exp = B_DeN? PARM_EXP_ONE : B_i[PARM_XLEN - 2 : PARM_MANT];
    wire [PARM_EXP - 1: 0] C_Exp = C_DeN? PARM_EXP_ONE : B_i[PARM_XLEN - 2 : PARM_MANT];
    
    wire [PARM_MANT : 0] A_Mant = {A_Leadingbit, A_i[PARM_MANT - 1 : 0]};
    wire [PARM_MANT : 0] B_Mant = {B_Leadingbit, B_i[PARM_MANT - 1 : 0]};
    wire [PARM_MANT : 0] C_Mant = {C_Leadingbit, C_i[PARM_MANT - 1 : 0]};

    //Generate 13 Partial Product by Radix-4 Booth's Algorithm
    wire [2*PARM_MANT + 2 : 0] booth_PP [13 - 1: 0];
    
    R4Booth R4Booth(
        .MantA_i(B_Mant),
        .MantB_i(C_Mant),
        
        .pp_00_o(booth_PP[ 0]),
        .pp_01_o(booth_PP[ 1]),
        .pp_02_o(booth_PP[ 2]),
        .pp_03_o(booth_PP[ 3]),
        .pp_04_o(booth_PP[ 4]),
        .pp_05_o(booth_PP[ 5]),
        .pp_06_o(booth_PP[ 6]),
        .pp_07_o(booth_PP[ 7]),
        .pp_08_o(booth_PP[ 8]),
        .pp_09_o(booth_PP[ 9]),
        .pp_10_o(booth_PP[10]),
        .pp_11_o(booth_PP[11]),
        .pp_12_o(booth_PP[12])
    );

    //Sum 13 partial Product by Wallace Tree
    wire [2*PARM_MANT + 2 : 0] Wallace_sum;
    wire [2*PARM_MANT + 2 : 0] Wallace_carry;
    wire Wallace_msb_cor;

    WallaceTree wallaceTree(
        .pp_00_i(booth_PP[ 0]),
        .pp_01_i(booth_PP[ 1]),
        .pp_02_i(booth_PP[ 2]),
        .pp_03_i(booth_PP[ 3]),
        .pp_04_i(booth_PP[ 4]),
        .pp_05_i(booth_PP[ 5]),
        .pp_06_i(booth_PP[ 6]),
        .pp_07_i(booth_PP[ 7]),
        .pp_08_i(booth_PP[ 8]),
        .pp_09_i(booth_PP[ 9]),
        .pp_10_i(booth_PP[10]),
        .pp_11_i(booth_PP[11]),
        .pp_12_i(booth_PP[12]),
        
        .wallace_sum_o(Wallace_sum),
        .wallace_carry_o(Wallace_carry),
        .suppression_sign_extension_o(Wallace_msb_cor)
    );

    //Prenormalization of the augend, in parallel with multiplication.
    wire [74 : 0] A_Mant_aligned;
    wire signed [PARM_EXP + 1 : 0] Exp_aligned;
    wire [2*PARM_MANT + 2 : 0] Wallace_sum_aligned;
    wire [2*PARM_MANT + 2 : 0] Wallace_carry_aligned;
    wire [PARM_EXP + 1 : 0] Exp_mv_neg;
    wire Mant_sticky_sht_out;
    wire sign_change_unknown = 1;
    //global signals ...
    wire Sign_aligned;
    wire Exp_mv_sign;
    wire Mv_halt;
    
    Aligner aligner(
        .A_sign_i(A_Sign),
        .B_sign_i(B_Sign),
        .C_sign_i(C_Sign),
        .Sub_Sign_i(Sub_Sign),
        .A_Exp_i(A_Exp),
        .B_Exp_i(B_Exp),
        .C_Exp_i(C_Exp),
        .A_Mant_i(A_Mant),
        .Wallace_sum_i(Wallace_sum),
        .Wallace_carry_i(Wallace_carry),
        .sign_change_i(sign_change_unknown), //this is currently not complete......

        .A_Mant_aligned_o(A_Mant_aligned),
        .Exp_aligned_o(Exp_aligned),
        .Sign_aligned_o(Sign_aligned),

        .Exp_mv_sign_o(Exp_mv_sign), //done, Sign_amt_DO
        .Mv_halt_o(Mv_halt), //, Sft_stop_SO

        .Wallace_sum_aligned_o(Wallace_sum_aligned),
        .Wallace_carry_aligned_o(Wallace_carry_aligned),
        .Exp_mv_neg_o(Exp_mv_neg), //done ,Minus_sft_amt_DO
        .Mant_sticky_sht_out_o(Mant_sticky_sht_out)
    );





endmodule