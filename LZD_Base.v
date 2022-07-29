`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/29/2022 03:48:01 PM
// Design Name: 
// Module Name: LZD_Base
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



module LZD_Base #(
    parameter XLEN = 8
) (
    input [XLEN - 1: 0] data_i,
    output zero_i );

    assign zero_i = (data_i == 8'd0);
    
endmodule