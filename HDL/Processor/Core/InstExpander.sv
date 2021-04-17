module InstExpander
    import CoreDefs::*;
(
    input  Inst  i_inst,          // Instruccio comprimida
    output Inst  o_inst,          // Instruccio expandida
    output logic o_isCompressed); // Indica si es comprimida

    Inst inst;
    logic bad;

    assign o_inst         = bad ? i_inst : inst;
    assign o_isCompressed = !bad;

    always_comb begin

        bad  = 1'b0;
        inst = i_inst;

        unique casez ({i_inst[15:13], i_inst[1:0]})

            // c.addi4spn -> addi rd', x2, imm
            5'b000_00:
                begin
                    inst = {2'b0, i_inst[10:7], i_inst[12:11], i_inst[5], i_inst[6], 2'b00, 5'h02, 3'b000, 2'b01, i_inst[4:2], OpCode_OpIMM};
                    bad = i_inst[12:5] == 8'b0;
                end

            // c.lw -> lw rd', imm(rs1')
            5'b010_00:
                inst = {5'b0, i_inst[5], i_inst[12:10], i_inst[6], 2'b00, 2'b01, i_inst[9:7], 3'b010, 2'b01, i_inst[4:2], OpCode_Load};

            // c.sw -> sw rs2', imm(rs1')
            5'b110_00:
                inst = {5'b0, i_inst[5], i_inst[12], 2'b01, i_inst[4:2], 2'b01, i_inst[9:7], 3'b010, i_inst[11:10], i_inst[6], 2'b00, OpCode_Store};

            // c.addi -> addi rd, rd, nzimm
            // c.nop
            5'b000_01:
                inst = {{6{i_inst[12]}}, i_inst[12], i_inst[6:2], i_inst[11:7], 3'b0, i_inst[11:7], OpCode_OpIMM};

            // c.jal -> jal x1, imm
            // c.j   -> jal x0, imm
            5'b001_01,
            5'b101_01:
                inst = {i_inst[12], i_inst[8], i_inst[10:9], i_inst[6], i_inst[7], i_inst[2], i_inst[11], i_inst[5:3], {9 {i_inst[12]}}, 4'b0, ~i_inst[15], OpCode_JAL};

            // c.li -> addi rd, x0, nzimm
            5'b010_01:
                begin
                    inst = {{6 {i_inst[12]}}, i_inst[12], i_inst[6:2], 5'b0, 3'b0, i_inst[11:7], OpCode_OpIMM};
                    bad = i_inst[11:7] == 5'b0;
                end

            5'b011_01:
                begin
                    if (i_inst[11:7] == 5'h02)
                        // c.addi16sp -> addi x2, x2, nzimm
                        inst = {{3 {i_inst[12]}}, i_inst[4:3], i_inst[5], i_inst[2], i_inst[6], 4'b0, 5'h02, 3'b000, 5'h02, OpCode_OpIMM};
                    else
                        // c.lui -> lui rd, imm
                        inst = {{15 {i_inst[12]}}, i_inst[6:2], i_inst[11:7], OpCode_LUI};
                    bad = {i_inst[12], i_inst[6:2]} == 6'b0;
                end

            5'b100_01:
                unique casez ({i_inst[12], i_inst[11:10], i_inst[6:5]})
                    // c.srli -> srli rd, rd, shamt
                    // c.srai -> srai rd, rd, shamt
                    5'b0_00_??,
                    5'b0_01_??:
                        inst = {1'b0, i_inst[10], 5'b0, i_inst[6:2], 2'b01, i_inst[9:7], 3'b101, 2'b01, i_inst[9:7], OpCode_OpIMM};

                    // c.andi -> andi rd, rd, imm
                    5'b?_10_??:
                        inst = {{6 {i_inst[12]}}, i_inst[12], i_inst[6:2], 2'b01, i_inst[9:7], 3'b111, 2'b01, i_inst[9:7], OpCode_OpIMM};

                    // c.sub -> sub rd', rd', rs2'
                    5'b0_11_00:
                        inst = {2'b01, 5'b0, 2'b01, i_inst[4:2], 2'b01, i_inst[9:7], 3'b000, 2'b01, i_inst[9:7], OpCode_Op};

                    // c.xor -> xor rd', rd', rs2'
                    5'b0_11_01:
                        inst = {7'b0, 2'b01, i_inst[4:2], 2'b01, i_inst[9:7], 3'b100, 2'b01, i_inst[9:7], OpCode_Op};

                    // c.or  -> or  rd', rd', rs2'
                    5'b0_11_10:
                        inst = {7'b0, 2'b01, i_inst[4:2], 2'b01, i_inst[9:7], 3'b110, 2'b01, i_inst[9:7], OpCode_Op};

                    // c.and -> and rd', rd', rs2'
                    5'b0_11_11:
                        inst = {7'b0, 2'b01, i_inst[4:2], 2'b01, i_inst[9:7], 3'b111, 2'b01, i_inst[9:7], OpCode_Op};

                    default:
                        bad = 1'b1;

                endcase

            // c.beqz -> beq rs1', x0, imm
            // c.bnez -> bne rs1', x0, imm
            5'b110_01,
            5'b111_01:
                inst = {{4 {i_inst[12]}}, i_inst[6:5], i_inst[2], 5'b0, 2'b01, i_inst[9:7], 2'b00, i_inst[13], i_inst[11:10], i_inst[4:3], i_inst[12], OpCode_Branch};

            // c.slli -> slli rd, rd, shamt
            5'b000_10:
                begin
                    inst = {7'b0, i_inst[6:2], i_inst[11:7], 3'b001, i_inst[11:7], OpCode_OpIMM};
                    bad = i_inst[12] == 1'b1;
                end

            // c.lwsp -> lw rd, imm(x2)
            5'b010_10:
                begin
                    inst = {4'b0, i_inst[3:2], i_inst[12], i_inst[6:4], 2'b00, 5'h02, 3'b010, i_inst[11:7], OpCode_Load};
                    bad = i_inst[11:7] == 5'b0;
                end

            5'b100_10:
                begin
                    if (i_inst[12] == 1'b0) begin
                        if (i_inst[6:2] != 5'b0) begin
                            // c.mv -> add rd/rs1, x0, rs2
                            inst = {7'b0, i_inst[6:2], 5'b0, 3'b0, i_inst[11:7], OpCode_Op};
                        end
                        else begin
                            // c.jr -> jalr x0, rd/rs1, 0
                            inst = {12'b0, i_inst[11:7], 3'b0, 5'b0, OpCode_JALR};
                            bad = i_inst[11:7] == 5'b0;
                        end
                    end
                    else begin
                        if (i_inst[6:2] != 5'b0) begin
                            // c.add -> add rd, rd, rs2
                            inst = {7'b0, i_inst[6:2], i_inst[11:7], 3'b0, i_inst[11:7], OpCode_Op};
                        end
                        else begin
                            if (i_inst[11:7] == 5'b0) begin
                                // c.ebreak -> ebreak
                                inst = {32'h00_10_00_73};
                            end
                            else begin
                                // c.jalr -> jalr x1, rs1, 0
                                inst = {12'b0, i_inst[11:7], 3'b000, 5'b00001, OpCode_JALR};
                            end
                        end
                    end
                end

            // c.swsp -> sw rs2, imm(x2)
            5'b110_10:
                inst = {4'b0, i_inst[8:7], i_inst[12], i_inst[6:2], 5'h02, 3'b010, i_inst[11:9], 2'b00, OpCode_Store};

            // Il·legals
            default:
                bad = 1'b1;
        endcase
    end

endmodule
