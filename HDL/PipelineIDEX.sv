module PipelineIDEX 
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter PC_WIDTH   = 32,
    parameter REG_WIDTH  = 5) 
(
    // Senyals de control
    input  logic                  i_Clock,        // Clock
    input  logic                  i_Reset,        // Reset
     
     // Senyals de depuracio
    input  logic [2:0]            i_DbgTag,       // Etiqueta de depuracio
    output logic [2:0]            o_DbgTag,                
     
    // Senyals de control del pipeline  
    input  logic                  i_Flush,
    input  logic                  i_Stall,

    // Senyals d'entrada al pipeline
    input  logic [PC_WIDTH-1:0]   i_PC,           // PC
    input  logic [6:0]            i_InstOP,       // Instruccio OP
    input  logic [REG_WIDTH-1:0]  i_InstRS1,      // Instruccio RS1
    input  logic [REG_WIDTH-1:0]  i_InstRS2,      // Instruccio RS2
    input  logic [DATA_WIDTH-1:0] i_InstIMM,      // Valor inmediat de la instruccio
    input  logic [DATA_WIDTH-1:0] i_DataA,        // Operand A per la ALU
                                  i_DataB,        // Operand B per la ALU
    input  logic [REG_WIDTH-1:0]  i_RegWrAddr,    // Registre per escriure
    input  logic                  i_RegWrEnable,  // Habilita l'escriptura en el registres
    input  logic [1:0]            i_RegWrDataSel, // Seleccio de dades per escriure en els registre
    input  logic                  i_MemWrEnable,  // Habilita la escriptura en memoria
    input  logic                  i_OperandASel,
    input  logic                  i_OperandBSel,
    input  logic [4:0]            i_AluControl,   // Control de la ALU
    
    // Senyals de sortida del pipeline
    output logic [PC_WIDTH-1:0]   o_PC,
    output logic [6:0]            o_InstOP,     
    output logic [REG_WIDTH-1:0]  o_InstRS1,      // Instruccio RS1
    output logic [REG_WIDTH-1:0]  o_InstRS2,      // Instruccio RS2
    output logic [DATA_WIDTH-1:0] o_InstIMM,      // Valor inmediat de la instruccio
    output logic [DATA_WIDTH-1:0] o_DataA,
                                  o_DataB,
    output logic [REG_WIDTH-1:0]  o_RegWrAddr,
    output logic                  o_RegWrEnable,
    output logic [1:0]            o_RegWrDataSel,
    output logic                  o_MemWrEnable,
    output logic                  o_OperandASel,
    output logic                  o_OperandBSel,
    output logic [4:0]            o_AluControl);
    
    
    localparam [2:0] PP_RESET = 3'b1??;
    localparam [2:0] PP_STALL = 3'b010;
    localparam [2:0] PP_FLUSH = 3'b000;
    
         
    logic [2:0] PPOp;
    assign PPOp = {i_Reset, i_Stall, i_Flush};
    
    always_ff @(posedge i_Clock) begin
        unique casez (PPOp)
            PP_RESET: begin
                o_PC           <= {PC_WIDTH{1'b0}};
                o_InstOP       <= 7'b0;
                o_InstRS1      <= 5'b0;
                o_InstRS2      <= 5'b0;
                o_InstIMM      <= {DATA_WIDTH{1'b0}};
                o_DataA        <= {DATA_WIDTH{1'b0}};
                o_DataB        <= {DATA_WIDTH{1'b0}};
                o_RegWrAddr    <= {REG_WIDTH{1'b0}};
                o_RegWrEnable  <= 1'b0;
                o_RegWrDataSel <= 2'b0;
                o_MemWrEnable  <= 1'b0;
                o_AluControl   <= 5'b0;
                o_OperandASel  <= 1'b0;
                o_OperandBSel  <= 1'b0;
            end
            
            PP_STALL: begin
                o_PC           <= o_PC;
                o_InstOP       <= o_InstOP;
                o_InstRS1      <= o_InstRS1;
                o_InstRS2      <= o_InstRS2;
                o_InstIMM      <= o_InstIMM;
                o_DataA        <= o_DataA;
                o_DataB        <= o_DataB;
                o_RegWrAddr    <= o_RegWrAddr;
                o_RegWrEnable  <= o_RegWrEnable;
                o_RegWrDataSel <= o_RegWrDataSel;
                o_MemWrEnable  <= o_MemWrEnable;
                o_AluControl   <= o_AluControl;
                o_OperandASel  <= o_OperandASel;
                o_OperandBSel  <= o_OperandBSel;
            end
            
            default: begin
                o_PC           <= i_PC;
                o_InstOP       <= i_InstOP;
                o_InstRS1      <= i_InstRS1;
                o_InstRS2      <= i_InstRS2;
                o_InstIMM      <= i_InstIMM;
                o_DataA        <= i_DataA;
                o_DataB        <= i_DataB;
                o_RegWrAddr    <= i_RegWrAddr;
                o_RegWrEnable  <= i_RegWrEnable;
                o_RegWrDataSel <= i_RegWrDataSel;
                o_MemWrEnable  <= i_MemWrEnable;
                o_AluControl   <= i_AluControl;
                o_OperandASel  <= i_OperandASel;
                o_OperandBSel  <= i_OperandBSel;
            end
        endcase
        
        o_DbgTag       <= i_DbgTag;
    end
    
    
endmodule