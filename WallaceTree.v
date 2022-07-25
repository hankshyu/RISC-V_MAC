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

    parameter PARM_CSACOUNT = 10;

    wire  [2*PARM_MANT + 2 : 0] csa_sum [PARM_CSACOUNT - 1: 0];
    wire  [2*PARM_MANT + 2 : 0] csa_carry [PARM_CSACOUNT - 1: 0];
    
    wire  [2*PARM_MANT + 2 : 0] csa_shcy [PARM_CSACOUNT - 1: 0];
    wire  [PARM_CSACOUNT - 1: 0] csa_sig;
    generate
        genvar j;
        for(j = 0; j < PARM_CSACOUNT ;j = j+1)begin
            assign csa_shcy[j] = csa_carry[j] << 1;
            assign csa_sig[j] = csa_carry[j][2*PARM_MANT + 2];
        end
    endgenerate
    
    
    CarrySaveAdder #(2*PARM_MANT + 3) csa_LV1_0 (.A_i(pp_00_i),.B_i(pp_01_i),.C_i(pp_02_i),.Sum_o(csa_sum[0]),.Carry_o(csa_carry[0]));
    CarrySaveAdder #(2*PARM_MANT + 3) csa_LV1_1 (.A_i(pp_03_i),.B_i(pp_04_i),.C_i(pp_05_i),.Sum_o(csa_sum[1]),.Carry_o(csa_carry[1]));
    CarrySaveAdder #(2*PARM_MANT + 3) csa_LV1_2 (.A_i(pp_06_i),.B_i(pp_07_i),.C_i(pp_08_i),.Sum_o(csa_sum[2]),.Carry_o(csa_carry[2]));
    CarrySaveAdder #(2*PARM_MANT + 3) csa_LV1_3 (.A_i(pp_09_i),.B_i(pp_10_i),.C_i(pp_11_i),.Sum_o(csa_sum[3]),.Carry_o(csa_carry[3]));
    
    CarrySaveAdder #(2*PARM_MANT + 3) csa_LV2_4 (.A_i(csa_sum[0]),.B_i(csa_shcy[0]),.C_i(csa_sum[1]),.Sum_o(csa_sum[4]),.Carry_o(csa_carry[4]));
    CarrySaveAdder #(2*PARM_MANT + 3) csa_LV2_5 (.A_i(csa_shcy[1]),.B_i(csa_sum[2]),.C_i(csa_shcy[2]),.Sum_o(csa_sum[5]),.Carry_o(csa_carry[5]));
    CarrySaveAdder #(2*PARM_MANT + 3) csa_LV3_6 (.A_i(csa_sum[3]),.B_i(csa_shcy[3]),.C_i(csa_sum[4]),.Sum_o(csa_sum[6]),.Carry_o(csa_carry[6]));
    CarrySaveAdder #(2*PARM_MANT + 3) csa_LV3_7 (.A_i(csa_shcy[4]),.B_i(csa_sum[5]),.C_i(csa_shcy[5]),.Sum_o(csa_sum[7]),.Carry_o(csa_carry[7]));
    CarrySaveAdder #(2*PARM_MANT + 3) csa_LV4_8 (.A_i(csa_sum[6]),.B_i(csa_shcy[6]),.C_i(csa_sum[7]),.Sum_o(csa_sum[8]),.Carry_o(csa_carry[8]));
    CarrySaveAdder #(2*PARM_MANT + 3) csa_LV5_9 (.A_i(csa_shcy[7]),.B_i(csa_shcy[8]),.C_i(csa_sum[8]),.Sum_o(csa_sum[9]),.Carry_o(csa_carry[9]));

    //answer producer
    CarrySaveAdder #(2*PARM_MANT + 3) csa_Final (.A_i(csa_sum[9]),.B_i(csa_shcy[9]),.C_i(pp_12_i),.Sum_o(pp_sum_o),.Carry_o(pp_carry_o)); 

    assign msb_cor_o = | csa_sig[9:3];

endmodule
