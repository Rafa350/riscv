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
    logic comparator_isEqual;
    logic comparator_isLess;

    Comparator #(
        .WIDTH (WIDTH))
    comparator (
        .i_inputA  (i_inputA),
        .i_inputB  (i_inputB),
        .o_isEqual (comparator_isEqual),
        .o_isLess  (comparator_isLess));


    // Obte els signes (El bit MSB) dels valors
    logic signA;
    logic signB;
    assign signA = i_inputA[WIDTH-1];
    assign signB = i_inputB[WIDTH-1];


    // Evalua els resultats
    //
    always_comb begin

        o_isLessUnsigned = comparator_isLess;

        if (comparator_isEqual) begin
            o_isEqual = 1'b1;
            o_isLessSigned = 1'b0;
        end

        else if (comparator_isLess) begin
            o_isEqual = 1'b0;
            o_isLessSigned = ~signB;
        end

        else begin
            o_isEqual = 1'b0;
            o_isLessSigned = ~signA;
        end

    end

endmodule