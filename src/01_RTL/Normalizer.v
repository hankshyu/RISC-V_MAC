`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//  Engineer:        Tzu-Han Hsu
//  Create Date:     08/01/2022 03:36:51 PM
//  Module Name:     Normalizer
//  Project Name:    IEEE-754 & RISC-V Compatible Multiply-Accumulate Unit
//  HDL(Version):    Verilog-2005
//   
//  Dependencies:    None
//
//////////////////////////////////////////////////////////////////////////////////
//  Description:     Normalizes the Fraction, and correct the exponent by
//                   the input from Leading One Detector
//
//////////////////////////////////////////////////////////////////////////////////
//  Revision:
//  08/01/2022 - Output logic mistaken port name, fixed
//  08/04/2022 - Remove redundant parameters
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


module Normalizer#(
    parameter PARM_EXP              = 8,
    parameter PARM_MANT             = 23,
    parameter PARM_LEADONE_WIDTH    = 7
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
