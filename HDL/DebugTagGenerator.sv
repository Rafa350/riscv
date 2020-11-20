module DebugTagGenerator
(
    input logic i_Clock,
    input logic i_Reset,
    
    output logic [2:0] o_Tag);
    
    always_ff @(posedge i_Clock)
        o_Tag <= i_Reset ? 0 : o_Tag + 1;
    
endmodule
    