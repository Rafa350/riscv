module BranchComparer
    import Config::*, Types::*;
(
    input  Data  i_dataRS1,
    input  Data  i_dataRS2,

    output logic o_isEqual,
    output logic o_isLessSigned,
    output logic o_isLessUnsigned);


    assign o_isEqual = i_dataRS1 == i_dataRS2;

    generate
    if (RV_TARGET_COMPILER == "VERILATOR") begin

        assign o_isLessUnsigned = $unsigned(i_dataRS1) < $unsigned(i_dataRS2);
        assign o_isLessSigned   = $signed(i_dataRS1) < $signed(i_dataRS2);

    end

    else if (RV_TARGET_COMPILER == "QUARTUS") begin

        less32S
        less32S (
            .dataa(i_dataRS1),
            .datab(i_dataRS2),
            .alb(o_isLessSigned));

        less32U
        less32U (
            .dataa(i_dataRS1),
            .datab(i_dataRS2),
            .alb(o_isLessUnsigned));

    end
    endgenerate

endmodule
