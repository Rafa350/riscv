module Comparator
# (
    parameter WIDTH = 32)
(
    input  logic [WIDTH-1:0] i_dataA,
    input  logic [WIDTH-1:0] i_dataB,
    output logic             o_isEqual,
    output logic             o_isLess);

    generate

        genvar i, j;

        localparam NUM_LEVELS = $clog2(WIDTH);

        for (i = 0; i < NUM_LEVELS; i++) begin: BLK1

            localparam NUM_BITS = WIDTH/(2**i)/2;

            logic isEqual[NUM_BITS];
            logic isLess[NUM_BITS];

            for (j = 0; j < NUM_BITS; j++) begin: BLK2

                // Primer nivell
                //
                if (i == 0) begin
                    Comparator_CMP cmp (
                        .i_dataA  (i_dataA[j+j+1:j+j]),
                        .i_dataB  (i_dataB[j+j+1:j+j]),
                        .o_isEqual (BLK1[i].isEqual[j]),
                        .o_isLess  (BLK1[i].isLess[j]));
                end

                // Ultim nivell
                //
                else if (i == NUM_LEVELS-1) begin
                    Comparator_CL cl(
                        .i_isEqualLSB (BLK1[i-1].isEqual[j+j]),
                        .i_isLessLSB  (BLK1[i-1].isLess[j+j]),
                        .i_isEqualMSB (BLK1[i-1].isEqual[j+j+1]),
                        .i_isLessMSB  (BLK1[i-1].isLess[j+j+1]),
                        .o_isEqual    (o_isEqual),
                        .o_isLess     (o_isLess));
                end

                // Nivells intermitjos
                //
                else begin
                    Comparator_CL cl(
                        .i_isEqualLSB (BLK1[i-1].isEqual[j+j]),
                        .i_isLessLSB  (BLK1[i-1].isLess[j+j]),
                        .i_isEqualMSB (BLK1[i-1].isEqual[j+j+1]),
                        .i_isLessMSB  (BLK1[i-1].isLess[j+j+1]),
                        .o_isEqual    (BLK1[i].isEqual[j]),
                        .o_isLess     (BLK1[i].isLess[j]));
                end
            end
        end
    endgenerate


endmodule


module Comparator_CMP (
    input  logic [1:0] i_dataA,
    input  logic [1:0] i_dataB,
    output logic       o_isEqual,
    output logic       o_isLess);

    assign o_isEqual =
        (~i_dataA[1] & ~i_dataA[0] & ~i_dataB[1] & ~i_dataB[0]) |
        (~i_dataA[1] &  i_dataA[0] & ~i_dataB[1] &  i_dataB[0]) |
        ( i_dataA[1] & ~i_dataA[0] &  i_dataB[1] & ~i_dataB[0]) |
        ( i_dataA[1] &  i_dataA[0] &  i_dataB[1] &  i_dataB[0]);

    assign o_isLess =
        (~i_dataA[1] & ~i_dataA[0] & i_dataB[0]) |
        (~i_dataA[1] &  i_dataB[1]) |
        ( i_dataA[1] & ~i_dataA[0] & i_dataB[1] & i_dataB[0]);

endmodule


module Comparator_CL (
    input  logic i_isEqualLSB,
    input  logic i_isLessLSB,
    input  logic i_isEqualMSB,
    input  logic i_isLessMSB,
    output logic o_isEqual,
    output logic o_isLess);

    assign o_isEqual = i_isEqualMSB & i_isEqualLSB;
    assign o_isLess = i_isLessMSB | (i_isEqualMSB & i_isLessLSB);

endmodule
