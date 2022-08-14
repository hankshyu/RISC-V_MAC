`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:        Tzu-Han Hsu
// Create Date:     07/22/2022 10:13:32 AM
// Module Name:     FullAdder
// Project Name:    IEEE-754 & RISC-V Compatible Multiply-Accumulate Unit
// RTL Language:    Verilog-2005
//
// Dependencies:    None
//
//////////////////////////////////////////////////////////////////////////////////
// Description:     A full Adder module, with 3 input and 2 output
//
//////////////////////////////////////////////////////////////////////////////////
// Revision:
// 07/25/2022 - Output ports naming inconsistent with definition, bug fixed
//
//////////////////////////////////////////////////////////////////////////////////


module FullAdder(
    input augend_i,
    input addend_i,
    input carry_i,
    output sum_o,
    output carry_o);

    assign sum_o = augend_i ^ addend_i ^ carry_i;
    assign carry_o = (augend_i & addend_i) || (addend_i & carry_i) || (carry_i & augend_i);

endmodule
