/*************************************************************************
 *
 *       Modul CPU
 *
 *       Entrades:
 *           clk     : Clock
 *           rst     : Reset
 *           rom_din : Dades d'entrada de la ROM
 *           ram_din : Dades d'entrada de la RAM
 *
 *       Sortides:
 *           rom_addr: Adressa de la ROM
 *           ram_dout: Dades de sortida de la RAM
 *           ram_addr: Addresa de la ram
 *
 *************************************************************************/


/* verilator lint_off UNDRIVEN */


module cpu
#(
    parameter RAM_DATA_WIDTH = 16,
    parameter RAM_ADDR_WIDTH = 12,
    parameter ROM_DATA_WIDTH = 16,
    parameter ROM_ADDR_WIDTH = 12)
(
    input i_clk,
    input i_rst,
    
    input [ROM_DATA_WIDTH-1:0] rom_din,
    output [ROM_ADDR_WIDTH-1:0] rom_addr,

    input [RAM_DATA_WIDTH-1:0] ram_din,
    output [RAM_DATA_WIDTH-1:0] ram_dout,
    output [RAM_ADDR_WIDTH-1:0] ram_addr,
    output ram_we);
    
    wire rst;                               // Reset
    wire clk;                               // Clock
    
    // Linies de dades i control del contador de programa
    //
    wire pc_le;                             // Program counter load enable
    wire pc_in_sel;                         // Program counter input selection
    wire [ROM_ADDR_WIDTH-1:0] pc_in;        // Program counter input
    wire [ROM_ADDR_WIDTH-1:0] imm_addr;     // Immediate address
    
    // Linies de dades i control de la pila R
    //
    wire rstk_we;                           // R-Stack write enable
    wire rstk_me;                           // R-Stack move enable
    wire rstk_md;                           // R-Stack move direction
    wire [ROM_ADDR_WIDTH-1:0] rstk_top;     // R-Stack top value
    
    // Linies de dades i control per la pila D
    //
    wire dstk_we;                           // D-Stack write enable
    wire dstk_me;                           // D-Stack move enable
    wire dstk_md;                           // D-Stack move direction
    wire [RAM_DATA_WIDTH-1:0] dstk_top;     // D-Stack top value
    wire [RAM_DATA_WIDTH-1:0] dstk_topN;    // D-Stack new top value
    wire [RAM_DATA_WIDTH-1:0] dstk_next;    // D-Stack bext value
       
    // Linies de dades i control de la ALU
    //
    wire [3:0] alu_op;                      // ALU operation code
    wire [1:0] dstk_topN_sel;               // topN value selection
    wire zero = |dstk_top;                  // Zero detection
    wire [RAM_DATA_WIDTH-1:0] alu_out;      // ALU result output
    wire [RAM_DATA_WIDTH-1:0] imm_data;     // immediate data
    
    // Generator de rellotge
    //
    clock 
    clock_generator(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_pause(0),
        .o_clk(clk),
        .o_rst(rst));
       
    // Contador de programa
    //
    counter #(
        .DATA_WIDTH(ROM_ADDR_WIDTH)) 
    program_counter(
        .i_clk(clk),                        // Reset
        .i_rst(rst),                        // Clock
        .i_le(pc_le),                       // Load enable
        .i_data(pc_in),                     // Input
        .o_data(rom_addr));                 // Output

    // Selector de la entrada del contador de programa
    //
    mux2to1 #(
        .DATA_WIDTH(ROM_ADDR_WIDTH))
    mux2to1_impl(
        .i_data0(imm_addr),                 // Input A
        .i_data1(rstk_top),                 // Input B
        .o_data(pc_in),                     // Output
        .i_sel(pc_in_sel));                 // Input selection
        
    // Pila de retorn
    //
    stack #(
        .WIDTH(ROM_ADDR_WIDTH))
    return_stack(
        .clk(clk),                          // Clock
        .we(rstk_we),                       // Write enable
        .me(rstk_me),                       // Move enable
        .md(rstk_md),                       // Move direction
        .in(rom_addr + 12'b1),              // Input
        .out(rstk_top));                    // Output
        
    // Registre del primer element de la pila
    //
    register #(
        .DATA_WIDTH(RAM_DATA_WIDTH))
    data_stack_top(
        .i_clk(clk),                        // Clock
        .i_rst(rst),                        // Reset
        .i_data(dstk_topN),                 // Input
        .o_data(dstk_top));                 // Output
        
    // Pila de dades
    //
    stack #(
        .WIDTH(RAM_DATA_WIDTH))
    data_stack(
        .clk(clk),                          // Clock
        .we(dstk_we),                       // Write enable
        .me(dstk_me),                       // Move enable
        .md(dstk_md),                       // Move direction
        .in(dstk_top),                      // Input
        .out(dstk_next));                   // Output
        
    // Selector pel nou valor de dstk_top
    //
    mux4to1 
        #(.DATA_WIDTH(RAM_DATA_WIDTH))
    mux4to1_impl(
        .i_data0(alu_out),                  // Input A
        .i_data1(imm_data),                 // Input B
        .i_data2({4'b0, rstk_top}),         // Input C
        .i_data3(ram_din),                  // Input D
        .o_data(dstk_topN),                 // Output
        .i_sel(dstk_topN_sel));             // Input selection
        
    // Unitat de calcul (ALU)
    //
    alu #(
        .DATA_WIDTH(RAM_DATA_WIDTH))
    alu_impl(
        .i_data0(dstk_top),                 // Input A
        .i_data1(dstk_next),                // Input B
        .o_data(alu_out),                   // Output
        .i_op(alu_op));                     // Op-Code        
                                    
    // Unitat de control (Decodificador d'instruccions)
    //
    controller #(
        .ADDR_WIDTH(ROM_ADDR_WIDTH),
        .DATA_WIDTH(RAM_DATA_WIDTH))
    controller_impl(
        .rst(rst),                          // Reset
        .inst(rom_din),                     // Instruction
        .zero(zero),                        // Zero input
        .pc_le(pc_le),                      // Program counter load enable
        .pc_in_sel(pc_in_sel),              // Program counter input selection
        .ram_we(ram_we),                    // RAM write enable
        .rstk_we(rstk_we),                  // R-Stack write enable
        .rstk_me(rstk_me),                  // R-Stack move enable
        .rstk_md(rstk_md),                  // R-Stack move direction
        .dstk_we(dstk_we),
        .dstk_me(dstk_me),
        .dstk_md(dstk_md),        
        .imm_data(imm_data),                // Immediate data 
        .imm_addr(imm_addr),                // Immediate address
        .alu_op(alu_op),                    // ALU operation selection
        .alu_inB_sel(dstk_topN_sel));       // D-Stack topN selection
    
    assign ram_addr = dstk_top[RAM_ADDR_WIDTH-1:0];
    assign ram_dout = dstk_next;
    

endmodule
