`include "RV.svh"


package Config;


`ifndef RV_BASE_32
    `ifndef RV_BASE_64
        `define RV_BASE_32
    `endif
`endif


`ifdef RV_BASE_32
    localparam bit RV_BASE_32 = 1;
    localparam bit RV_BASE_64 = 0;
`else
    `ifdef RV_BASE_64
        localparam bit RV_BASE_32 = 0;
        localparam bit RV_BASE_64 = 1;
    `endif
`endif

    localparam bit RV_EXT_A = 0; // Operacions atomiques

    localparam bit RV_EXT_B = 0; // Manipulacio de bits

`ifdef RV_EXT_C
    localparam bit RV_EXT_C = 1; // Instruccions comprimides
`else
    localparam bit RV_EXT_C = 0;
`endif

    localparam bit RV_EXT_D = 0; // Operacions float doble precissio de 64 bits (Implica RV_EXT_F)

`ifdef RV_EXT_E
    localparam bit RV_EXT_E = 1; // Reduccio del nombre de registres
`else
    localparam bit RV_EXT_E = 0;
`endif

    localparam bit RV_EXT_F = 0; // Operacions float simple precissio de 32 bits

    localparam bit RV_EXT_I = 1; // Instruccions amb enters

`ifdef RV_EXT_M
    localparam bit RV_EXT_M = 1; // Multiplicacio i divisio d'enters
`else
    localparam bit RV_EXT_M = 0; // Multiplicacio i divisio d'enters
`endif

    localparam bit RV_EXT_U = 0; // Implementa User Mode


    // Configuracio dels parametres fundamentals
    //
    localparam int unsigned DATA_WIDTH = RV_BASE_32 ? 32 : 64;
    localparam int unsigned ADDR_WIDTH = 32;
    localparam int unsigned PC_WIDTH   = 32;
    localparam int unsigned REG_WIDTH  = RV_EXT_E ? 4 : 5;


    // Configuracio de la arquitectura
    //
    localparam int unsigned RV_ARCH_CORES = 1;    // Nombre de cores
    localparam string       RV_ARCH_CPU   = "PP"; // (PP: Pipeline, SC: Single cycle; MC: Multicicle)


    // Configuracio per les extensions de depuracio
    //
`ifdef RV_COMPILER_VERILATOR
    localparam bit RV_DEBUG_ON = 1; // Habilita la depuracio
`else
    localparam bit RV_DEBUG_ON = 0; // Deshabilita la depuracio
`endif


    // Configuracio del cache L1 d'instruccions
    //
`ifdef RV_ICACHE_ON
    localparam bit          RV_ICACHE_ON       = 1;   // Habilita el cache d'instruccions
    localparam int unsigned RV_ICACHE_SETS     = 1;   // Nombre de vias
    localparam int unsigned RV_ICACHE_ELEMENTS = 128; // Nombre d'elements
    localparam int unsigned RV_ICACHE_BLOCKS   = 4;   // Nombre d'instruccions, en cada element del cache
`else
    localparam bit          RV_ICACHE_ON       = 0;
`endif


    // Configuracio del cache L1 de dades
    //
`ifdef RV_DCACHE_ON
    localparam bit          RV_DCACHE_ON       = 1;   // Habilita el cache de dades
    localparam int unsigned RV_DCACHE_SETS     = 1;   // Nombre de vias
    localparam int unsigned RV_DCACHE_ELEMENTS = 128; // Nombre d'elements
    localparam int unsigned RV_DCACHE_BLOCKS   = 4;   // Nombre de words, en cada element del cache
`else
    localparam bit          RV_DCACHE_ON       = 0;
`endif


    // Configuracio del cache L2
    //
    localparam bit          RV_L2CACHE_ON      = 0;   // Habilita el cache L2


    // Configuracio de la plataforma de destinacio
    //
`ifdef RV_COMPILER_VERILATOR
    localparam string RV_TARGET_COMPILER = "VERILATOR";
    localparam string RV_TARGET_DEVICE   = "UNKNOWN";
`endif
`ifdef RV_COMPILER_QUARTUS
    localparam string RV_TARGET_COMPILER = "QUARTUS";
    localparam string RV_TARGET_DEVICE   = "CYCLONE-IV";
`endif


endpackage