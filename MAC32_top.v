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
    input clk_i,
    input rst_i,
    //input stall_i,
    input req_i,

    input [PARM_RM - 1 : 0] rounding_mode_i,


    input [PARM_XLEN - 1 : 0] A_i,
    input [PARM_XLEN - 1 : 0] B_i,
    input [PARM_XLEN - 1 : 0] C_i,

    // T (result_o) = B + (A * C)
    output reg [32 - 1 : 0] result_o,
    output ready_o,
    
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
    // parameter PARM_PC            = 5;
    parameter PARM_EXP          = 8;
    parameter PARM_MANT         = 23;
    // parameter PARM_MANT_PRENORM  = 24;
    parameter PARM_BIAS         = 127;
    //parameter PARM_HALF_BIAS     = 63;
    //parameter PARM_LEADONE_WIDTH = 7,
    parameter PARM_EXP_ZERO     = 8'h00;
    parameter PARM_EXP_ONE      = 8'h01;
    parameter PARM_EXP_INF      = 8'hff;
    parameter PARM_MANT_ZERO    = 23'd0;
   //RISC-V defines canonical NaN to be 0x7fc0_0000
    parameter PARM_MANT_NAN     = 23'b100_0000_0000_0000_0000_0000;

    wire Sign_a, Sign_b, Sign_c;
    wire [PARM_EXP - 1 : 0] Exp_a;
    wire [PARM_EXP - 1 : 0] Exp_b;
    wire [PARM_EXP - 1 : 0] Exp_c;
    wire [PARM_MANT - 1 : 0] Mant_a;
    wire [PARM_MANT - 1 : 0] Mant_b;
    wire [PARM_MANT - 1 : 0] Mant_c;

    assign {Sign_a, Exp_a, Mant_a} = A_i;
    assign {Sign_b, Exp_b, Mant_b} = B_i;
    assign {Sign_c, Exp_c, Mant_c} = C_i;



    
endmodule