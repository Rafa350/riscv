`define PIPELINE


module top(
    input  wire       CLOCK_50,
    input  wire [1:0] KEY,
    input  wire [3:0] SW,
    output wire [7:0] LED);
    
    parameter DATA_DBUS_WIDTH = 32;
    parameter ADDR_DBUS_WIDTH = 32;
    parameter DATA_IBUS_WIDTH = 32;
    parameter ADDR_IBUS_WIDTH = 32;
    
    logic Clock;
    assign Clock = ~KEY[0];

    logic Reset;
    assign Reset = ~KEY[1];
    
    assign LED[5:0] = Pgm_PgmInst[31:26];
    assign LED[7:6] = Cpu_PgmAddr[1:0];
    
    
    // ------------------------------------------------------------------
    // Port IO
    //


    // -------------------------------------------------------------------
    // Memoria RAM
    //
    logic [DATA_DBUS_WIDTH-1:0] Mem_MemRdData;
    mem #(
        .DATA_WIDTH (DATA_DBUS_WIDTH),
        .ADDR_WIDTH (DATA_DBUS_WIDTH))
    mem (
        .i_clk   (Clock),
        .i_we    (Cpu_MemWrEnable),
        .i_addr  (Cpu_MemAddr),
        .i_wdata (Cpu_MemWrData),
        .o_rdata (Mem_MemRdData));

      
    // -------------------------------------------------------------------
    // Memoria de programa
    //    
    logic [DATA_IBUS_WIDTH-1:0] Pgm_PgmInst;    
    pgm #(
        .ADDR_WIDTH (ADDR_IBUS_WIDTH),
        .INST_WIDTH (DATA_IBUS_WIDTH))
    pgm (
        .i_addr (Cpu_PgmAddr),
        .o_inst (Pgm_PgmInst));


    // -------------------------------------------------------------------
    // CPU
    //
    logic [DATA_DBUS_WIDTH-1:0] Cpu_MemWrData;
    logic [ADDR_DBUS_WIDTH-1:0] Cpu_MemAddr;
    logic                       Cpu_MemWrEnable;
    logic [ADDR_IBUS_WIDTH-1:0] Cpu_PgmAddr;
    
`ifdef PIPELINE
    ProcessorPP #(
`else    
    ProcessorSC #(
`endif    
        .DATA_DBUS_WIDTH (DATA_DBUS_WIDTH), 
        .ADDR_DBUS_WIDTH (ADDR_DBUS_WIDTH),
        .DATA_IBUS_WIDTH (DATA_IBUS_WIDTH),
        .ADDR_IBUS_WIDTH (ADDR_IBUS_WIDTH)) 
    Cpu (
        .i_Clock       (Clock),
        .i_Reset       (Reset),
        .o_PgmAddr     (Cpu_PgmAddr),
        .i_PgmInst     (Pgm_PgmInst),
        .o_MemWrEnable (Cpu_MemWrEnable),  
        .i_MemRdData   (Mem_MemRdData),
        .o_MemWrData   (Cpu_MemWrData),
        .o_MemAddr     (Cpu_MemAddr));
       
endmodule
