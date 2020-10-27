module cpu
#(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 12,
    parameter INST_WIDTH = 16,
    parameter PC_WIDTH = 12)
(
    input logic i_clk,
    input logic i_rst,
    
    input logic [DATA_WIDTH-1:0] i_rdata,
    output logic [DATA_WIDTH-1:0] o_wdata,
    output logic [ADDR_WIDTH-1:0] o_addr,
    output logic o_we,

    input logic [INST_WIDTH-1:0] i_inst,
    output logic [PC_WIDTH-1:0] o_pc);
    
    logic [15:0] pc;                   // Contador de programa
    logic [15:0] pc_next;              // Contador de programa actualitzat
      
    logic lit;                         // Indica instruccio literal

    logic [2:0] reg_raddr1;            // Adressa del registre de lectura 1
    logic [2:0] reg_raddr2;            // Adressa del registre de lectura 2
    logic [2:0] reg_waddr;             // Adressa del registre d'escriptura
    logic [DATA_WIDTH-1:0] reg_data1;  // Valor del registre seleccionat 1
    logic [DATA_WIDTH-1:0] reg_data2;  // Valor del regisres seleccionat 2 
    logic reg_we;                      // Autoritza escriptura del regisres

    // Control
    ctl
    ctl0 (
        .i_inst(i_inst),
        .o_lit(lit),
        .o_reg_we(reg_we),
        .o_reg_waddr(reg_waddr),
        .o_reg_raddr1(reg_raddr1),
        .o_reg_raddr2(reg_raddr2),
        .o_mem_we(o_we),
        .o_alu_op(alu_op));
        
    // Bloc de registres
    regs #(
        .DATA_WIDTH(DATA_WIDTH))
    regs0(
        .i_clk(i_clk),
        .i_waddr(reg_waddr),
        .i_wdata(result),
        .i_we(reg_we),
        .i_raddr1(reg_raddr1),
        .o_rdata1(reg_data1),
        .i_raddr2(reg_raddr2),
        .o_rdata2(reg_data2));
    
    // ALU
    alu #(
        .DATA_WIDTH(DATA_WIDTH))
    alu0 (
        .i_op(alu_op),
        .i_data1(lit ? i_inst[15:0] : reg_data1),
        .i_data2(reg_data2),
        .o_result(o_wdata));        

    // Program counter
    assign pc_next = pc + 1;
    always_ff @(posedge i_clk) begin
        if (i_rst)
            pc <= 0;
        else
            pc <= pc_next;
    end
          
endmodule
