module PCAlu 
#(
    parameter DATA_WIDTH = 32,
    parameter PC_WIDTH   = 32)
(
    input  logic [1:0]            i_Op,      // Operacio
    
    input  logic [PC_WIDTH-1:0]   i_PC,      // PC
    input  logic [DATA_WIDTH-1:0] i_InstIMM, // Valor inmediat de la isntruccio
    input  logic [DATA_WIDTH-1:0] i_RegData, // Valor del registre base
    
    output logic [PC_WIDTH-1:0]   o_PC);     // El resultat
    
    logic [PC_WIDTH-1:0] Sel1_Output,
                         Sel2_Output;
    
    Mux2To1 #(
        .WIDTH (PC_WIDTH))
    Sel1 (
        .i_Select (i_Op[1]),
        .i_Input0 (i_PC),
        .i_Input1 (i_RegData[PC_WIDTH-1:0]),
        .o_Output (Sel1_Output));

    Mux2To1 #(
        .WIDTH (PC_WIDTH))
    Sel2 (
        .i_Select (i_Op[0]),
        .i_Input0 (4),
        .i_Input1 (i_InstIMM[PC_WIDTH-1:0]),
        .o_Output (Sel2_Output));
        
    HalfAdder #(
        .WIDTH (PC_WIDTH))
    adder (
        .i_OperandA (Sel1_Output),
        .i_OperandB (Sel2_Output),
        .o_Result   (o_PC));

endmodule
