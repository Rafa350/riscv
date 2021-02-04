`include "RV.svh"


package Config;


    // Configuracio dels parametres fundamentals
    //
`ifdef RV_BASE_RV32I
    localparam DATA_WIDTH = 32;
    localparam ADDR_WIDTH = 32;
    localparam PC_WIDTH   = 32;
    localparam REG_WIDTH  = 5;
`endif

`ifdef RV_BASE_RV32E
    localparam DATA_WIDTH = 32;
    localparam ADDR_WIDTH = 32;
    localparam PC_WIDTH   = 32;
    localparam REG_WIDTH  = 4;
`endif

`ifdef RV_BASE_RV64I
    localparam DATA_WIDTH = 64;
    localparam ADDR_WIDTH = 64;
    localparam PC_WIDTH   = 64;
    localparam REG_WIDTH  = 5;
`endif


    // Configuracio de les extensions de la cpu
    //
    localparam RV_EXT_A = 0;                      // Operacions atomiques
    localparam RV_EXT_B = 0;                      // Manipulacio de bits
    localparam RV_EXT_C = 0;                      // Instruccions comprimides
    localparam RV_EXT_D = 0;                      // Operacions float doble precissio de 64 bits (Implica RV_EXT_F)
    localparam RV_EXT_E = REG_WIDTH == 5 ? 0 : 1; // Reduccio del nombre de registres
    localparam RV_EXT_F = 0;                      // Operacions float simple precissio de 32 bits
    localparam RV_EXT_I = 1;                      // Instruccions amb enters
    localparam RV_EXT_M = 0;                      // Multiplicacio i divisio d'enters
    localparam RV_EXT_U = 0;                      // Implementa User Mode


    // Configuracio de la arquitectura
    //
    localparam RV_ARCH_CPU = "PP"; // (PP: Pipeline, SC: Single cycle; MC: Multicicle)


    // Configuracio per les extensions de depuracio
    //
`ifdef RV_COMPILER_VERILATOR
    localparam RV_DEBUG_ON = 1; // Habilita la depuracio
`else
    localparam RV_DEBUG_ON = 1; // Deshabilita la depuracio
`endif


    // Configuracio del cache L1 d'instruccions
    //
    localparam RV_ICACHE_ON       = 1;   // Habilita el cache d'instruccions
    localparam RV_ICACHE_SETS     = 1;   // Nombre de vias
    localparam RV_ICACHE_ELEMENTS = 128; // Nombre d'elements
    localparam RV_ICACHE_BLOCKS   = 4;   // Nombre d'instruccions, en cada element del cache


    // Configuracio del cache L1 de dades
    //
    localparam RV_DCACHE_ON       = 0;   // Habilita el cache de dades
    localparam RV_DCACHE_SETS     = 1;   // Nombre de vias
    localparam RV_DCACHE_ELEMENTS = 128; // Nombre d'elements
    localparam RV_DCACHE_BLOCKS   = 4;   // Nombre de words, en cada element del cache


    // Configuracio del cache L2
    //
    localparam RV_L2CACHE_ON      = 0;   // Habilita el cache L2


    // Configuracio de la plataforma de destinacio
    //
`ifdef RV_COMPILER_VERILATOR
    localparam RV_TARGET_COMPILER = "VERILATOR";
    localparam RV_TARGET_DEVICE   = "UNKNOWN";
`endif
`ifdef RV_COMPILER_QUARTUS
    localparam RV_TARGET_COMPILER = "QUARTUS";
    localparam RV_TARGET_DEVICE   = "CYCLONE-IV";
`endif


endpackage