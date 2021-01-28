`include "RV.svh"


module top
    import Config::*, Types::*;
(
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
       
    logic Clock;
    logic Reset;
    logic [7:0] leds;

    assign Clock = CLOCK_50;
    assign Reset = ~KEY[0];


    DataMemoryBus dataBus();        
    InstMemoryBus instBus();
       
    // ------------------------------------------------------------------------
    // Port IO LEDSA
    // ------------------------------------------------------------------------
    
    always_ff @(posedge Clock)
        if (dataBus.wrData & dataBus.addr == 10'h0200)
            LED <= dataBus.wrData[7:0];


    // ------------------------------------------------------------------------
    // Memoria de dades
    // ------------------------------------------------------------------------
    
    DataMemory1024x32
    DataMem (
        .i_clock (Clock),
        .bus     (dataBus));

      
    // ------------------------------------------------------------------------
    // Memoria de programa
    // ------------------------------------------------------------------------
    
    InstMemory
    InstMem (
        .bus (instBus));


    // ------------------------------------------------------------------------
    // CPU
    // ------------------------------------------------------------------------
    
`ifdef PIPELINE
    ProcessorPP
`else    
    ProcessorSC
`endif    
    Cpu (
        .i_clock (Clock),
        .i_reset (Reset),
        .instBus (instBus),
        .dataBus (dataBus));
       
endmodule
