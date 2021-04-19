module BranchComparer
    import Config::*,
           ProcessorDefs::*;
(
    input  Data  i_dataRS1,
    input  Data  i_dataRS2,

    output logic o_isEqual,
    output logic o_isLessSigned,
    output logic o_isLessUnsigned);


    localparam bit FAST = 1;

    generate
        if (FAST == 1) begin
            FullComparer #(
                .WIDTH($size(Data)))
            comparator (
                .i_dataA          (i_dataRS1),
                .i_dataB          (i_dataRS2),
                .o_isEqual        (o_isEqual),
                .o_isLessUnsigned (o_isLessUnsigned),
                .o_isLessSigned   (o_isLessSigned));
        end
        else begin
            assign o_isEqual        = i_dataRS1 == i_dataRS2;
            assign o_isLessUnsigned = $unsigned(i_dataRS1) < $unsigned(i_dataRS2);
            assign o_isLessSigned   = $signed(i_dataRS1) < $signed(i_dataRS2);
        end
    endgenerate

endmodule
