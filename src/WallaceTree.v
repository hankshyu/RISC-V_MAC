`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//  Engineer:        Tzu-Han Hsu
//  Create Date:     07/22/2022 03:15:31 PM
//  Module Name:     WallaceTree
//  Project Name:    IEEE-754 & RISC-V Compatible Multiply-Accumulate Unit
//  HDL(Version):    Verilog-2005
//
//  Dependencies:    Compressor32.v
//                   Compressor42.v
//
//////////////////////////////////////////////////////////////////////////////////
//  Description:     Sums 13 partial products using carry save adder(CSA) into carry and sum
//                   with: 
//                           9x 3-2 Compressor
//                           1x 4-2 Compressor
//
//////////////////////////////////////////////////////////////////////////////////
//  Revision:
//  07/22/2022 - Basic wiring finished, I/O signals updated for appropriate prefix
//  07/25/2022 - Use generate statements to simplify code
//  07/25/2022 - Multidriven net fixed
//  07/25/2022 - Interleaving Wires rearranged
//  08/15/2022 - Interconnection changed, to reduce critical path
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


module WallaceTree #(
    parameter PARM_MANT = 23
) (
    input [2*PARM_MANT + 2 : 0] pp_00_i,
    input [2*PARM_MANT + 2 : 0] pp_01_i,
    input [2*PARM_MANT + 2 : 0] pp_02_i,
    input [2*PARM_MANT + 2 : 0] pp_03_i,
    input [2*PARM_MANT + 2 : 0] pp_04_i,
    input [2*PARM_MANT + 2 : 0] pp_05_i,
    input [2*PARM_MANT + 2 : 0] pp_06_i,
    input [2*PARM_MANT + 2 : 0] pp_07_i,
    input [2*PARM_MANT + 2 : 0] pp_08_i,
    input [2*PARM_MANT + 2 : 0] pp_09_i,
    input [2*PARM_MANT + 2 : 0] pp_10_i,
    input [2*PARM_MANT + 2 : 0] pp_11_i,
    input [2*PARM_MANT + 1 : 0] pp_12_i,

    output [2*PARM_MANT + 2 : 0] wallace_sum_o,
    output [2*PARM_MANT + 2 : 0] wallace_carry_o,
    output suppression_sign_extension_o);


    wire  [2*PARM_MANT + 2 : 0] csa_sum [9 - 1: 0];
    wire  [2*PARM_MANT + 2 : 0] csa_carry [9 - 1: 0];
    
    wire  [2*PARM_MANT + 2 : 0] csa_shcy [9 - 1: 0];
    wire  [9 : 3] sign_extension;
    generate
        genvar i;
        for(i = 3; i < 9; i = i+1)begin
            assign sign_extension[i] = csa_carry[i][2*PARM_MANT + 2];
        end
    endgenerate

    generate
        genvar j;
        for(j = 0; j < 9; j = j+1)begin
            assign csa_shcy[j] = csa_carry[j] << 1;
        end
    endgenerate
    
    
    Compressor32 #(2*PARM_MANT + 3) LV1_0 (.A_i(pp_00_i),.B_i(pp_01_i),.C_i(pp_02_i),.Sum_o(csa_sum[0]),.Carry_o(csa_carry[0]));
    Compressor32 #(2*PARM_MANT + 3) LV1_1 (.A_i(pp_03_i),.B_i(pp_04_i),.C_i(pp_05_i),.Sum_o(csa_sum[1]),.Carry_o(csa_carry[1]));
    Compressor32 #(2*PARM_MANT + 3) LV1_2 (.A_i(pp_06_i),.B_i(pp_07_i),.C_i(pp_08_i),.Sum_o(csa_sum[2]),.Carry_o(csa_carry[2]));
    Compressor32 #(2*PARM_MANT + 3) LV1_3 (.A_i(pp_09_i),.B_i(pp_10_i),.C_i(pp_11_i),.Sum_o(csa_sum[3]),.Carry_o(csa_carry[3]));

    Compressor32 #(2*PARM_MANT + 3) LV2_0 (.A_i(csa_sum[0] ),.B_i(csa_shcy[0]),.C_i(csa_sum[1] ),.Sum_o(csa_sum[4]),.Carry_o(csa_carry[4]));
    Compressor32 #(2*PARM_MANT + 3) LV2_1 (.A_i(csa_shcy[1]),.B_i(csa_sum[2] ),.C_i(csa_shcy[2]),.Sum_o(csa_sum[5]),.Carry_o(csa_carry[5]));
    Compressor32 #(2*PARM_MANT + 3) LV2_2 (.A_i(csa_sum[3] ),.B_i(csa_shcy[3]),.C_i({1'd0, pp_12_i}),.Sum_o(csa_sum[6]),.Carry_o(csa_carry[6]));
    
    Compressor32 #(2*PARM_MANT + 3) LV3_0 (.A_i(csa_sum[4] ),.B_i(csa_shcy[4]),.C_i(csa_sum[5] ),.Sum_o(csa_sum[7]),.Carry_o(csa_carry[7]));
    Compressor32 #(2*PARM_MANT + 3) LV3_1 (.A_i(csa_shcy[5]),.B_i(csa_sum[6] ),.C_i(csa_shcy[6]),.Sum_o(csa_sum[8]),.Carry_o(csa_carry[8]));

    Compressor42 #(2*PARM_MANT + 3)
        LV4_Final (
            .A_i(csa_sum[7]),
            .B_i(csa_shcy[7]),
            .C_i(csa_sum[8]),
            .D_i(csa_shcy[8]),
            .Sum_o(wallace_sum_o),
            .Carry_o(wallace_carry_o),
            .hidden_carry_msb(sign_extension[9])
        );

    assign suppression_sign_extension_o = |sign_extension;

endmodule
