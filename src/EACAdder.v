`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//  Engineer:        Tzu-Han Hsu
//  Create Date:     07/29/2022 10:40:06 AM
//  Module Name:     EACAdder
//  Project Name:    IEEE-754 & RISC-V Compatible Multiply-Accumulate Unit
//  HDL(Version):    Verilog-2005
//
//  Dependencies:    None
//
//////////////////////////////////////////////////////////////////////////////////
//  Description:    An adder outputs a positive magnitude result and preferably
//                  only need to conditionally complement one operand
//
//////////////////////////////////////////////////////////////////////////////////
//  Revision:
//  07/29/2022 - I/O port names renamed with correct suffix
//  08/06/2022 - Add A_Zero_i signal to detect A is -0, in order to avoid false end round carry
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


module EACAdder #(
    parameter PARM_MANT = 23
) (
    input [2*PARM_MANT + 1 : 0] CSA_sum_i,
    input [2*PARM_MANT + 1 : 0] CSA_carry_i,
    input Carry_postcor_i,
    input Sub_Sign_i,
    input A_Zero_i,    

    output [2*PARM_MANT + 1 : 0] low_sum_o,
    output low_carry_o,
    output [2*PARM_MANT + 1 : 0] low_sum_inv_o,
    output low_carry_inv_o);

    wire end_round_carry = Sub_Sign_i & (~A_Zero_i);
    assign {low_carry_o, low_sum_o} =  CSA_sum_i + {Carry_postcor_i, CSA_carry_i[2*PARM_MANT : 0], end_round_carry};
    assign {low_carry_inv_o, low_sum_inv_o} = 2'b10 + {1'b1, ~CSA_sum_i} + {~Carry_postcor_i, ~CSA_carry_i[2*PARM_MANT : 0], ~end_round_carry};

endmodule
