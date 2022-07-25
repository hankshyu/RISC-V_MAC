`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2022 03:15:31 PM
// Design Name: 
// Module Name: WallaceTree
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


module WallaceTree#(
    parameter PARM_MANT = 23
) (
    input [2*PARM_MANT + 2 : 0] pp_00_i,
    input [2*PARM_MANT + 2 : 0] pp_01_i,
    input [2*PARM_MANT + 2 : 0] pp_02_i,
    input [2*PARM_MANT + 2 : 0] pp_03_i,
    input [2*PARM_MANT + 2 : 0] pp_04_i,
    input [2*PARM_MANT + 2 : 0] pp_05_i,
    input [2*PARM_MANT + 2 : 0] pp_06_i,
    input [2*PARM_MANT + 2 : 0] pp_07_i,
    input [2*PARM_MANT + 2 : 0] pp_08_i,
    input [2*PARM_MANT + 2 : 0] pp_09_i,
    input [2*PARM_MANT + 2 : 0] pp_10_i,
    input [2*PARM_MANT + 2 : 0] pp_11_i,
    input [2*PARM_MANT + 2 : 0] pp_12_i,

    output [2*PARM_MANT + 2 : 0] wallace_sum_o,
    output [2*PARM_MANT + 2 : 0] wallace_carry_o,
    output suppression_sign_extension_o);


    wire  [2*PARM_MANT + 2 : 0] csa_sum [9 - 1: 0];
    wire  [2*PARM_MANT + 2 : 0] csa_carry [9 - 1: 0];
    
    wire  [2*PARM_MANT + 2 : 0] csa_shcy [9 - 1: 0];
    wire  [9 : 3] sign_extension;
    generate
        genvar i;
        for(i = 3; i < 9; i = i+1)begin
            assign sign_extension[i] = csa_carry[i][2*PARM_MANT + 2];
        end
    endgenerate

    generate
        genvar j;
        for(j = 0; j < 9; j = j+1)begin
            assign csa_shcy[j] = csa_carry[j] << 1;
        end
    endgenerate
    
    
    Compressor32 #(2*PARM_MANT + 3) LV1_0 (.A_i(pp_00_i),.B_i(pp_01_i),.C_i(pp_02_i),.Sum_o(csa_sum[0]),.Carry_o(csa_carry[0]));
    Compressor32 #(2*PARM_MANT + 3) LV1_1 (.A_i(pp_03_i),.B_i(pp_04_i),.C_i(pp_05_i),.Sum_o(csa_sum[1]),.Carry_o(csa_carry[1]));
    Compressor32 #(2*PARM_MANT + 3) LV1_2 (.A_i(pp_06_i),.B_i(pp_07_i),.C_i(pp_08_i),.Sum_o(csa_sum[2]),.Carry_o(csa_carry[2]));
    Compressor32 #(2*PARM_MANT + 3) LV1_3 (.A_i(pp_09_i),.B_i(pp_10_i),.C_i(pp_11_i),.Sum_o(csa_sum[3]),.Carry_o(csa_carry[3]));

    Compressor32 #(2*PARM_MANT + 3) LV2_0 (.A_i(csa_sum[0] ),.B_i(csa_shcy[0]),.C_i(csa_sum[1] ),.Sum_o(csa_sum[4]),.Carry_o(csa_carry[4]));
    Compressor32 #(2*PARM_MANT + 3) LV2_1 (.A_i(csa_shcy[1]),.B_i(csa_sum[2] ),.C_i(csa_shcy[2]),.Sum_o(csa_sum[5]),.Carry_o(csa_carry[5]));
    Compressor32 #(2*PARM_MANT + 3) LV2_2 (.A_i(csa_sum[3] ),.B_i(csa_shcy[3]),.C_i(pp_12_i    ),.Sum_o(csa_sum[6]),.Carry_o(csa_carry[6]));

    Compressor32 #(2*PARM_MANT + 3) LV3_0 (.A_i(csa_sum[4] ),.B_i(csa_shcy[4]),.C_i(csa_sum[5] ),.Sum_o(csa_sum[7]),.Carry_o(csa_carry[7]));
    Compressor32 #(2*PARM_MANT + 3) LV3_1 (.A_i(csa_shcy[5]),.B_i(csa_sum[6] ),.C_i(csa_shcy[6]),.Sum_o(csa_sum[8]),.Carry_o(csa_carry[8]));
    
    Compressor42 #(2*PARM_MANT + 3)
        LV4_Final (
            .A_i(csa_sum[7]),
            .B_i(csa_shcy[7]),
            .C_i(csa_sum[8]),
            .D_i(csa_shcy[8]),
            .Sum_o(wallace_sum_o),
            .Carry_o(wallace_carry_o),
            .hidden_carry_msb(sign_extension[9])
        );

    assign suppression_sign_extension_o = |sign_extension;

endmodule
