`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:        Tzu-Han Hsu
// Create Date:     07/29/2022 11:01:59 PM
// Module Name:     ZeroDetector_Base
// Project Name:    IEEE-754 & RISC-V Compatible Multiply-Accumulate Unit
// HDL(Version):    Verilog-2005
//
// Dependencies:    None
//
//////////////////////////////////////////////////////////////////////////////////
// Description:     Check if the input is all zero
//
//////////////////////////////////////////////////////////////////////////////////
// Revision:
//
//////////////////////////////////////////////////////////////////////////////////


module ZeroDetector_Base #(
    parameter XLEN = 8
) (
    input [XLEN - 1: 0] base_data_i,
    output zero_o );

    assign zero_o = (base_data_i == 8'd0);
    
endmodule