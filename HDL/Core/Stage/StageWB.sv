`include "RV.svh"


module StageWB
    import Types::*;
(
    input  Data    i_regWrData,
    input  RegAddr i_regWrAddr,
    input  logic   i_regWrEnable,

    output Data    o_regWrData,
    output RegAddr o_regWrAddr,
    output logic   o_regWrEnable);


    assign o_regWrData   = i_regWrData;
    assign o_regWrAddr   = i_regWrAddr;
    assign o_regWrEnable = i_regWrEnable;

endmodule
