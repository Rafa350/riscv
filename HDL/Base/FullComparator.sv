module FullComparator
#(
    parameter WIDTH = 32)
(
    input  logic [WIDTH-1:0] i_dataA,
    input  logic [WIDTH-1:0] i_dataB,
    output logic             o_isEqual,
    output logic             o_isLessSigned,
    output logic             o_isLessUnsigned);


    // Compara els valors sense tindre en compte el signe
    //
    Comparer #(
        .WIDTH (WIDTH))
    comparer (
        .i_dataA   (i_dataA),
        .i_dataB   (i_dataB),
        .o_isEqual (o_isEqual),
        .o_isLess  (o_isLessUnsigned));

    // Evalua els resultats amb signe
    //
    always_comb begin
        if (o_isEqual)
            o_isLessSigned = 1'b0;
        else if (o_isLessUnsigned)
            o_isLessSigned = ~i_dataB[WIDTH-1];
        else
            o_isLessSigned = i_dataA[WIDTH-1];
    end

endmodule