`define PIPELINE


module top(
    input  logic        CLOCK_50,
    
    // Switches i pulsadors
    input  logic [1:0]  KEY,
    input  logic [3:0]  SW,

    // Leds
    output logic [7:0]  LED,
    
    // SDRAM
    output logic [12:0] DRAM_ADDR,
    inout  logic [15:0] DRAM_DQ,
    output logic [1:0]  DRAM_BA,
    output logic [1:0]  DRAM_DQM,
    output logic        DRAM_RAS,
    output logic        DRAM_CAS,
    output logic        DRAM_CKE,
    output logic        DRAM_CLK,
    output logic        DRAM_WE,
    output logic        DRAM_CS,
    
    // GPIO0
    input  logic [1:0]  GPIO_0_IN,
    output logic [33:0] GPIO_0,
    
    // GPIO1
    input  logic [1:0]  GPIO_1_IN,
    inout  logic [33:0] GPIO_1,
    
    // GPIO2
    input  logic [2:0]  GPIO_2_IN,
    inout  logic [12:0] GPIO_2,
    
    // I2C EEPROM/ACCELLEROMETER
    output logic        I2C_SCLK,
    inout  logic        I2C_SDAT);
    
    
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 10;
    parameter PC_WIDTH   = 10;
    parameter REG_WIDTH  = 5;
    
    logic Clock;
    logic Reset;
    logic [7:0] leds;

    assign Clock = CLOCK_50;
    assign Reset = ~KEY[0];


    DataMemoryBus #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH))
    DBus();        
    
    InstMemoryBus #(
        .PC_WIDTH (PC_WIDTH))
    IBus();
       
    // ------------------------------------------------------------------------
    // Port IO LEDSA
    // ------------------------------------------------------------------------
    
    always_ff @(posedge Clock)
        if (DBus.WrData & DBus.Addr == 10'h0200)
            LED <= DBus.WrData[7:0];


    // ------------------------------------------------------------------------
    // Memoria de dades
    // ------------------------------------------------------------------------
    
    DataMemory #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH))
    DataMem (
        .i_Clock (Clock),
        .DBus    (DBus));

      
    // ------------------------------------------------------------------------
    // Memoria de programa
    // ------------------------------------------------------------------------
    
    InstMemory #(
        .PC_WIDTH (PC_WIDTH))
    InstMem (
        .IBus (IBus));


    // ------------------------------------------------------------------------
    // CPU
    // ------------------------------------------------------------------------
    
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
        .i_Clock (Clock),
        .i_Reset (Reset),
        .IBus    (IBus),
        .DBus    (DBus));
       
endmodule
