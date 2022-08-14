`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:        Tzu-Han Hsu
// Create Date:     07/29/2022 10:40:06 AM
// Module Name:     EACAdder
// Project Name:    IEEE-754 & RISC-V Compatible Multiply-Accumulate Unit
// HDL(Version):    Verilog-2005
//
// Dependencies:    None
//
//////////////////////////////////////////////////////////////////////////////////
// Description:    An adder outputs a positive magnitude result and preferably
//                 only need to conditionally complement one operand
//
//////////////////////////////////////////////////////////////////////////////////
// Revision:
// 07/29/2022 - I/O port names renamed with correct suffix
// 08/06/2022 - Add A_Zero_i signal to detect A is -0, in order to avoid false end round carry
//
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
