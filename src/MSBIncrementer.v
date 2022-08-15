`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:        Tzu-Han Hsu
// Create Date:     07/29/2022 10:53:38 AM
// Module Name:     MSBIncrementer
// Project Name:    IEEE-754 & RISC-V Compatible Multiply-Accumulate Unit
// HDL(Version):    Verilog-2005
//
// Dependencies:    None
//
//////////////////////////////////////////////////////////////////////////////////
// Description:    Increments A_High if needed by the A_Low carry signal
//
//////////////////////////////////////////////////////////////////////////////////
// Revision:
//
//////////////////////////////////////////////////////////////////////////////////


module MSBIncrementer #(
    parameter PARM_MANT = 23
) (
    input low_carry_i,
    input low_carry_inv_i,
    input [PARM_MANT + 3 : 0]   A_Mant_aligned_high_i, 

    output [PARM_MANT + 3 : 0]  high_sum_o,
    output [PARM_MANT + 3 : 0]  high_sum_inv_o
);
    wire high_carry;        // signal that is abandoned
    wire high_carry_inv;    // signal that is abandoned
    
    assign {high_carry, high_sum_o} = (low_carry_i)? A_Mant_aligned_high_i + 1 : A_Mant_aligned_high_i;
    assign {high_carry_inv, high_sum_inv_o} = (low_carry_inv_i)? ~A_Mant_aligned_high_i : ~A_Mant_aligned_high_i - 1;

endmodule
