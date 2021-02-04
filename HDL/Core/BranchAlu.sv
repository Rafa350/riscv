module BranchAlu
    import Types::*;
(
    input  logic [1:0] i_op,      // Operacio

    input  InstAddr    i_pc,      // PC
    input  Data        i_instIMM, // Valor inmediat de la instruccio
    input  Data        i_regData, // Valor del registre base

    output InstAddr    o_pc);     // El resultat

    always_comb
        unique case (i_op)
            2'b00: o_pc = i_pc + 4;
            2'b01: o_pc = i_pc + i_instIMM;
            2'b10: o_pc = i_regData + 4;
            2'b11: o_pc = i_regData + i_instIMM;
        endcase

endmodule
