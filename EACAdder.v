`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/29/2022 10:40:06 AM
// Design Name: 
// Module Name: EACAdder
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


module EACAdder #(
    parameter PARM_MANT = 23
) (
    input [2*PARM_MANT + 1 : 0] CSA_sum_i,
    input [2*PARM_MANT + 1 : 0] CSA_carry_i,
    input Carry_postcor_i,
    input Sub_Sign_i,    

    output [2*PARM_MANT + 1 : 0] low_sum_o,
    output low_carry_o,
    output [2*PARM_MANT + 1 : 0] low_sum_inv_o,
    output low_carry_inv_o);

    assign {low_carry, low_sum} =  CSA_sum_i + {Carry_postcor_i, CSA_carry_i[2*PARM_MANT : 0], Sub_Sign_i};
    assign {low_carry_inv, low_sum_inv} = 2'b10 + {1'b1, ~CSA_sum_i} + {~Carry_postcor_i, ~CSA_carry_i[2*PARM_MANT : 0], ~Sub_Sign_i};

endmodule
