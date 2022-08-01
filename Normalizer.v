`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2022 03:36:51 PM
// Design Name: 
// Module Name: Normalizer
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


module Normalizer#(
    parameter PARM_LEADONE_WIDTH    = 7,
    parameter PARM_EXP              = 8,
    parameter PARM_MANT             = 23
) (
    input [3*PARM_MANT + 4 : 0]Mant_i,
    input [PARM_EXP + 1 : 0]Exp_i,
    
    input [PARM_LEADONE_WIDTH - 1 : 0] Shift_num_i,
    input Exp_mv_sign_i,

    output [3*PARM_MANT + 4 : 0] Mant_norm_o,
    output reg [PARM_EXP + 1 : 0] Exp_norm_o,
    output [PARM_EXP + 1 : 0] Exp_norm_mone_o,
    output [PARM_EXP + 1 : 0] Exp_max_rs_o,
    output [3*PARM_MANT + 6 : 0] Rs_Mant_o
    );

    //Exponent corrections and normalization by results from LOA

    wire [PARM_LEADONE_WIDTH - 1 : 0] Shift_num = (Exp_mv_sign_i | Mant_i[3*PARM_MANT + 4])? 0 : Shift_num_i; //If the exponent < 0, or it has a leading one (1xxxxxx....)
    
    reg [PARM_EXP : 0] norm_amt;
    always @(*) begin
        if(Exp_i[PARM_EXP + 1]) 
            norm_amt = 0; // the expoent overflows
        else if(Exp_i > Shift_num) 
            norm_amt = Shift_num; // assure that exp would not < 0
        else 
            norm_amt =  Exp_i[PARM_EXP : 0] - 1; //Denormalized Numbers, has exponent of 0, representing -126
    end

    assign Mant_norm_o = Mant_i << norm_amt;
    
    
    always @(*) begin
        if(Exp_i[PARM_EXP + 1]) 
            Exp_norm_o = 0; // the expoent overflows
        else if(Exp_i > Shift_num) 
            Exp_norm_o = Exp_i - Shift_num; // assure that exp would not < 0
        else 
            Exp_norm_o = 1; //Denormalized Numbers, has exponent of 0, representing -126
    end

    assign Exp_norm_mone_o = Exp_i - Shift_num - 1;
    
    //if Exp < 0, shift Right

    assign Exp_max_rs_o = Exp_i[PARM_EXP : 0] + 74;
    wire [PARM_EXP + 1 : 0] Rs_count = (~Exp_i + 1) + 1; // -Exp_i + 1, number of right shifts to get a denormalized number.
    assign Rs_Mant_o = {Mant_i, 2'd0} >> Rs_count;

endmodule
