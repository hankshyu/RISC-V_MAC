`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//  Engineer:        Tzu-Han Hsu
//  Create Date:     07/25/2022 10:50:12 PM
//  Module Name:     PreNormalizer
//  Project Name:    IEEE-754 & RISC-V Compatible Multiply-Accumulate Unit
//  HDL(Version):    Verilog-2005
//   
//  Dependencies:    None
//
//////////////////////////////////////////////////////////////////////////////////
//  Description:     It shifts the augend to the correct position, and calculates
//                   its exponent, works in parallel with the multiplier
//
//////////////////////////////////////////////////////////////////////////////////
//  Revision:
//  07/25/2022 - Ports renaming into appropriate suffix
//  07/26/2022 - Add debug signals to probe the shifting
//  07/26/2022 - Debug wires removed
//  07/27/2022 - Input wire "sign_change_i" renamed to "sign_flip_i"
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


module PreNormalizer #(
    parameter PARM_EXP  = 8,
    parameter PARM_MANT = 23,
    parameter PARM_BIAS = 127
) (
    input A_sign_i,
    input B_sign_i,
    input C_sign_i,
    input Sub_Sign_i,
    input [PARM_EXP - 1 : 0] A_Exp_i,
    input [PARM_EXP - 1 : 0] B_Exp_i,
    input [PARM_EXP - 1 : 0] C_Exp_i,
    input [PARM_MANT : 0] A_Mant_i,
    input Sign_flip_i, 
    input Mv_halt_i,
    input [PARM_EXP + 1 : 0] Exp_mv_i,
    input Exp_mv_sign_i,

    output Sign_aligned_o,
    output [PARM_EXP + 1: 0] Exp_aligned_o,
    output reg [74 : 0] A_Mant_aligned_o,
    output reg Mant_sticky_sht_out_o
    );
    

    wire [73 : 0] A_Mant_aligned;
    wire [PARM_MANT : 0] Drop_bits;
    assign {A_Mant_aligned, Drop_bits} = {A_Mant_i, 74'd0} >> (Mv_halt_i ? 0 : Exp_mv_i);

    //output logic for aligner
    assign Sign_aligned_o = (Exp_mv_sign_i)? A_sign_i : B_sign_i ^ C_sign_i;
    assign Exp_aligned_o = (Exp_mv_sign_i)? A_Exp_i : (B_Exp_i + C_Exp_i - PARM_BIAS + 27); // exponent = (expB + expC -127) + point distance(= 27)
    
    //output logic for A_Mant_aligned_o
    always @(*) begin
        if(Exp_mv_sign_i)
            A_Mant_aligned_o = (A_Mant_i << 50);
        else if(~Mv_halt_i)
            A_Mant_aligned_o = {Sub_Sign_i, {74{Sub_Sign_i}}^A_Mant_aligned};
        else 
            A_Mant_aligned_o = 0;
    end


    wire [PARM_MANT : 0] A_Mant_2compelemnt = (~A_Mant_i) + 1; //2's complement of mantA
    wire [PARM_MANT : 0] Drop_bits_2complement = (~Drop_bits) + 1; //2's complemet of Drop_bits
    
    //output logic for Mant_sticky_sht_out_o
    always @(*) begin
        if(Sub_Sign_i & (~Sign_flip_i))
            Mant_sticky_sht_out_o = (Mv_halt_i)? (|A_Mant_2compelemnt) : (|Drop_bits_2complement);
        else
            Mant_sticky_sht_out_o = (Mv_halt_i)? (|A_Mant_i) : (|Drop_bits);
    end

endmodule
