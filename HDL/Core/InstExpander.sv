module InstExpander
    import Types::*;
(
    input  logic [31:0] i_Inst,
    output logic [31:0] o_Inst,
    output logic        o_Compressed);
    
    
    always_comb begin
        unique case (i_Inst[1:0])
            2'b00:
                begin
                    o_Inst = i_Inst;
                    o_Compressed = 1;
                end 
                
            2'b01:
                begin
                    unique casez ({i_Inst[15:13], i_Inst[11:10], i_Inst[6:5]})
                        7'b100_10_??: // C.ANDI
                            o_Inst = {
                                {{7{i_Inst[12]}}, i_Inst[6:2]}, 
                                {2'b01, i_Inst[9:7]}, 
                                3'b111, 
                                {2'b01, i_Inst[9:7]}, 
                                OpCode_OpIMM};
                                      
                        7'b100_11_00: // C.SUB
                            o_Inst = {
                                7'b0100000,
                                {2'b01, i_Inst[4:2]},
                                {2'b01, i_Inst[9:7]},
                                3'b000,
                                {2'b01, i_Inst[9:7]},
                                OpCode_Op};
                        
                        7'b100_11_01: // C.XOR
                            o_Inst = {
                                7'b0000000,
                                {2'b01, i_Inst[4:2]},
                                {2'b01, i_Inst[9:7]},
                                3'b100,
                                {2'b01, i_Inst[9:7]},
                                OpCode_Op};                        
                                
                        7'b100_11_10: // C.OR
                            o_Inst = {
                                7'b0100000,
                                {2'b01, i_Inst[4:2]},
                                {2'b01, i_Inst[9:7]},
                                3'b110,
                                {2'b01, i_Inst[9:7]},
                                OpCode_Op};                            
                        
                        7'b100_11_11: // C.AND
                            o_Inst = {
                                7'b0100000,
                                {2'b01, i_Inst[4:2]},
                                {2'b01, i_Inst[9:7]},
                                3'b111,
                                {2'b01, i_Inst[9:7]},
                                OpCode_Op};                            
                            
                        default:
                            o_Inst = i_Inst;
                    endcase
                    o_Compressed = 1;
                end 
                
            2'b10:
                begin
                    o_Inst = i_Inst;
                    o_Compressed = 1;
                end 
            
            2'b11:
                begin
                    o_Inst = i_Inst;
                    o_Compressed = 0;
                end 
        endcase    
        
    end 

endmodule
