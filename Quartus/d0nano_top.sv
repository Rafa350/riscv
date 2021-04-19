module top
    import 
        Config::*, 
        ProcessorDefs::*;
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

    logic clock;
    logic reset;
    logic [7:0] leds;

    assign clock = CLOCK_50;
    assign reset = ~KEY[0];


    DataBus dataBus();
    InstBus instBus();


    // ------------------------------------------------------------------------
    // Port IO LEDSA
    // ------------------------------------------------------------------------

    always_ff @(posedge clock)
        if (dataBus.we & (dataBus.addr == DataAddr'('h0200)))
            LED[3:0] <= dataBus.wdata[3:0];


    // ------------------------------------------------------------------------
    // Memoria de dades
    // ------------------------------------------------------------------------

    DataMemory1024x32
    DataMem (
        .i_clock (clock),
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
    
    Processor
    processor (
        .i_clock (clock),
        .i_reset (reset),
        .instBus (instBus),
        .dataBus (dataBus));

endmodule
