module Trace
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter PC_WIDTH   = 12,
    parameter REG_WIDTH  = 5)
(
    input logic        i_Clock,
    input logic        i_Reset,
    input logic [31:0] i_Inst);

    
    always_ff @(posedge i_Clock) begin
    end
    
    
    function string getRegName(input logic [REG_WIDTH-1:0] regAddr, input logic abi);
    
        if (abi) 
            unique case (regAddr)
                0:       return "zero";
                1:       return "ra";
                2:       return "sp";
                3:       return "gp";
                4:       return "tp";
                5:       return "t0";
                6:       return "t1";
                7:       return "t2";
                8:       return "s0";
                9:       return "s1";
                10:      return "a0";
                11:      return "a1";
                12:      return "a2";
                13:      return "a3";
                14:      return "a4";
                15:      return "a5";
                16:      return "a6";
                17:      return "a7";
                18:      return "s2";
                19:      return "s3";
                20:      return "s4";
                21:      return "s5";
                22:      return "s6";
                23:      return "s7";
                24:      return "s8";
                25:      return "s9";
                26:      return "s10";
                27:      return "s11";
                28:      return "t3";
                29:      return "t4";
                30:      return "t5";
                31:      return "t6";
                default: return "???";
            endcase
        
        else
            unique case (regAddr)
                0:       return "x0";
                1:       return "x1";
                2:       return "x2";
                3:       return "x3";
                4:       return "x4";
                5:       return "x5";
                6:       return "x6";
                7:       return "x7";
                8:       return "x8";
                9:       return "x9";
                10:      return "x10";
                11:      return "x11";
                12:      return "x12";
                13:      return "x13";
                14:      return "x14";
                15:      return "x15";
                16:      return "x16";
                17:      return "x17";
                18:      return "x18";
                19:      return "x19";
                20:      return "x20";
                21:      return "x21";
                22:      return "x22";
                23:      return "x23";
                24:      return "x24";
                25:      return "x25";
                26:      return "x26";
                27:      return "x27";
                28:      return "x28";
                29:      return "x29";
                30:      return "x30";
                31:      return "x31";
                default: return "???";
            endcase
        
    endfunction

endmodule
