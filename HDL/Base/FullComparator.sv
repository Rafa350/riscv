module FullComparator
#(
    parameter WIDTH = 32)
(
    input  logic [WIDTH-1:0] i_inputA,
    input  logic [WIDTH-1:0] i_inputB,
    output logic             o_isEqual,
    output logic             o_isLessSigned,
    output logic             o_isLessUnsigned);


    // Compara els valors sense tindre en compte el signe
    //
    Comparator #(
        .WIDTH (WIDTH))
    comparator (
        .i_inputA  (i_inputA),
        .i_inputB  (i_inputB),
        .o_isEqual (o_isEqual),
        .o_isLess  (o_isLessUnsigned));

    // Evalua els resultats amb signe
    //
    always_comb begin
        if (o_isEqual)
            o_isLessSigned = 1'b0;
        else if (o_isLessUnsigned)
            o_isLessSigned = ~i_inputB[WIDTH-1];
        else
            o_isLessSigned = i_inputA[WIDTH-1];
    end

endmodule