module BranchComparer
    import Types::*;
(
    input  Data  i_dataA,
    input  Data  i_dataB,

    output logic o_isEqual,
    output logic o_isLessSigned,
    output logic o_isLessUnsigned);

    assign o_isEqual        = i_dataA == i_dataB;
`ifdef VERILATOR    
    assign o_isLessUnsigned = $unsigned(i_dataA) < $unsigned(i_dataB);
    assign o_isLessSigned   = $signed(i_dataA) < $signed(i_dataB);
`else
    less32S
    less32S (
        .dataa(i_dataA),
        .datab(i_dataB),
        .alb(o_isLessSigned));

    less32U
    less32U (
        .dataa(i_dataA),
        .datab(i_dataB),
        .alb(o_isLessUnsigned));
`endif    

endmodule
