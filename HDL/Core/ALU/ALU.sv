module ALU
    import Types::*;
(
    input  AluOp i_op,      // Operacio

    input  Data  i_dataA,   // Operand A
    input  Data  i_dataB,   // Operand B

    output Data  o_result); // Resultat


    always_comb begin
        case (i_op)
            AluOp_ADD:
                o_result = i_dataA + i_dataB;

            AluOp_SUB:
                o_result = i_dataA - i_dataB;

            AluOp_AND:
                o_result = i_dataA & i_dataB;

            AluOp_OR:
                o_result = i_dataA | i_dataB;

            AluOp_XOR:
                o_result = i_dataA ^ i_dataB;

            AluOp_SLL:
                o_result = i_dataA << (i_dataB & 32'h1F);

            AluOp_SLT:
                o_result = Data'($signed(i_dataA) < $signed(i_dataB) ? 1 : 0);

            AluOp_SLTU:
                o_result = Data'($unsigned(i_dataA) < $unsigned(i_dataB) ? 1 : 0);

            default:
                o_result = 0;
        endcase
    end

  endmodule
