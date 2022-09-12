`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//  Engineer:        Tzu-Han Hsu
//  Create Date:     07/25/2022 10:34:02 AM
//  Module Name:     Compressor32
//  Project Name:    IEEE-754 & RISC-V Compatible Multiply-Accumulate Unit
//  HDL(Version):    Verilog-2005
//
//  Dependencies:    FullAdder.v
//
//////////////////////////////////////////////////////////////////////////////////
//  Description:     This is a 3:2 compressor, a.k.a carry save adder.
//
//////////////////////////////////////////////////////////////////////////////////
//  Revision:
//
//////////////////////////////////////////////////////////////////////////////////
//  License information:
//
//  This software is released under the BSD-3-Clause Licence,
//  see https://opensource.org/licenses/BSD-3-Clause for details.
//  In the following license statements, "software" refers to the
//  "source code" of the complete hardware/software system.
//
//  Copyright 2019,
//                    Embedded Intelligent Systems Lab (EISL)
//                    Deparment of Computer Science
//                    National Chiao Tung Uniersity
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

module Compressor32 #(
    parameter XLEN = 49
) (
    input [XLEN - 1 : 0] A_i,
    input [XLEN - 1 : 0] B_i,
    input [XLEN - 1 : 0] C_i,
    output [XLEN - 1 : 0] Sum_o,
    output [XLEN - 1 : 0] Carry_o
);

    generate
        genvar j;
        for(j = 0; j < XLEN; j = j+1)begin
            FullAdder FA(
                .augend_i(A_i[j]),
                .addend_i(B_i[j]),
                .carry_i(C_i[j]),
                .sum_o(Sum_o[j]),
                .carry_o(Carry_o[j])
            );

        end
    endgenerate

endmodule
