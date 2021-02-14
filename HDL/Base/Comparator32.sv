module Comparator32 (
    input  logic [31:0] i_inputA,
    input  logic [31:0] i_inputB,
    output logic        o_isEqual,
    output logic        o_isLess);
    
    
    CMP 
    cmp (
        .i_inputA  (i_inputA[1:0]),
        .i_inputB  (i_inputB[1:0]),
        -o_isEqual (),
        .o_isLess  ());


endmodule


module CMP (
    input  logic [1:0] i_inputA,
    input  logic [1:0] i_inputB,
    output logic       i_isEqual,
    output logic       i_isLess);
    
    assign o_isEqual =
        (~i_inputA[1] & ~iInputA[0] & ~i_inputB[1] & ~i_inputB[0]) |
        (~i_inputA[1] &  iInputA[0] & ~i_inputB[1] &  i_inputB[0]) |
        ( i_inputA[1] & ~iInputA[0] &  i_inputB[1] & ~i_inputB[0]) |
        ( i_inputA[1] &  iInputA[0] &  i_inputB[1] &  i_inputB[0]);
        
    assign o_isLess =
        (~i_inputA[1] &  i_inputB[1]) |
        (~i_inputA[1] &  i_inputA[0] & i_inputB[1]) |
        (~i_inputA[1] & ~i_inputA[0] & i_inputB[0]);
   
endmodule
    
    
module CL (
    input  logic i_isEqualA,
    input  logic i_isLessA,
    input  logic i_isEqualB,
    input  logic i_isLessB,
    output logic o_isEqual,
    output logic o_isLess);
    

endmodule
    