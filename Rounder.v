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
// Revision 1.01 - Add PARM_MATN_RMM support
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
    output reg [PARM_EXP - 1 : 0] Exp_result_o,
    output reg [PARM_MANT - 1 : 0] Mant_result_o,
    output  Invalid_o,
    output reg Overflow_o,
    output reg Underflow_o,
    output  Inexact_o,
    output [3:0]dbg_rgs

    );

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


    reg Mant_roundup;// Whether to round up or not
    
    //wires soley for debug:
    wire dbg_w1 = Invalid_o;
    wire dbg_w2 = A_Inf_i | B_Inf_i | C_Inf_i;
    wire dbg_w3 = B_Zero_i | C_Zero_i;
    wire dbg_w4 = Exp_mv_sign_i;
    wire dbg_w5 = Allzero_i;

    wire dbg_w6 = Exp_i[PARM_EXP + 1];
    wire dbg_w6_1 = ~Exp_max_rs_i[PARM_EXP + 1];
    wire dbg_w6_2 = (dbg_w6 & ~dbg_w6_1);
    
    wire dbg_w7 = ((Exp_norm_i[PARM_EXP : 0] == 256) & (~Mant_norm_i[3*PARM_MANT + 4]) & (Mant_norm_i[3*PARM_MANT + 3 : 2*PARM_MANT+3] != 0));
    
    wire dbg_w8 = (Exp_norm_i[PARM_EXP - 1 : 0] == 8'b1111_1111);
    wire dbg_w8_1 = Mant_norm_i[3*PARM_MANT + 4];
    wire dbg_w8_2 = (Mant_norm_i[3*PARM_MANT + 4 : 2*PARM_MANT + 4] == 0);
    wire dbg_w8_3 = (dbg_w8 & ~dbg_w8_1 & ~dbg_w8_2);

    wire dbg_w9 = Exp_norm_i[PARM_EXP];
    wire dbg_w10 = Exp_norm_i == 10'd0;
    
    wire dbg_w11 = Exp_norm_i == 10'd1;
    wire dbg_w11_1 = Mant_norm_i[3*PARM_MANT + 4];
    wire dbg_w11_2 = dbg_w11 & ~dbg_w11_1;

    wire dbg_w12 = ~Mant_norm_i[3*PARM_MANT + 4];
    wire dbg_w13 = ~(dbg_w1 | dbg_w2 | dbg_w3 | dbg_w4 | dbg_w5 | dbg_w6 | dbg_w7 | dbg_w8 | dbg_w9 | dbg_w10 | dbg_w11 | dbg_w12);


    always @(*) begin
        //assign value to avoid latches
        Overflow_o = 1'b0;
        Underflow_o = 1'b0;
        Mant_result_norm = 0;
        Exp_result_norm = 0;
        Mant_lower = 2'b00;
        Sign_result_o = 1'b0;
        Mant_sticky = 1'b0;
//dbg_w1
        if(Invalid_o)begin 
            Mant_result_norm = {1'b0, PARM_MANT_NAN}; //PARM_MANT_NAN is 23 bit
            Exp_result_norm = 8'b1111_1111;

        end
//dbg_w2
        else if(A_Inf_i | B_Inf_i | C_Inf_i)begin // the result is Infinity     
            //Operations on infinite operands are usually exact and therefore signal no exceptions
            Exp_result_norm = 8'b1111_1111;
            //If there's two infinities, they must be the same, if there's 3, it's the same with a
            if(A_Inf_i) Sign_result_o = A_Sign_i;
            else Sign_result_o = B_Sign_i ^ C_Sign_i; 

        end
//dbg_w3
        else if(B_Zero_i | C_Zero_i)begin // for situation of sth + sth*0 / sth + 0*sth
            Mant_result_norm = A_Mant_i;
            Exp_result_norm = A_Exp_raw_i;
            Sign_result_o = A_Sign_i;
        end
//dbg_w4
        else if(Exp_mv_sign_i)begin // Only A counts 
            Underflow_o = A_DeN_i;
            Mant_result_norm = A_Mant_i;
            Exp_result_norm = A_Exp_raw_i;
            Sign_result_o = A_Sign_i;
            Mant_sticky = Sticky_one; // When the exponent move left (negative), sticky bit would come from Mant_sticky
            
        end
//dbg_w5
        else if(Allzero_i)begin
            Sign_result_o = Sign_i;

        end
//dbg_w6
        else if(Exp_i[PARM_EXP + 1])begin 
//dbg_w6_1            
            if(~Exp_max_rs_i[PARM_EXP + 1])begin // exponent would <0 after right shift (too negative)
                Overflow_o = 1;
                Sign_result_o = Sign_i;
            end
//dbg_w6_2 
            else begin // denormalized number
                Underflow_o = 1;
                Mant_result_norm = {1'b0, Rs_Mant_i[3*PARM_MANT + 6 : 2*PARM_MANT + 6]};
                Mant_lower = Rs_Mant_i[2*PARM_MANT + 5 : 2*PARM_MANT + 4];
                Sign_result_o = Sign_i;
                Mant_sticky = Sticky_one;
            end

        end
//dbg_w7
        else if((Exp_norm_i[PARM_EXP : 0] == 256) & (~Mant_norm_i[3*PARM_MANT + 4]) & (Mant_norm_i[3*PARM_MANT + 3 : 2*PARM_MANT+3] != 0))begin 
            // NaN, Exp_norm_i = 256
            // Mant_result_norm = {1'b0, PARM_MANT_NAN}; //PARM_MANT_NAN is 23 bit
            // Exp_result_norm = 8'b1111_1111;
            
            // This is an Overflow case
            Overflow_o = 1;
            Sign_result_o = Sign_i;
        end
//dbg_w8
        else if(Exp_norm_i[PARM_EXP - 1 : 0] == 8'b1111_1111)begin
//dbg_w8_1
            if(Mant_norm_i[3*PARM_MANT + 4])begin // Overflow
                Overflow_o = 1;
                Sign_result_o = Sign_i;
            end
//dbg_w8_1_2
            else if(Mant_norm_i[3*PARM_MANT + 4 : 2*PARM_MANT + 4] == 0)begin // Overflow
                Overflow_o = 1;
                Sign_result_o = Sign_i;
            end
//dbg_w8_1_3
            else begin // Normal numbers
                Exp_result_norm = 8'b1111_1110; //254
                Sign_result_o = Sign_i;

                Mant_result_norm  = Mant_norm_i [3*PARM_MANT + 2 : 2*PARM_MANT + 3];//originally out of bound
                Mant_lower = Mant_norm_i[2*PARM_MANT + 2 : 2*PARM_MANT + 1];
                Mant_sticky = Sticky_one;
                
                //see if it's overflow, if mant is full and about to round up
                if(Mant_result_norm[PARM_MANT - 1 : 0] == {(PARM_MANT){1'b1}})begin
                    case (Rounding_mode_i)
                        PARM_RM_RNE:
                            Overflow_o = Mant_lower[1] & (Mant_lower[0] | Mant_sticky | Mant_result_norm[0]);
                        PARM_RM_RTZ:
                            Overflow_o = 0;
                        PARM_RM_RDN:
                            Overflow_o = ((|Mant_lower) || Mant_sticky) & Sign_i;
                        PARM_RM_RUP:
                            Overflow_o = ((|Mant_lower) || Mant_sticky) & (~Sign_i);
                        PARM_RM_RMM:
                            Overflow_o = Mant_lower[1];
                        default:
                            Overflow_o = 0;
                    endcase
                end

            end

        end
//dbg_w9
        else if(Exp_norm_i[PARM_EXP])begin //Overflow Occurs, the exponent at preNorm(multiplication is over 127)
            Overflow_o = 1;
            Sign_result_o = Sign_i;
        end
//dbg_w10
        else if(Exp_norm_i == 10'd0)begin // 0 denormalized
            Underflow_o = 1;
            Mant_result_norm = {1'b0, Mant_norm_i[3*PARM_MANT + 4 : 2*PARM_MANT + 5]};
            Mant_lower = Mant_norm_i[2*PARM_MANT + 4 : 2*PARM_MANT + 3];
            Sign_result_o = Sign_i;
            Mant_sticky = Sticky_one;
            
        end
//dbg_w11
        else if(Exp_norm_i == 10'd1)begin // 0
//dbg_w11_1
            if(Mant_norm_i[3*PARM_MANT + 4])begin //Normal Number
                Mant_result_norm = Mant_norm_i[3*PARM_MANT + 4 : 2*PARM_MANT + 4];
                Exp_result_norm = 1;
                Mant_lower = Mant_norm_i[2*PARM_MANT + 3 : 2*PARM_MANT + 2];
                Sign_result_o = Sign_i;
                Mant_sticky = Sticky_one;
            end
//dbg_w11_2
            else begin //Denormalized Number
                Underflow_o = 1;
                Mant_result_norm = Mant_norm_i[3*PARM_MANT + 4: 2*PARM_MANT + 4];
                Mant_lower = Mant_norm_i[2*PARM_MANT + 3 : 2*PARM_MANT + 2];
                Sign_result_o = Sign_i;
                Mant_sticky = Sticky_one;
            end

        end
//dbg_w12
        else if(~Mant_norm_i[3*PARM_MANT + 4])begin // number with 0X.XX, normal numbers
            Mant_result_norm = Mant_norm_i[3*PARM_MANT + 3 : 2*PARM_MANT + 3];
            Exp_result_norm = Exp_norm_mone_i[PARM_MANT - 1 : 0];
            Mant_lower = Mant_norm_i[2*PARM_MANT + 2 : 2*PARM_MANT + 1];
            Sign_result_o = Sign_i;
            Mant_sticky = Sticky_one;
        end
//dbg_w13
        else begin // number with 1X.XX, normal nubmers
            Mant_result_norm = Mant_norm_i[3*PARM_MANT + 4 : 2*PARM_MANT + 4];
            Exp_result_norm = Exp_norm_i[PARM_MANT - 1 : 0];
            Mant_lower = Mant_norm_i[2*PARM_MANT + 3 : 2*PARM_MANT + 2];
            Sign_result_o = Sign_i;
            Mant_sticky = Sticky_one;
        end
    end

    //Rounding
    // IEEE 754
    // Unless stated otherwise, if the rounded result of an operation is inexact—that is, it differs from what would
    // have been computed were both exponent range and precision unbounded—then the inexact exception shall
    // be signaled. The rounded or overflowed result shall be delivered to the destination
    // 7.6 Inexact (emphaisis added): 
    // When all of these exceptions are handled by default, the inexact flag is always raised when either the overflow or underflow flag is raised.
    assign Inexact_o = (|Mant_lower) || Mant_sticky || Overflow_o ||Underflow_o;


    always @(*) begin
        case (Rounding_mode_i)
            PARM_RM_RNE:
                Mant_roundup = Mant_lower[1] & (Mant_lower[0] | Mant_sticky | Mant_result_norm[0]);
            PARM_RM_RTZ:
                Mant_roundup = 0;
            PARM_RM_RDN:
                Mant_roundup = Inexact_o & Sign_i;
            PARM_RM_RUP:
                Mant_roundup = Inexact_o & (~Sign_i);
            PARM_RM_RMM:
                Mant_roundup = Mant_lower[1];
            default:
                Mant_roundup = 0;
        endcase
    end

    wire [PARM_MANT + 1 : 0] Mant_upper_rounded = Mant_result_norm + Mant_roundup;
    wire Mant_renormalize = Mant_upper_rounded[PARM_MANT + 1];


    // Overflow (IEEE 754-2008)
    // The overflow exception shall be signaled if and only if the destination format’s largest finite number is
    // exceeded in magnitude by what would have been the rounded floating-point result (see 4) were the exponent
    // range unbounded. The default result shall be determined by the rounding-direction attribute and the sign of
    // the intermediate result as follows:
    // a) roundTiesToEven and roundTiesToAway carry all overflows to ∞ with the sign of the intermediate
    // result.
    // b) roundTowardZero carries all overflows to the format’s largest finite number with the sign of the
    // intermediate result.
    // c) roundTowardNegative carries positive overflows to the format’s largest finite number, and carries
    // negative overflows to −∞.
    // d) roundTowardPositive carries negative overflows to the format’s most negative finite number, and
    // carries positive overflows to +∞.
    // In addition, under default exception handling for overflow, the overflow flag shall be raised and the inexact
    // exception shall be signaled.
    
    //output logic

    always @(*) begin
        if(Overflow_o)begin
            case (Rounding_mode_i)
                PARM_RM_RNE:
                    Mant_result_o = 0; // to Inf
                PARM_RM_RTZ:
                    Mant_result_o = {PARM_MANT{1'b1}};//to Largest Finite Number
                PARM_RM_RDN:
                    Mant_result_o = (Sign_result_o)? 0 : {PARM_MANT{1'b1}}; //+: to largest Finite Number -: to Inf
                PARM_RM_RUP:
                    Mant_result_o = (Sign_result_o)? {PARM_MANT{1'b1}} : 0; //+: to Inf  -: to most negative Finite Number
                PARM_RM_RMM:
                    Mant_result_o = 0; // to Inf
                default:
                    Mant_result_o = 0;
            endcase
        end
        else if(Mant_renormalize)
            Mant_result_o = Mant_upper_rounded[PARM_MANT : 1];
        else 
            Mant_result_o = Mant_upper_rounded[PARM_MANT - 1 : 0];
    end

    always@(*)begin
        if(Overflow_o)begin
            case (Rounding_mode_i)
                PARM_RM_RNE:
                    Exp_result_o = {PARM_EXP{1'b1}}; // to Inf
                PARM_RM_RTZ:
                    Exp_result_o = {{(PARM_EXP-1){1'b1}},1'b0}; ////to Largest Finite Number, exp = 1111_1110
                PARM_RM_RDN:
                    Exp_result_o = (Sign_result_o)? {PARM_EXP{1'b1}} : {{(PARM_EXP-1){1'b1}},1'b0};
                PARM_RM_RUP:
                    Exp_result_o = (Sign_result_o)? {{(PARM_EXP-1){1'b1}},1'b0} : {PARM_EXP{1'b1}};
                PARM_RM_RMM:
                    Exp_result_o = {PARM_EXP{1'b1}}; // to Inf
                default:
                    Mant_roundup = 0;
            endcase
        end
        else 
            Exp_result_o = Exp_result_norm + Mant_renormalize;
    end

    //debug
    assign dbg_rgs = {Mant_result_norm[0],Mant_lower,Mant_sticky};

endmodule
