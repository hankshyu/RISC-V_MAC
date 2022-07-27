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
    wire [PARM_EXP - 1: 0] C_Exp = C_DeN? PARM_EXP_ONE : C_i[PARM_XLEN - 2 : PARM_MANT];
    
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
    wire Wallace_suppression_sign_extension;

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
        .suppression_sign_extension_o(Wallace_suppression_sign_extension)
    );
    
    //Prenormalization of the augend, in parallel with multiplication.
    //global signals ...
    wire Sign_aligned;
    wire Exp_mv_sign;
    wire Mv_halt;

    //Exponent Processor
    wire [PARM_EXP + 1 : 0] Exp_mv = 27 - A_Exp + B_Exp + C_Exp - PARM_BIAS; // d = expA - (expB + expC - 127), mv = 27 - d 
    wire [PARM_EXP + 1 : 0] Exp_mv_neg = -27 + A_Exp - B_Exp - C_Exp + PARM_BIAS; //Minus_sft_amt_DO
    assign Exp_mv_sign = Exp_mv[PARM_EXP + 1]; // the sign bit of the mv parameter, Sign_amt_DO
    assign Mv_halt = (~Exp_mv_sign) & (Exp_mv[PARM_EXP : 0] > 73); //right shift(+) is out of range, which is 74 or more, Sft_stop_SO

    //signals for prenormalizer:
    wire SignFlip_ADD_PRN;
    
    wire [3*PARM_MANT + 5 : 0] A_Mant_aligned;
    wire [PARM_MANT + 3 : 0] A_Mant_aligned_high = A_Mant_aligned[3*PARM_MANT + 5 : 2*PARM_MANT + 2];
    wire [2*PARM_MANT + 1 : 0] A_Mant_aligned_low = A_Mant_aligned[2*PARM_MANT + 1 : 0];
    
    wire signed [PARM_EXP + 1 : 0] Exp_aligned;
    wire Mant_sticky_sht_out;


    PreNormalizer preNormalizer(
        .A_sign_i(A_Sign),
        .B_sign_i(B_Sign),
        .C_sign_i(C_Sign),
        .Sub_Sign_i(Sub_Sign),
        .A_Exp_i(A_Exp),
        .B_Exp_i(B_Exp),
        .C_Exp_i(C_Exp),
        .A_Mant_i(A_Mant),
        .Sign_flip_i(SignFlip_ADD_PRN), //this is currently not complete......
        .Mv_halt_i(Mv_halt),
        .Exp_mv_i(Exp_mv),
        .Exp_mv_sign_i(Exp_mv_sign),

        .A_Mant_aligned_o(A_Mant_aligned),
        .Exp_aligned_o(Exp_aligned),
        .Sign_aligned_o(Sign_aligned),
        .Mant_sticky_sht_out_o(Mant_sticky_sht_out)
    );

    //adjust wallace sum to send in... 
    wire [2*PARM_MANT + 2 : 0] Wallace_sum_adjusted;
    wire [2*PARM_MANT + 2 : 0] Wallace_carry_adjusted;
    
    assign Wallace_sum_adjusted = (Exp_mv_sign)? 0 : Wallace_sum;
    assign Wallace_carry_adjusted = (Exp_mv_sign) ? 0 : Wallace_carry;

    //Sums the Wallace outputs with A_Low
    wire [2*PARM_MANT + 1 : 0] CSA_sum;
    wire [2*PARM_MANT + 1 : 0] CSA_carry;
    
    Compressor32 #(2*PARM_MANT + 2) CarrySaveAdder (
        .A_i(A_Mant_aligned_low), //A_low
        .B_i(Wallace_sum_adjusted[2*PARM_MANT + 1 : 0]),
        .C_i({Wallace_carry_adjusted[2*PARM_MANT : 0], 1'b0}),
        .Sum_o(CSA_sum),
        .Carry_o(CSA_carry)
    );

    //correction based sign extenson is also in grand-adder.
    //input signals

    wire Wallace_adjusted_msb = Wallace_sum_adjusted[2*PARM_MANT + 2] & Wallace_carry_adjusted[2*PARM_MANT + 1];
    wire [2:0] Adder_Correlated_sign = {Wallace_suppression_sign_extension, Wallace_carry_adjusted[2*PARM_MANT + 2] , Wallace_adjusted_msb};
    
    //output signals
    wire [73 : 0] PosSum;
    wire [3*PARM_MANT + 4 : 0] A_LZA;
    wire [3*PARM_MANT + 4 : 0] B_LZA;
    wire Minus_sticky_bit;
    
    wire Adder_sign; //global signal for Sign_out_D

   GrandAdder grandadder (
    .CSA_sum_i(CSA_sum),  
    .CSA_carry_i(CSA_carry),
    .Sub_Sign_i(Sub_Sign),   
    .Adder_Correlated_sign_i(Adder_Correlated_sign),
    
    //signals from exponent processors and prealigner
    .Exp_mv_sign_i(Exp_mv_sign),
    .Mv_halt_i(Mv_halt),
    .Exp_mv_neg_i(Exp_mv_neg), 
    .Sign_aligned_i(Sign_aligned),
   
    .A_Mant_aligned_high(A_Mant_aligned_high), //strange name
   
    .B_Inf_i(B_Inf),
    .C_Inf_i(C_Inf),
    .B_Zero_i(B_Zero),
    .C_Zero_i(C_Zero), 
    .B_NaN_i(B_NaN),
    .C_Nan_i(C_NaN),
   
   .PosSum_o(PosSum),
   .Adder_sign_o(Adder_sign),
   .A_LZA_o(A_LZA),
   .B_LZA_o(B_LZA),
   .Minus_sticky_bit_o(Minus_sticky_bit),
   .Sign_flip_o(SignFlip_ADD_PRN)
   );


endmodule