`ifdef RTL
    `define CYCLE_TIME 20.0
`endif
`ifdef GATE
    `define CYCLE_TIME 20.0
`endif


module PATTERN #(
    parameter PARM_RM       = 3,
    parameter PARM_XLEN     = 32,
    parameter PARM_RM_RNE   = 3'b000,
    parameter PARM_RM_RTZ   = 3'b001,
    parameter PARM_RM_RDN   = 3'b010,
    parameter PARM_RM_RUP   = 3'b011,
    parameter PARM_RM_RMM   = 3'b100
) (
    output reg clk,
    output reg rst_n,

    output reg [PARM_RM - 1 : 0] Rounding_mode_i,
    output reg [PARM_XLEN - 1 : 0] A_i,
    output reg [PARM_XLEN - 1 : 0] B_i,
    output reg [PARM_XLEN - 1 : 0] C_i,

    input [PARM_XLEN - 1 : 0] Result_o, // T (result_o) = A + (B * C)
    //Accrued exceptions (fflags)
    input NV_o,
    input OF_o,
    input UF_o,
    input NX_o );

//================================================================
// integer
//================================================================
real CYCLE = `CYCLE_TIME;
integer SEED = 82; 

parameter PATNUM = 300;
integer total_latency;
integer patcount;
reg [1 : 0] map [64-1 : 0][4-1 : 0];
reg [1:0]init_in;
integer wait_val_time;
integer i;
integer cac; //check answer cycle

integer bonus_point;
integer sum_bonus;

reg [1:0] spotA, spotB, move;
reg [1:0] current_line;

integer resetted;

endmodule