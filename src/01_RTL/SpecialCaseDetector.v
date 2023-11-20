`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//  Engineer:        Tzu-Han Hsu
//  Create Date:     07/21/2022 07:41:57 PM
//  Module Name:     SpecialCaseDetector
//  Project Name:    IEEE-754 & RISC-V Compatible Multiply-Accumulate Unit
//  HDL(Version):    Verilog-2005
//
//  Dependencies:    None
//
//////////////////////////////////////////////////////////////////////////////////
//  Description:     Detect whether the input data is:
//                   1. Infinity            
//                   2. Zero                 
//                   3. NaN
//                   4. Denormalized Number
//
//////////////////////////////////////////////////////////////////////////////////
//  Revision:
//  07/21/2022 - Infinity, Zero and NaN detection done.
//  07/21/2022 - Denormalized Nubmer detection added
//  08/04/2022 - I/O ports renamingm, appropriate suffix added
//  08/04/2022 - parameters arranged, comments added for readability
//  08/14/2022 - Wire rename, avoid non-parameter upper cased wire
//  09/12/2022 - Add BSD-3-Clause Licence
//   
//////////////////////////////////////////////////////////////////////////////////
//  License information:
//
//  This software is released under the BSD-3-Clause Licence,
//  see https://opensource.org/licenses/BSD-3-Clause for details.
//  In the following license statements, "software" refers to the
//  "source code" of the complete hardware/software system.
//
//  Copyright 2022,
//                    Embedded Intelligent Systems Lab (EISL)
//                    Deparment of Computer Science
//                    National Yang Ming Chiao Tung Uniersity
//                    Hsinchu, Taiwan.
//
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//  3. Neither the name of the copyright holder nor the names of its contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//////////////////////////////////////////////////////////////////////////////////


module SpecialCaseDetector #(
    parameter PARM_XLEN         = 32,
    parameter PARM_EXP          = 8,
    parameter PARM_MANT         = 23

) (
    input [PARM_XLEN - 1 : 0] A_i,
    input [PARM_XLEN - 1 : 0] B_i,
    input [PARM_XLEN - 1 : 0] C_i,
    input A_Leadingbit_i,
    input B_Leadingbit_i,
    input C_Leadingbit_i,
    
    output A_Inf_o,
    output B_Inf_o,
    output C_Inf_o,
    output A_Zero_o,
    output B_Zero_o,
    output C_Zero_o,
    output A_NaN_o,
    output B_NaN_o,
    output C_NaN_o,
    output A_DeN_o,
    output B_DeN_o,
    output C_DeN_o);


    wire [PARM_EXP - 1: 0] Exp_Fullone = {PARM_EXP{1'b1}}; // Exponent is all '1'

    
    wire A_ExpZero = ~A_Leadingbit_i;
    wire B_ExpZero = ~B_Leadingbit_i;
    wire C_ExpZero = ~C_Leadingbit_i;

    wire A_ExpFull = (A_i[PARM_XLEN - 2 : PARM_MANT] == Exp_Fullone);
    wire B_ExpFull = (B_i[PARM_XLEN - 2 : PARM_MANT] == Exp_Fullone);
    wire C_ExpFull = (C_i[PARM_XLEN - 2 : PARM_MANT] == Exp_Fullone);

    wire A_MantZero = (A_i[PARM_MANT - 1 : 0] == 0);
    wire B_MantZero = (B_i[PARM_MANT - 1 : 0] == 0);
    wire C_MantZero = (C_i[PARM_MANT - 1 : 0] == 0);


    //output logic
    assign A_Zero_o = A_ExpZero & A_MantZero;
    assign B_Zero_o = B_ExpZero & B_MantZero;
    assign C_Zero_o = C_ExpZero & C_MantZero;

    assign A_Inf_o = A_ExpFull & A_MantZero;
    assign B_Inf_o = B_ExpFull & B_MantZero;
    assign C_Inf_o = C_ExpFull & C_MantZero;

    assign A_NaN_o = A_ExpFull & (~A_MantZero);
    assign B_NaN_o = B_ExpFull & (~B_MantZero);
    assign C_NaN_o = C_ExpFull & (~C_MantZero);

    assign A_DeN_o  = A_ExpZero & (~A_MantZero);
    assign B_DeN_o  = B_ExpZero & (~B_MantZero);
    assign C_DeN_o  = C_ExpZero & (~C_MantZero);

endmodule