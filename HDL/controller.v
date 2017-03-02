/*************************************************************************
 *
 *       Modul de control de la CPU
 *
 *       Parametres:
 *           DATA_WIDTH : Amplada del bus de dades
 *           ADDR_WIDTH : Amplada del bus d'adresses
 *
 *       Entrades:
 *           rst        : Reset
 *           inst       : Instruccio a decodificar
 *           zero       : Indica si el resultat es zero
 *
 *       Sortides:
 *           pc_le      : Autoritza la carrega del contador de programa
 *           pc_in_sel  : Seleccio de la entrada al contador de programa
 *           ram_we     : Autoritza la escriptura en la RAM
 *           rstk_we    : Autoritza la carrega en la pila de retorn
 *           rstk_me    : Autoritza el moviment en la pila de retorn
 *           rstk_md    : Indica el sentit del moviment (UP/DOWN) de la pila de retorn
 *           dstk_we    : Autoritza la carrega en la pila de dades
 *           dstk_me    : Autoritza el moviment en la pila de dades
 *           dstk_md    : Indica el sentit del moviment (UP/DOWN) de la pila de dades
 *           imm_data   : Dades inmediates en la instruccio
 *           imm_addr   : Adressa inmediata en la instruccio
 *           alu_op     : Operacio a realitzar en la ALU
 *           alu_inB_sel: Selecciona l'operand B d'entrada a la ALU
 *
 *
 *       +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
 *       | F | E | D | C | B | A | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
 * +-----+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
 * | LIT | 1 | data                                                      |
 * +-----+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
 * | JMP | 0   0   0 | S | address                                       |
 * +-----+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
 * | BRZ | 0   0   1 | S | address                                       |
 * +-----+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
 * | JSR | 0   1   0 |   | address                                       |
 * +-----+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
 * | DO  | 0   1   1 | R | op-code       |   | mov       |rmd|rme|dmd|dme|
 * +-----+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
 *
 *************************************************************************/

 
`include "alu.vh"
 
 
module controller
#(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 16)
(
    input rst,
    input [15:0] inst,
    input zero,
    output pc_le,
    output pc_in_sel,
    output ram_we,
    output rstk_we,
    output rstk_me,
    output rstk_md,
    output dstk_we,
    output dstk_me,
    output dstk_md,
    output [ADDR_WIDTH-1:0] imm_addr,
    output [DATA_WIDTH-1:0] imm_data,
    output [3:0] alu_op,
    output [1:0] alu_inB_sel);
    
    wire is_lit = inst[15];
    wire is_jmp = !inst[15] & !inst[14] & !inst[13];
    wire is_brz = !inst[15] & !inst[14] & inst[13];
    wire is_jsr = !inst[15] & inst[14] & !inst[13];
    wire is_do = !inst[15] & inst[14] & inst[13];

    wire is_TtoN = !inst[6] & !inst[5] & inst[4]; 
    wire is_TtoR = !inst[6] & inst[5] & !inst[4]; 
    wire is_NtoMEM = !inst[6] & inst[5] & inst[4]; 
    //wire is_NtoIO = inst[6] & !inst[5] & !inst[4];  
    wire is_RtoPC = inst[12];
    
    // Genera la senyals de control del contador de programa
    // pc_le    : Program counter load enable
    // pc_in_sel: Program counter input selection
    //
    always_comb begin
        if (!rst & is_jmp)
            {pc_le, pc_in_sel} = {2'b10};
        else if (!rst & is_brz)
            {pc_le, pc_in_sel} = {zero, 1'b0};
        else if (!rst & is_jsr)
            {pc_le, pc_in_sel} = {2'b10};
        else if (!rst & is_do)
            {pc_le, pc_in_sel} = {is_RtoPC, 1'b1};
        else
            {pc_le, pc_in_sel} = {2'b00};
    end
    
    // Genera les senyals de control de la pila de retorn
    // rstk_we: R-Stack write enable
    // rstd_me: R-Stack move enable
    // rstk_md: R-Stack move direction
    //
    always_comb begin
        if (!rst & is_jsr)
            {rstk_we, rstk_me, rstk_md} = {3'b110};
        else if (!rst & is_do)
            {rstk_we, rstk_me, rstk_md} = {is_TtoR, inst[2], inst[3]};
        else
            {rstk_we, rstk_me, rstk_md} = {3'b000};
    end
    
    // Genera les senyals de control de la pila de dades
    // dstk_we: D-Stack write enable
    // dstd_me: D-Stack move enable
    // dstk_md: D-Stack move direction
    //
    always_comb begin
        if (!rst & is_lit)
            {dstk_we, dstk_me, dstk_md} = {3'b110};
        else if (!rst & is_do)    
            {dstk_we, dstk_me, dstk_md} = {is_TtoN, inst[0], inst[1]};
        else
            {dstk_we, dstk_me, dstk_md} = {3'b000};
    end
    
    // Genera les senyals de control de la RAM
    //
    assign ram_we = !rst & is_do & is_NtoMEM;
    
    // Genera les senyals de control de la IO
    //
    
    // Genera les senyals de control de la ALU
    // alu_op: ALU op-code
    //
    always_comb begin
        if (!rst & is_do)
            case (inst[11:8]) 
                4'b0000: alu_op = `ALU_OP_A;
                4'b0001: alu_op = `ALU_OP_B;
                4'b0010: alu_op = `ALU_OP_AaddB;
                4'b0011: alu_op = `ALU_OP_AandB;
                4'b0100: alu_op = `ALU_OP_AorB;
                4'b0101: alu_op = `ALU_OP_AxorB;
                4'b0110: alu_op = `ALU_OP_notA;
                4'b0111: alu_op = `ALU_OP_AeqB;
                4'b1000: alu_op = `ALU_OP_AgtB;
                4'b1001: alu_op = `ALU_OP_BshlA;
                4'b1010: alu_op = `ALU_OP_Adec;
                4'b1101: alu_op = `ALU_OP_BshrA;
                default: alu_op = `ALU_OP_A;
            endcase
        else
            alu_op = `ALU_OP_A;
    end
    
    always_comb begin
        if (!rst & is_lit)
            alu_inB_sel = 2'b01;
        else if (!rst & is_do & (inst[11:8] == 4'b1011))
            alu_inB_sel = 2'b10;
        else if (!rst & is_do & (inst[11:8] == 4'b1100))
            alu_inB_sel = 2'b11;
        else 
            alu_inB_sel = 2'b00;
    end
    
    // Obte els parametres immediats de les instruccions
    //
    assign imm_data = {{DATA_WIDTH-15{1'b0}}, inst[14:0]};
    assign imm_addr = inst[ADDR_WIDTH-1:0];
    
endmodule
    