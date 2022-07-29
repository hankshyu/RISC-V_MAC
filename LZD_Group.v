`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/29/2022 03:48:01 PM
// Design Name: 
// Module Name: LZD_Group
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


module LZD_Group(
    input [1:0] base_zero_i,
    output all_zero);

    assign all_zero = (base_zero_i == 2'b11);

endmodule


