module DebugController
#(
    parameter DATA_WIDTH = 32,
    parameter REG_WIDTH  = 5,
    parameter PC_WIDTH   = 32)
(
    input  logic                  i_Clock,         // Clock
    input  logic                  i_Reset,         // Reset

    input  logic [7:0]            i_ExTag,         // Tag de la instruccio executada
    input  logic [PC_WIDTH-1:0]   i_ExPC,          // PC de la instruccio executada
    input  logic [31:0]           i_ExInst,        // Instruccio executada
    input  logic [REG_WIDTH-1:0]  i_ExRegWrAddr,   // Registre per escriure
    input  logic [DATA_WIDTH-1:0] i_ExRegWrData,   // Dades per escriure en registre
    input  logic                  i_ExRegWrEnable, // Habilita escriptura en el registre
    input  logic [REG_WIDTH-1:0]  i_ExMemWrAddr,   // Memoria per escriure
    input  logic [DATA_WIDTH-1:0] i_ExMemWrData,   // Dades per escriure en memoria
    input  logic                  i_ExMemWrEnable, // Habilita escriptura en memoria

    output logic [7:0]            o_Tag);          // Etiqueta generada


    always_ff @(posedge i_Clock)
        o_Tag <= i_Reset ? 8'h01 : o_Tag + 8'h01;


`ifdef VERILATOR

    import "DPI-C" function void TraceInstruction(input int addr, input int data);
    import "DPI-C" function void TraceRegister(input int addr, input int data);
    import "DPI-C" function void TraceMemory(input int addr, input int data);

    always_ff @(posedge i_Clock)
        if (!i_Reset & (i_ExTag != 8'h00)) begin
            // verilator lint_off WIDTH
            TraceInstruction(i_ExPC, i_ExInst);
            if ((i_ExRegWrAddr) != 0 & i_ExRegWrEnable)
                TraceRegister(i_ExRegWrAddr, i_ExRegWrData);
            if (i_ExMemWrEnable)
                TraceMemory(i_ExMemWrAddr, i_ExMemWrData);
            // verilator lint_on WIDTH
        end

`endif


endmodule
