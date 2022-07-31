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
    input C_NaN_i,

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

    //Exponent corrections and normalization by results from LOA

    wire [PARM_LEADONE_WIDTH - 1 : 0] Shift_num = (Exp_mv_sign_i | Mant_i[3*PARM_MANT + 4])? 0 : Shift_num_i; // if the leading is 1, or it shifts to the right
    
    reg [PARM_EXP : 0] norm_amt;
    always @(*) begin
        if(Exp_i[PARM_EXP + 1]) 
            norm_amt = 0; // the expoent overflows
        else if(Exp_i > Shift_num) 
            norm_amt = Shift_num; // assure that exp would not < 0
        else 
            norm_amt =  Exp_i[PARM_EXP : 0] - 1; //Denormalized Numbers
    end

    wire [3*PARM_MANT + 4 : 0] Mant_norm = Mant_i << norm_amt;
    
    reg [PARM_EXP + 1 : 0] Exp_norm;
    always @(*) begin
        if(Exp_i[PARM_EXP + 1]) 
            Exp_norm = 0; // the expoent overflows
        else if(Exp_i > Shift_num) 
            Exp_norm = Exp_i - Shift_num; // assure that exp would not < 0
        else 
            Exp_norm = 1; //Denormalized Numbers
    end

    wire [PARM_EXP + 1 : 0] Exp_norm_mone = Exp_i - Shift_num - 1;
    
    //if Exp < 0, shift Right

    wire [PARM_EXP + 1 : 0] Exp_max_rs = Exp_i[PARM_EXP : 0] + 74;
    wire [PARM_EXP + 1 : 0] Rs_count = (~Exp_i + 1) + 1; // -Exp_i + 1, number of right shifts to get a denormalized number.
    wire [3*PARM_MANT + 6 : 0] Rs_Mant = {Mant_i, 2'd0} >> Rs_count;



    //Sticky bit
    reg [2*PARM_MANT + 1 : 0] Mant_sticky_changed;
    
    always @(*) begin
        if(Exp_norm[PARM_EXP + 1]) 
            Mant_sticky_changed = Rs_Mant [2*PARM_MANT + 3 : 2];
        else if(Exp_norm == 0) 
            Mant_sticky_changed = Mant_norm[2*PARM_MANT + 2 : 1];
        else if(Exp_norm[3*PARM_MANT + 4]) 
            Mant_sticky_changed = Mant_norm[2*PARM_MANT + 1 : 0];
        else 
            Mant_sticky_changed = {Mant_norm[2*PARM_MANT : 0], 1'b0};
    end

    wire Sticky_one = (|Mant_sticky_changed) || Mant_sticky_sht_out_i || Minus_sticky_bit_i;

    wire Mant_sticky;

    wire includeNaN = A_NaN_i | B_NaN_i | C_NaN_i;
    wire zeromulinf = (B_Zero_i & C_Inf_i) | (C_Zero_i & B_Inf_i);
    wire subinf = (Sub_Sign_i & A_Inf_i & (B_Inf_i | C_Inf_i));

    assign Invalid_o = (includeNaN | zeromulinf | subinf);
    



    



    
endmodule
