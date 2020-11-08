module stageWB 
#(
    parameter DATA_DBUS_WIDTH = 32) 
(
    input  logic                       i_Clock,
    input  logic                       i_Reset,
    
    input  logic [DATA_DBUS_WIDTH-1:0] i_AluOut,
    input  logic [DATA_DBUS_WIDTH-1:0] i_ReadData,
    input  logic                       i_MemToReg,
    
    output logic [DATA_DBUS_WIDTH-1:0] o_Result);

    Mux2To1 #(
        .WIDTH(DATA_DBUS_WIDTH))
    mux(
        .i_Select (i_MemToReg),
        .i_Input0 (i_AluOut),
        .i_Input1 (i_ReadData),
        .o_Output (o_Result));

endmodule
