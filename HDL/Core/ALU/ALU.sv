module ALU
    import Types::*;
(
    input  AluOp i_op,      // Operacio

    input  Data  i_dataA,   // Operand A
    input  Data  i_dataB,   // Operand B

    output Data  o_result); // Resultat


    /*logic shiftDir;
    logic shiftSR;
    Data bs_result;

    BarrelShifter #(
        .WIDTH ($size(Data)))
    bs (
        .i_data (i_dataA),
        .i_bits (i_dataB[4:0]),
        .i_dir  (shiftDir),
        .i_sr   (shiftSR),
        .o_data (bs_result));*/


    always_comb begin

        //shiftDir = 0;
        //shiftSR  = 0;

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
                o_result = i_dataA << i_dataB[4:0];
                //o_result = bs_result;

            /*AluOp_SRA: begin
                shiftDir = 1'b1;
                shiftSR  = 1'b1;
                o_result = bs_result;
            end*/

            AluOp_SRL: begin
                o_result = i_dataA >> i_dataB[4:0];
                //shiftDir = 1'b1;
                //o_result = bs_result;
            end

            AluOp_SLT:
                o_result = Data'($signed(i_dataA) < $signed(i_dataB) ? 1 : 0);

            AluOp_SLTU:
                o_result = Data'($unsigned(i_dataA) < $unsigned(i_dataB) ? 1 : 0);

            default:
                o_result = 0;
        endcase
    end

  endmodule
