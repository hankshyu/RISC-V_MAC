`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/30/2022 10:47:12 AM
// Design Name: 
// Module Name: Rounder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - File Renamed
// Revision 1.00 - Invalid_o shall raise whilst Overflow/Underflow
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Rounder #(
    parameter PARM_RM               = 3,
    parameter PARM_RM_RNE           = 3'b000,
    parameter PARM_RM_RTZ           = 3'b001,
    parameter PARM_RM_RDN           = 3'b010,
    parameter PARM_RM_RUP           = 3'b011,
    parameter PARM_RM_RMM           = 3'b100,
    parameter PARM_MANT_NAN         = 23'b100_0000_0000_0000_0000_0000,
    parameter PARM_EXP              = 8,
    parameter PARM_MANT             = 23,
    parameter PARM_LEADONE_WIDTH    = 7
) (

    input [PARM_EXP + 1 : 0]Exp_i,
    input Sign_i,

    input Allzero_i,
    input Exp_mv_sign_i,

    input Sub_Sign_i,
    input [PARM_EXP - 1 : 0] A_Exp_raw_i,
    input [PARM_MANT : 0] A_Mant_i,
    input [PARM_RM - 1 : 0] Rounding_mode_i,
    input A_Sign_i,
    input B_Sign_i,
    input C_Sign_i,

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

    input [3*PARM_MANT + 4 : 0] Mant_norm_i,
    input [PARM_EXP + 1 : 0] Exp_norm_i,
    input [PARM_EXP + 1 : 0] Exp_norm_mone_i,
    input [PARM_EXP + 1 : 0] Exp_max_rs_i,
    input [3*PARM_MANT + 6 : 0] Rs_Mant_i,

    output reg Sign_result_o,
    output [PARM_EXP - 1 : 0] Exp_result_o,
    output [PARM_MANT - 1 : 0] Mant_result_o,
    output  Invalid_o,
    output reg Overflow_o,
    output reg Underflow_o,
    output  Inexact_o );

    //Sticky bit
    reg [2*PARM_MANT + 1 : 0] Mant_sticky_changed;
    always @(*) begin
        if(Exp_norm_i[PARM_EXP + 1]) 
            Mant_sticky_changed = Rs_Mant_i [2*PARM_MANT + 3 : 2];
        else if(Exp_norm_i == 0) 
            Mant_sticky_changed = Mant_norm_i[2*PARM_MANT + 2 : 1];
        else if(Mant_norm_i[3*PARM_MANT + 4]) // | Exp_norm_i == 0
            Mant_sticky_changed = Mant_norm_i[2*PARM_MANT + 1 : 0];
        else 
            Mant_sticky_changed = {Mant_norm_i[2*PARM_MANT : 0], 1'b0};
    end

    wire Sticky_one = (|Mant_sticky_changed) || Mant_sticky_sht_out_i || Minus_sticky_bit_i;


    wire includeNaN = A_NaN_i | B_NaN_i | C_NaN_i;
    wire zeromulinf = (B_Zero_i & C_Inf_i) | (C_Zero_i & B_Inf_i);
    wire subinf = (Sub_Sign_i & A_Inf_i & (B_Inf_i | C_Inf_i));

    assign Invalid_o = (includeNaN | zeromulinf | subinf);
    
    reg Mant_sticky;
    reg [PARM_MANT : 0] Mant_result_norm; // 24 bit
    reg [PARM_EXP - 1 : 0] Exp_result_norm; // 8 bit
    reg [1 : 0] Mant_lower;


    always @(*) begin
        //assign value to avoid latches
        Overflow_o = 1'b0;
        Underflow_o = 1'b0;
        Mant_result_norm = 0;
        Exp_result_norm = 0;
        Mant_lower = 2'b00;
        Sign_result_o = 1'b0;
        Mant_sticky = 1'b0;

        if(Invalid_o)begin
            Mant_result_norm = {1'b0, PARM_MANT_NAN}; //PARM_MANT_NAN is 23 bit
            Exp_result_norm = 8'b1111_1111;

        end
        else if(A_Inf_i | B_Inf_i | C_Inf_i)begin // the result is Infinity
            //Operations on infinite operands are usually exact and therefore signal no exceptions
            Exp_result_norm = 8'b1111_1111;
            //If there's two infinities, they must be the same, if there's 3, it's the same with a
            if(A_Inf_i) Sign_result_o = A_Sign_i;
            else Sign_result_o = B_Sign_i ^ C_Sign_i; 

        end
        else if(B_Zero_i | C_Zero_i)begin // for situation of sth + sth*0 / sth + 0*sth
            Mant_result_norm = A_Mant_i;
            Exp_result_norm = A_Exp_raw_i;
            Sign_result_o = A_Sign_i;
        end
        else if(Exp_mv_sign_i)begin // Only A counts 
            Underflow_o = A_DeN_i;
            Mant_result_norm = A_Mant_i;
            Exp_result_norm = A_Exp_raw_i;
            Sign_result_o = A_Sign_i;
            Mant_sticky = Sticky_one; // When the exponent move left (negative), sticky bit would come from Mant_sticky
            
        end
        else if(Allzero_i)begin
            Sign_result_o = Sign_i;

        end
        else if(Exp_i[PARM_EXP + 1])begin 
            
            if(~Exp_max_rs_i[PARM_EXP + 1])begin // exponent would <0 after right shift (too negative)
                Overflow_o = 1;
                Sign_result_o = Sign_i;
            end
            else begin // denormalized number
                Underflow_o = 1;
                Mant_result_norm = {1'b0, Rs_Mant_i[3*PARM_MANT + 6 : 2*PARM_MANT + 6]};
                Mant_lower = Rs_Mant_i[2*PARM_MANT + 5 : 2*PARM_MANT + 4];
                Sign_result_o = Sign_i;
                Mant_sticky = Sticky_one;
            end

        end
        else if((Exp_norm_i[PARM_EXP : 0] == 256) & (~Mant_norm_i[3*PARM_MANT + 4]) & (Mant_norm_i[3*PARM_MANT + 3 : 2*PARM_MANT+3] != 0))begin //NaN, Exp_norm_i = 256
            Mant_result_norm = {1'b0, PARM_MANT_NAN}; //PARM_MANT_NAN is 23 bit
            Exp_result_norm = 8'b1111_1111;

        end
        else if(Exp_norm_i[PARM_EXP - 1 : 0] == 8'b1111_1111)begin
            
            if(Mant_norm_i[3*PARM_MANT + 4])begin // NaN
                Overflow_o = 1;
                Mant_result_norm = {1'b0, PARM_MANT_NAN};
                Exp_result_norm = 8'b1111_1111;
                Sign_result_o = Sign_i;
    
            end
            else if(Mant_norm_i[3*PARM_MANT + 4 : 2*PARM_MANT + 4] == 0)begin //Infinity
                Overflow_o = 1;
                Exp_result_norm = 8'b1111_1111;
                Sign_result_o = Sign_i;
            end
            else begin // Normal numbers
                Mant_result_norm  = Mant_norm_i [3*PARM_MANT + 3 : 2*PARM_MANT + 3];
                Exp_result_norm = 8'b1111_1110; //254
                Mant_lower = Mant_norm_i[2*PARM_MANT + 2 : 2*PARM_MANT + 1];
                Sign_result_o = Sign_i;
                Mant_sticky = Sticky_one;
            end

        end
        else if(Exp_norm_i[PARM_EXP])begin //Infinity
            Overflow_o = 1;
            Exp_result_norm = 8'b1111_1111;
            Sign_result_o = Sign_i;

        end
        else if(Exp_norm_i == 10'd0)begin // 0 denormalized
            Underflow_o = 1;
            Mant_result_norm = {1'b0, Mant_norm_i[3*PARM_MANT + 4 : 2*PARM_MANT + 5]};
            Mant_lower = Mant_norm_i[2*PARM_MANT + 4 : 2*PARM_MANT + 3];
            Sign_result_o = Sign_i;
            Mant_sticky = Sticky_one;
            
        end
        else if(Exp_norm_i == 10'd1)begin // 0

            if(Mant_norm_i[3*PARM_MANT + 4])begin //Normal Number
                Mant_result_norm = Mant_norm_i[3*PARM_MANT + 4 : 2*PARM_MANT + 4];
                Exp_result_norm = 1;
                Mant_lower = Mant_norm_i[2*PARM_MANT + 3 : 2*PARM_MANT + 2];
                Sign_result_o = Sign_i;
                Mant_sticky = Sticky_one;
            end
            else begin //Denormalized Number
                Underflow_o = 1;
                Mant_result_norm = Mant_norm_i[3*PARM_MANT + 4: 2*PARM_MANT + 4];
                Mant_lower = Mant_norm_i[2*PARM_MANT + 3 : 2*PARM_MANT + 2];
                Sign_result_o = Sign_i;
                Mant_sticky = Sticky_one;
            end

        end
        else if(~Mant_norm_i[3*PARM_MANT + 4])begin // number with 0X.XX
            Mant_result_norm = Mant_norm_i[3*PARM_MANT + 3 : 2*PARM_MANT + 3];
            Exp_result_norm = Exp_norm_mone_i[PARM_MANT - 1 : 0];
            Mant_lower = Mant_norm_i[2*PARM_MANT + 2 : 2*PARM_MANT + 1];
            Sign_result_o = Sign_i;
            Mant_sticky = Sticky_one;
        end
        else begin // number with 1X.XX
            Mant_result_norm = Mant_norm_i[3*PARM_MANT + 4 : 2*PARM_MANT + 4];
            Exp_result_norm = Exp_norm_i[PARM_MANT - 1 : 0];
            Mant_lower = Mant_norm_i[2*PARM_MANT + 3 : 2*PARM_MANT + 2];
            Sign_result_o = Sign_i;
            Mant_sticky = Sticky_one;
        end
    end

    //Rounding
    // IEEE 754
    // 7.6 Inexact (emphaisis added): 
    // When all of these exceptions are handled by default, the inexact flag is always raised when either the overflow or underflow flag is raised.
    assign Inexact_o = (|Mant_lower) || Mant_sticky || Overflow_o ||Underflow_o;

    reg Mant_roundup;// Whether to round up or not
    always @(*) begin
        case (Rounding_mode_i)
            PARM_RM_RNE:
                Mant_roundup = Mant_lower[1] & (Mant_lower[0] | Mant_sticky | Mant_result_norm[0]);
            PARM_RM_RTZ:
                Mant_roundup = 0;
            PARM_RM_RUP:
                Mant_roundup = Inexact_o & (~Sign_i);
            PARM_RM_RDN:
                Mant_roundup = Inexact_o & Sign_i;
            default:
                Mant_roundup = 0;
        endcase
    end

    wire [PARM_MANT + 1 : 0] Mant_upper_rounded = Mant_result_norm + Mant_roundup;
    wire Mant_renormalize = Mant_upper_rounded[PARM_MANT + 1];

    //output logic
    assign Mant_result_o = (Mant_renormalize)? Mant_upper_rounded[PARM_MANT : 1] : Mant_upper_rounded[PARM_MANT - 1 : 0];
    assign Exp_result_o = Exp_result_norm + Mant_renormalize;

endmodule
