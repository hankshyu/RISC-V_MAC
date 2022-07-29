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
    input [2*PARM_MANT + 1 : 0]      CSA_sum_i,
    input [2*PARM_MANT + 1 : 0]      CSA_carry_i,
    input                            Sub_Sign_i,    
    
    input Wallace_suppression_sign_extension_i,
    input [2*PARM_MANT + 2 : 2*PARM_MANT + 1] Wallace_carry_adjusted_2msb_i,  
    input Wallace_sum_adjusted_msb_i,     

    input                            Exp_mv_sign_i,
    input                            Mv_halt_i,
    input [PARM_EXP + 1 : 0]         Exp_mv_neg_i, 
    input                            Sign_aligned_i,

    input [PARM_MANT + 3 : 0]        A_Mant_aligned_high_i, 

    input                            B_Inf_i,
    input                            C_Inf_i,
    input                            B_Zero_i,
    input                            C_Zero_i, 
    input                            B_NaN_i,
    input                            C_Nan_i,

    output reg [3*PARM_MANT + 4 : 0] PosSum_o,
    output                           Adder_sign_o,
    output [3*PARM_MANT + 4 : 0]     A_LZA_o,
    output [3*PARM_MANT + 4 : 0]     B_LZA_o,
    output                           Minus_sticky_bit_o,
    output                           Sign_flip_o);


    //End Around Carry Adders, LSBs
    wire wallace_msb_G = Wallace_sum_adjusted_msb_i & Wallace_carry_adjusted_2msb_i[2*PARM_MANT + 1];
    //if Wallace's msb is 1, or will carry to 1
    wire adder_Correlated_sign = Wallace_suppression_sign_extension_i | Wallace_carry_adjusted_2msb_i[2*PARM_MANT + 2] | wallace_msb_G;

    wire Carry_postcor = (~Exp_mv_sign_i) & ((~adder_Correlated_sign) ^ CSA_carry_i[2*PARM_MANT + 1]);


    wire [2*PARM_MANT + 1 : 0] low_sum;
    wire low_carry;
    wire [2*PARM_MANT + 1 : 0] low_sum_inv;
    wire low_carry_inv;

    EACAdder #(PARM_MANT) eacadder(
        .CSA_sum_i(CSA_sum_i),
        .CSA_carry_i(CSA_carry_i),
        .Carry_postcor_i(Carry_postcor),
        .Sub_Sign_i(Sub_Sign_i),

        .low_sum_o(low_sum),
        .low_carry_o(low_carry),
        .low_sum_inv_o(low_sum_inv),
        .low_carry_inv_o(low_carry_inv)
    );

    //Incrementer, Work on MSBs

    wire [PARM_MANT + 3 : 0]high_sum;
    wire [PARM_MANT + 3 : 0]high_sum_inv;

    MSBIncrementer #(PARM_MANT) msbincrementer(
        .low_carry_i(low_carry),
        .low_carry_inv_i(low_carry_inv),
        .A_Mant_aligned_high_i(A_Mant_aligned_high_i), 

        .high_sum_o(high_sum),
        .high_sum_inv_o(high_sum_inv)
    );

    wire bc_not_strange = ~(B_Inf_i | C_Inf_i | B_Zero_i | C_Zero_i | B_NaN_i | C_Nan_i);

    wire [3*PARM_MANT + 4 : 0] sub_minus = {{A_Mant_aligned_high_i[PARM_MANT+2 : 0], 1'b0} - bc_not_strange, 47'd0};
    
    //outputlogic
    
    assign Sign_flip_o = high_sum[PARM_MANT + 3];
    assign Adder_sign_o = Exp_mv_sign_i? Sign_aligned_i: (Sign_flip_o ^ Sign_aligned_i);
    
    always @(*) begin
        if(Mv_halt_i)
            PosSum_o = {{26'd0}, low_sum};
        else if(Exp_mv_sign_i) //b*c does not participate
            PosSum_o = Sub_Sign_i? sub_minus : {A_Mant_aligned_high_i[PARM_MANT+2 : 0], 48'd0};
        else if(Sign_flip_o)
            PosSum_o = {high_sum_inv[PARM_MANT + 2 : 0], low_sum_inv};
        else
            PosSum_o = {high_sum[PARM_MANT + 2 : 0], low_sum};
    end

////////////////////////////////////////////////////////////////////////////////////
//                  Sticky_bit                                                    //
////////////////////////////////////////////////////////////////////////////////////
// for Sign_amt_DI=1'b1, if is difficult to compute combined with other cases. 
// When addition,   | (b*c) ; when substruction, | (b*c) for rounding excption trunction. 

   assign Minus_sticky_bit_o = Exp_mv_sign_i && (bc_not_strange);

//////////////////////////////////////////////////////////////////// /////////////////
//                  to LZA                                                         //
/////////////////////////////////////////////////////////////////////////////////////

   assign A_LZA_o = PosSum_o;
   assign B_LZA_o = 74'd0 ;

endmodule