`include "RV.svh"


package Config;


    // Configuracio dels parametres fundamentals
    //
`ifdef RV_BASE_RV32I
    localparam int unsigned DATA_WIDTH = 32;
    localparam int unsigned ADDR_WIDTH = 32;
    localparam int unsigned PC_WIDTH   = 32;
    localparam int unsigned REG_WIDTH  = 5;
`endif

`ifdef RV_BASE_RV32E
    localparam int unsigned DATA_WIDTH = 32;
    localparam int unsigned ADDR_WIDTH = 32;
    localparam int unsigned PC_WIDTH   = 32;
    localparam int unsigned REG_WIDTH  = 4;
`endif

`ifdef RV_BASE_RV64I
    localparam int unsigned DATA_WIDTH = 64;
    localparam int unsigned ADDR_WIDTH = 64;
    localparam int unsigned PC_WIDTH   = 64;
    localparam int unsigned REG_WIDTH  = 5;
`endif

    // Configuracio de les extensions de la cpu
    //
    localparam bit          RV_EXT_A = 0; // Operacions atomiques
    localparam bit          RV_EXT_B = 0; // Manipulacio de bits
    localparam bit          RV_EXT_C = 0; // Instruccions comprimides
    localparam bit          RV_EXT_D = 0; // Operacions float doble precissio de 64 bits (Implica RV_EXT_F)
`ifdef RV_BASE_RV32E
    localparam bit          RV_EXT_E = 1; // Reduccio del nombre de registres
`else
    localparam bit          RV_EXT_E = 0; // Reduccio del nombre de registres
`endif
    localparam bit          RV_EXT_F = 0; // Operacions float simple precissio de 32 bits
    localparam bit          RV_EXT_I = 1; // Instruccions amb enters
    localparam bit          RV_EXT_M = 0; // Multiplicacio i divisio d'enters
    localparam bit          RV_EXT_U = 0; // Implementa User Mode


    // Configuracio de la arquitectura
    //
    localparam int unsigned RV_ARCH_CORES = 1;    // Nombre de cores
    localparam string       RV_ARCH_CPU   = "PP"; // (PP: Pipeline, SC: Single cycle; MC: Multicicle)


    // Configuracio per les extensions de depuracio
    //
`ifdef RV_COMPILER_VERILATOR
    localparam bit          RV_DEBUG_ON = 1; // Habilita la depuracio
`else
    localparam bit          RV_DEBUG_ON = 0; // Deshabilita la depuracio
`endif


    // Configuracio del cache L1 d'instruccions
    //
    localparam bit          RV_ICACHE_ON       = 1;    // Habilita el cache d'instruccions
    localparam int unsigned RV_ICACHE_SETS     = 1;   // Nombre de vias
    localparam int unsigned RV_ICACHE_ELEMENTS = 128; // Nombre d'elements
    localparam int unsigned RV_ICACHE_BLOCKS   = 4;   // Nombre d'instruccions, en cada element del cache


    // Configuracio del cache L1 de dades
    //
    localparam bit          RV_DCACHE_ON       = 0;   // Habilita el cache de dades
    localparam int unsigned RV_DCACHE_SETS     = 1;   // Nombre de vias
    localparam int unsigned RV_DCACHE_ELEMENTS = 128; // Nombre d'elements
    localparam int unsigned RV_DCACHE_BLOCKS   = 4;   // Nombre de words, en cada element del cache


    // Configuracio del cache L2
    //
    localparam bit          RV_L2CACHE_ON      = 0;   // Habilita el cache L2


    // Configuracio de la plataforma de destinacio
    //
`ifdef RV_COMPILER_VERILATOR
    localparam string       RV_TARGET_COMPILER = "VERILATOR";
    localparam string       RV_TARGET_DEVICE   = "UNKNOWN";
`endif
`ifdef RV_COMPILER_QUARTUS
    localparam string       RV_TARGET_COMPILER = "QUARTUS";
    localparam string       RV_TARGET_DEVICE   = "CYCLONE-IV";
`endif


endpackage