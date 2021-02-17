module Comparator
# (
    parameter WIDTH = 32)
(
    input  logic [WIDTH-1:0] i_inputA,
    input  logic [WIDTH-1:0] i_inputB,
    output logic             o_isEqual,
    output logic             o_isLess);

    generate

        localparam NUM_LEVELS = $clog2(WIDTH);

        genvar level;
        for (level = 0; level < NUM_LEVELS; level++) begin: L

            localparam NUM_BITS = WIDTH/(2**level)/2;

            logic isEqual[WIDTH/(2**level)/2];
            logic isLess[WIDTH/(2**level)/2];

            genvar bits;
            for (bits = 0; bits < NUM_BITS; bits++) begin: C

                // Primer nivell
                //
                if (level == 0) begin
                    CMP cmp (
                        .i_inputA  (i_inputA[2*bits+1:2*bits]),
                        .i_inputB  (i_inputB[2*bits+1:2*bits]),
                        .o_isEqual (L[level].isEqual[bits]),
                        .o_isLess  (L[level].isLess[bits]));
                end

                // Ultim nivell
                //
                else if (level == $clog2(WIDTH)-1) begin
                    CL cl(
                        .i_isEqualLSB (L[level-1].isEqual[bits*2]),
                        .i_isLessLSB  (L[level-1].isLess[bits*2]),
                        .i_isEqualMSB (L[level-1].isEqual[bits*2+1]),
                        .i_isLessMSB  (L[level-1].isLess[bits*2+1]),
                        .o_isEqual    (o_isEqual),
                        .o_isLess     (o_isLess));
                end

                // Nivells intermitjos
                //
                else begin
                    CL cl(
                        .i_isEqualLSB (L[level-1].isEqual[bits*2]),
                        .i_isLessLSB  (L[level-1].isLess[bits*2]),
                        .i_isEqualMSB (L[level-1].isEqual[bits*2+1]),
                        .i_isLessMSB  (L[level-1].isLess[bits*2+1]),
                        .o_isEqual    (L[level].isEqual[bits]),
                        .o_isLess     (L[level].isLess[bits]));
                end
            end
        end
    endgenerate


endmodule


module CMP (
    input  logic [1:0] i_inputA,
    input  logic [1:0] i_inputB,
    output logic       o_isEqual,
    output logic       o_isLess);

    assign o_isEqual =
        (~i_inputA[1] & ~i_inputA[0] & ~i_inputB[1] & ~i_inputB[0]) |
        (~i_inputA[1] &  i_inputA[0] & ~i_inputB[1] &  i_inputB[0]) |
        ( i_inputA[1] & ~i_inputA[0] &  i_inputB[1] & ~i_inputB[0]) |
        ( i_inputA[1] &  i_inputA[0] &  i_inputB[1] &  i_inputB[0]);

    assign o_isLess =
        (~i_inputA[1] &  i_inputB[1]) |
        (~i_inputA[1] &  i_inputA[0] & i_inputB[1]) |
        (~i_inputA[1] & ~i_inputA[0] & i_inputB[0]);

endmodule


module CL (
    input  logic i_isEqualLSB,
    input  logic i_isLessLSB,
    input  logic i_isEqualMSB,
    input  logic i_isLessMSB,
    output logic o_isEqual,
    output logic o_isLess);

    assign o_isEqual = i_isEqualMSB & i_isEqualLSB;
    assign o_isLess = i_isLessMSB | (i_isEqualMSB & i_isLessLSB);

endmodule
