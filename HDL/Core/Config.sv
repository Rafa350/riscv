`include "RV.svh"


package Config;


    // Configuracio dels parametres fundamentals
    //
`ifdef RV_BASE_RV32I
    localparam DATA_WIDTH = 32;
    localparam ADDR_WIDTH = 32;
`ifdef RV_TARGET_VERILATOR
    localparam PC_WIDTH   = 16;
`else
    localparam PC_WIDTH   = 32;
`endif
    localparam REG_WIDTH  = 5;
`endif

`ifdef RV_BASE_RV32E
    localparam DATA_WIDTH = 32;
    localparam ADDR_WIDTH = 32;
`ifdef RV_TARGET_VERILATOR
    localparam PC_WIDTH   = 16;
`else
    localparam PC_WIDTH   = 32;
`endif
    localparam REG_WIDTH  = 4;
`endif

`ifdef RV_BASE_RV64I
    localparam DATA_WIDTH = 64;
    localparam ADDR_WIDTH = 64;
`ifdef RV_TARGET_VERILATOR
    localparam PC_WIDTH   = 16;
`else
    localparam PC_WIDTH   = 64;
`endif
    localparam REG_WIDTH  = 5;
`endif


    // Configuracio de les extensions de la cpu
    //
    localparam RV_EXT_B  = 0; // Manipulacio de bits
    localparam RV_EXT_C  = 0; // Instruccions comprimides
    localparam RV_EXT_D  = 0; // Operacions float doble precissio de 64 bits (Implica RV_EXT_F)
    localparam RV_EXT_F  = 0; // Operacions float simple precissio de 32 bits
    localparam RV_EXT_M  = 0; // Multiplicacio i divisio d'enters


    // Configuracio per les extensions de depuracio en verilator
    //
    localparam RV_DEBUG_ON = 1; // Habilita la depùracio


    // Configuracio del cache d'instruccions
    //
    localparam RV_ICACHE_ON       = 1;  // Habilita el cache d'instruccions
    localparam RV_ICACHE_SETS     = 1;  // Nombre de vias
    localparam RV_ICACHE_ELEMENTS = 64; // Nombre d'elements
    localparam RV_ICACHE_BLOCKS   = 4;  // Nombre de words en cada element


endpackage