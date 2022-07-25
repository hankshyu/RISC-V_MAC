`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2022 10:13:32 AM
// Design Name: 
// Module Name: FullAdder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
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
