`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:        Tzu-Han Hsu
// Create Date:     11/20/2023 05:03:25 PM
// Module Name:     TESTBED
// Project Name:    IEEE-754 & RISC-V Compatible Multiply-Accumulate Unit
// HDL(Version):    Verilog-2005
//
// Dependencies:    MAC32_top.v
//                  PATTERN.v
//
//////////////////////////////////////////////////////////////////////////////////
// Description:     Testbed of MAC32_top module, act as breadboard
//
//////////////////////////////////////////////////////////////////////////////////
// Revision:
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps

`include "PATTERN.v"
`ifdef RTL
    `include "MAC.v"
`endif
`ifdef GATE
    `include "MAC_SYN.v"
`endif

module TESTBED;

// parameter declaration
parameter PARM_RM       = 3,
parameter PARM_XLEN     = 32,
parameter PARM_RM_RNE   = 3'b000,
parameter PARM_RM_RTZ   = 3'b001,
parameter PARM_RM_RDN   = 3'b010,
parameter PARM_RM_RUP   = 3'b011,
parameter PARM_RM_RMM   = 3'b100

// interconnect wires delcarations
wire         clk, rst_n;

wire [PARM_RM - 1 : 0] Rounding_mode_wire;
wire [PARM_XLEN - 1 : 0] A_wire;
wire [PARM_XLEN - 1 : 0] B_wire;
wire [PARM_XLEN - 1 : 0] C_wire;

wire [PARM_XLEN - 1 : 0] Result_wire;
wire NV_wire;
wire OF_wire;
wire UF_wire;
wire NX_wire;

initial begin
    `ifdef RTL
        $fsdbDumpfile("MAC.fsdb");
        $fsdbDumpvars(0,"+mda");
    `endif
    `ifdef GATE
        $sdf_annotate("MAC_SYN.sdf", u_SUBWAY);
        $fsdbDumpfile("MAC_SYN.fsdb");
        $fsdbDumpvars(0,"+mda"); 
    `endif
end
 
PATTERN #(
    .PARM_RM (PARM_RM),
    .PARM_XLEN(PARM_XLEN),
    .PARM_RM_RNE(PARM_RM_RNE),
    .PARM_RM_RTZ(PARM_RM_RTZ),
    .PARM_RM_RDN(PARM_RM_RDN),
    .PARM_RM_RUP(PARM_RM_RUP),
    .PARM_RM_RMM(PARM_RM_RMM)
)u_PATTERN(
    .clk(clk),
    .rst_n(rst_n),

    .Rounding_mode_o(Rounding_mode_wire),
    .A_o(A_wire),
    .B_o(B_wire),
    .C_o(C_wire),

    .Result_i(Result_wire),
    
    //Accrued exceptions (fflags)
    .NV_i(NV_wire),
    .OF_i(OF_wire),
    .UF_i(UF_wire),
    .NX_i(NX_wire)
);

MAC32_top #(
    .PARM_RM (PARM_RM),
    .PARM_XLEN(PARM_XLEN),
    .PARM_RM_RNE(PARM_RM_RNE),
    .PARM_RM_RTZ(PARM_RM_RTZ),
    .PARM_RM_RDN(PARM_RM_RDN),
    .PARM_RM_RUP(PARM_RM_RUP),
    .PARM_RM_RMM(PARM_RM_RMM)
) u_MAC32_top (
    //input clk_i,
    //input rst_i,
    //input stall_i,
    //input req_i,

    .Rounding_mode_i(Rounding_mode_wire),
    .A_i(A_wire),
    .B_i(B_wire),
    .C_i(C_wire),

    .Result_o(Result_wire), // T (result_o) = A + (B * C)
    //output ready_o,
    
    //Accrued exceptions (fflags)
    .NV_o(NV_wire),
    .OF_o(OF_wire),
    .UF_o(UF_wire),
    .NX_o(NX_wire)
);

endmodule