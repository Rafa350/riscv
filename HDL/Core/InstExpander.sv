module InstExpander
    import Types::*;
(
    input  Inst  i_inst,          // Instruccio comprimida
    output Inst  o_inst,          // Instruccio expandida
    output logic o_isIllegal,     // Indica si es il·legal.
    output logic o_isCompressed); // Indica si es comprimida

    always_comb begin

        o_inst         = i_inst;
        o_isIllegal    = 1'b0;
        o_isCompressed = 1'b1;

        unique casez ({i_inst[1:0], i_inst[15:13]})

            // c.addi4spn -> addi rd', x2, imm
            5'b00_000: begin
                o_inst = {2'b0, i_inst[10:7], i_inst[12:11], i_inst[5], i_inst[6], 2'b00, 5'h02, 3'b000, 2'b01, i_inst[4:2], OpCode_OpIMM};
                o_isIllegal = i_inst[12:5] == 8'b0;
            end

            // c.lw -> lw rd', imm(rs1')
            5'b00_010:
                o_inst = {5'b0, i_inst[5], i_inst[12:10], i_inst[6], 2'b00, 2'b01, i_inst[9:7], 3'b010, 2'b01, i_inst[4:2], OpCode_Load};

            // c.sw -> sw rs2', imm(rs1')
            5'b00_110:
                o_inst = {5'b0, i_inst[5], i_inst[12], 2'b01, i_inst[4:2], 2'b01, i_inst[9:7], 3'b010, i_inst[11:10], i_inst[6], 2'b00, OpCode_Store};

            // c.addi -> addi rd, rd, nzimm
            // c.nop
            5'b01_000:
                o_inst = {{6{i_inst[12]}}, i_inst[12], i_inst[6:2], i_inst[11:7], 3'b0, i_inst[11:7], OpCode_OpIMM};

            // c.jal -> jal x1, imm
            // c.j   -> jal x0, imm
            5'b01_001,
            5'b01_101:
                o_inst = {i_inst[12], i_inst[8], i_inst[10:9], i_inst[6], i_inst[7], i_inst[2], i_inst[11], i_inst[5:3], {9 {i_inst[12]}}, 4'b0, ~i_inst[15], OpCode_JAL};

            // c.li -> addi rd, x0, nzimm
            5'b01_010:
                o_inst = {{6 {i_inst[12]}}, i_inst[12], i_inst[6:2], 5'b0, 3'b0, i_inst[11:7], OpCode_OpIMM};

            5'b01_011: begin
                if (i_inst[11:7] == 5'h02)
                    // c.addi16sp -> addi x2, x2, nzimm
                    o_inst = {{3 {i_inst[12]}}, i_inst[4:3], i_inst[5], i_inst[2], i_inst[6], 4'b0, 5'h02, 3'b000, 5'h02, OpCode_OpIMM};
                else
                    // c.lui -> lui rd, imm
                    o_inst = {{15 {i_inst[12]}}, i_inst[6:2], i_inst[11:7], OpCode_LUI};
                o_isIllegal = {i_inst[12], i_inst[6:2]} == 6'b0;
            end

            5'b01_100: begin
                unique case (i_inst[11:10])
                    // c.srli -> srli rd, rd, shamt
                    // c.srai -> srai rd, rd, shamt
                    2'b00,
                    2'b01: begin
                        o_inst = {1'b0, i_inst[10], 5'b0, i_inst[6:2], 2'b01, i_inst[9:7], 3'b101, 2'b01, i_inst[9:7], OpCode_OpIMM};
                        o_isIllegal = i_inst[12] == 1'b1;
                    end

                    // c.andi -> andi rd, rd, imm
                    2'b10:
                        o_inst = {{6 {i_inst[12]}}, i_inst[12], i_inst[6:2], 2'b01, i_inst[9:7], 3'b111, 2'b01, i_inst[9:7], OpCode_OpIMM};

                    2'b11: begin
                        unique case ({i_inst[12], i_inst[6:5]})
                            // c.sub -> sub rd', rd', rs2'
                            3'b000:
                                o_inst = {2'b01, 5'b0, 2'b01, i_inst[4:2], 2'b01, i_inst[9:7], 3'b000, 2'b01, i_inst[9:7], OpCode_Op};

                            // c.xor -> xor rd', rd', rs2'
                            3'b001:
                                o_inst = {7'b0, 2'b01, i_inst[4:2], 2'b01, i_inst[9:7], 3'b100, 2'b01, i_inst[9:7], OpCode_Op};

                            // c.or  -> or  rd', rd', rs2'
                            3'b010:
                                o_inst = {7'b0, 2'b01, i_inst[4:2], 2'b01, i_inst[9:7], 3'b110, 2'b01, i_inst[9:7], OpCode_Op};

                            // c.and -> and rd', rd', rs2'
                            3'b011:
                                o_inst = {7'b0, 2'b01, i_inst[4:2], 2'b01, i_inst[9:7], 3'b111, 2'b01, i_inst[9:7], OpCode_Op};

                            default:
                                o_inst = i_inst;
                        endcase
                    end
                endcase
            end

            // c.beqz -> beq rs1', x0, imm
            // c.bnez -> bne rs1', x0, imm
            5'b01_110,
            5'b01_111:
                o_inst = {{4 {i_inst[12]}}, i_inst[6:5], i_inst[2], 5'b0, 2'b01, i_inst[9:7], 2'b00, i_inst[13], i_inst[11:10], i_inst[4:3], i_inst[12], OpCode_Branch};

            // c.slli -> slli rd, rd, shamt
            5'b10_000: begin
                o_inst = {7'b0, i_inst[6:2], i_inst[11:7], 3'b001, i_inst[11:7], OpCode_OpIMM};
                o_isIllegal = i_inst[12] == 1'b1;
            end

            // c.lwsp -> lw rd, imm(x2)
            5'b10_010: begin
                o_inst = {4'b0, i_inst[3:2], i_inst[12], i_inst[6:4], 2'b00, 5'h02, 3'b010, i_inst[11:7], OpCode_Load};
                o_isIllegal = i_inst[11:7] == 5'b0;
            end

            5'b10_100: begin
                if (i_inst[12] == 1'b0) begin
                    if (i_inst[6:2] != 5'b0) begin
                        // c.mv -> add rd/rs1, x0, rs2
                        o_inst = {7'b0, i_inst[6:2], 5'b0, 3'b0, i_inst[11:7], OpCode_Op};
                    end
                    else begin
                        // c.jr -> jalr x0, rd/rs1, 0
                        o_inst = {12'b0, i_inst[11:7], 3'b0, 5'b0, OpCode_JALR};
                        o_isIllegal = i_inst[11:7] == 5'b0;
                    end
                end
                else begin
                    if (i_inst[6:2] != 5'b0) begin
                        // c.add -> add rd, rd, rs2
                        o_inst = {7'b0, i_inst[6:2], i_inst[11:7], 3'b0, i_inst[11:7], OpCode_Op};
                    end
                    else begin
                        if (i_inst[11:7] == 5'b0) begin
                            // c.ebreak -> ebreak
                            o_inst = {32'h00_10_00_73};
                        end
                        else begin
                            // c.jalr -> jalr x1, rs1, 0
                            o_inst = {12'b0, i_inst[11:7], 3'b000, 5'b00001, OpCode_JALR};
                        end
                    end
                end
            end

            // c.swsp -> sw rs2, imm(x2)
            5'b10_110:
                o_inst = {4'b0, i_inst[8:7], i_inst[12], i_inst[6:2], 5'h02, 3'b010, i_inst[11:9], 2'b00, OpCode_Store};

            // No comprimides
            5'b11_???:
                o_isCompressed = 1'b0;

            // Il·legals
            default:
                o_isIllegal = 1'b1;
        endcase
    end

endmodule
