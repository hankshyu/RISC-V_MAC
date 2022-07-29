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



module LZD_Group #(
    parameter XLEN = 2
) (
    input [XLEN - 1 : 0] group_data_i,
    output group_zero_o );

    assign group_zero_o = &group_data_i;
    
endmodule


