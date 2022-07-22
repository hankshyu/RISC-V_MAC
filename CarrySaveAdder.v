`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2022 10:09:16 AM
// Design Name: 
// Module Name: CarrySaveAdder
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


module CarrySaveAdder #(
    parameter XLEN = 49
) (
    input [XLEN - 1 : 0] A_i,
    input [XLEN - 1 : 0] B_i,
    input [XLEN - 1 : 0] C_i,
    output [XLEN - 1 : 0] Sum_o,
    output [XLEN - 1 : 0] Cy_o
);
    generate
        genvar j;
        for(j = 0; j < XLEN; j = j+1)begin
            FullAdder FA(
                .augend_i(A_i[j]),
                .addend_i(B_i[j]),
                .carry_i(C_i[j]),
                .sum_o(Sum_o[j]),
                .carry_o(Cy_o[j])
            );
            
        end
    endgenerate

    
endmodule
