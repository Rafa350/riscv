module Decoder_RV32I
    import Types::*;
#(
    parameter DATA_WIDTH = 32,
    parameter REG_WIDTH  = 5)
 (
    input  logic [31:0]           i_Inst,      // La instruccio a decodificar
    output Types::OpCode          o_OP,        // El codi d'operacio
    output logic [REG_WIDTH-1:0]  o_RS1,       // El registre font 1 (rs1)
    output logic [REG_WIDTH-1:0]  o_RS2,       // El registre fomt 2 (rs2)
    output logic [REG_WIDTH-1:0]  o_RD,        // El registre de destinacio  (rd)
    output logic [DATA_WIDTH-1:0] o_IMM,       // El valor inmediat
    output logic                  o_IsLoad,    // Indica que es una instruccio LOAD
    output logic                  o_IsALU,     // Indica que es una instruccio ALU
    output logic                  o_IsECALL,   // Indica instruccio ECALL
    output logic                  o_IsEBREAK); // Indica instruccio EBREAK
 

    // Evalua el valor IMM
    //
    always_comb begin
        unique casez ({i_Inst[14:12], i_Inst[6:0]})
            {3'b???, OpCode_LUI  }, // LUI
            {3'b???, OpCode_AUIPC}: // AUIPC
                o_IMM = {i_Inst[31:12], 12'b0};

            {3'b???, OpCode_JAL  }: // JAL
                o_IMM = {{12{i_Inst[31]}}, i_Inst[19:12], i_Inst[20], i_Inst[30:21], 1'b0};

            {3'b???, OpCode_Branch}: // Branch
                o_IMM = {{20{i_Inst[31]}}, i_Inst[7], i_Inst[30:25], i_Inst[11:8], 1'b0};

            {3'b001, OpCode_OpIMM}, // SLLI
            {3'b101, OpCode_OpIMM}: // SRLI/SRAI
                o_IMM = {{27{1'b0}}, i_Inst[24:20]}; // Sempre positiu

            {3'b???, OpCode_Load}, // Load
            {3'b000, OpCode_OpIMM}, // ADDI
            {3'b010, OpCode_OpIMM}, // SLTI
            {3'b011, OpCode_OpIMM}, // SLTIU
            {3'b100, OpCode_OpIMM}, // XORI
            {3'b110, OpCode_OpIMM}, // ORI
            {3'b111, OpCode_OpIMM}, // ANDI
            {3'b000, OpCode_JALR}: // JALR
                o_IMM = {{20{i_Inst[31]}}, i_Inst[31:20]};

            {3'b???, OpCode_Store}: // Store
                o_IMM = {{20{i_Inst[31]}}, i_Inst[31:25], i_Inst[11:7]};

            default:
                o_IMM = 32'b0;
        endcase

    end


    // Evalua el codi d'operacio
    //
    assign o_OP = Types::OpCode'(i_Inst[6:0]);


    // Evalua els registres de la instruccio
    //
    assign o_RS1 = i_Inst[REG_WIDTH+14:15];
    assign o_RS2 = i_Inst[REG_WIDTH+19:20];
    assign o_RD  = i_Inst[REG_WIDTH+6:7];


    // Evalua els indicadors del tipus d'instruccio
    //
    assign o_IsLoad   = i_Inst[6:0] == OpCode_Load;
    assign o_IsALU    = (i_Inst[6:0] == OpCode_Op) | (i_Inst[6:0] == OpCode_OpIMM);
    assign o_IsECALL  = (i_Inst[6:0] == OpCode_System) & (i_Inst[14:12] == 3'b001);
    assign o_IsEBREAK = (i_Inst[6:0] == OpCode_System) & (i_Inst[14:12] == 3'b000);

endmodule
