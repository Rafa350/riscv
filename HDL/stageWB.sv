module stageWB 
#(
    parameter DATA_DBUS_WIDTH = 32) 
(
    input  logic i_clk,
    input  logic i_rst,
    
    input  logic [DATA_DBUS_WIDTH-1:0] i_AluOut,
    input  logic [DATA_DBUS_WIDTH-1:0] i_ReadData,
    input  logic                       i_MemToReg,
    
    output logic [DATA_DBUS_WIDTH-1:0] o_Result);

    mux2 #(
        .WIDTH(DATA_DBUS_WIDTH))
    mux(
        .i_sel (i_MemToReg),
        .i_in0 (i_AluOut),
        .i_in1 (i_ReadData),
        .o_out (o_Result));

endmodule
