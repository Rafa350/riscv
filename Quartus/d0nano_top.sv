`define PIPELINE


module top(
    input  logic        CLOCK_50,
    
    input  logic [1:0]  KEY,
    input  logic [3:0]  SW,

    output logic [7:0]  LED,
    
    input  logic [1:0]  GPIO_0_IN,
    output  logic [33:0] GPIO_0,
    
    input  logic [1:0]  GPIO_1_IN,
    inout  logic [33:0] GPIO_1,
    
    input  logic [1:0]  GPIO_2_IN,
    inout  logic [12:0] GPIO_2,
    
    output logic        I2C_SCLK,
    inout  logic        I2C_SDAT);
    
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 10;
    parameter PC_WIDTH   = 10;
    parameter REG_WIDTH  = 5;
    
    logic Clock;
    logic Reset;

    logic [ADDR_WIDTH-1:0] MemAddr;
    logic                  MemWrEnable;
    logic [DATA_WIDTH-1:0] MemWrData;
    logic [DATA_WIDTH-1:0] MemRdData;

    logic [PC_WIDTH-1:0]   PgmAddr;
    logic [31:0]           PgmInst;
       
    assign Clock = ~KEY[0];
    assign Reset = ~KEY[1];
    assign LED[7:0] = MemWrData[7:0];
    
    
    // ------------------------------------------------------------------
    // Port IO
    //


    // -------------------------------------------------------------------
    // Memoria RAM
    //
    Memory #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH))
    mem (
        .i_Clock    (Clock),
        .i_Addr     (MemAddr),
        .i_WrEnable (MemWrEnable),
        .i_WrData   (MemWrData),
        .o_RdData   (MemRdData));

      
    // -------------------------------------------------------------------
    // Memoria de programa
    //     
    Program #(
        .ADDR_WIDTH (PC_WIDTH),
        .INST_WIDTH (32))
    pgm (
        .i_Addr (PgmAddr),
        .o_Inst (PgmInst));


    // -------------------------------------------------------------------
    // CPU
    //
    
`ifdef PIPELINE
    ProcessorPP #(
`else    
    ProcessorSC #(
`endif    
        .DATA_WIDTH (DATA_WIDTH), 
        .ADDR_WIDTH (ADDR_WIDTH),
        .PC_WIDTH   (PC_WIDTH),
        .REG_WIDTH  (REG_WIDTH)) 
    Cpu (
        .i_Clock       (Clock),
        .i_Reset       (Reset),
        
        .o_PgmAddr     (PgmAddr),
        .i_PgmInst     (PgmInst),
        
        .o_MemAddr     (MemAddr),
        .o_MemWrEnable (MemWrEnable),
        .o_MemWrData   (MemWrData),
        .i_MemRdData   (MemRdData));
       
endmodule
