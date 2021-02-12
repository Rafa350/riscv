module DCache
    import Types::*;
(
    // Senyals de control
    //
    input  logic     i_clock,      // Clock
    input  logic     i_reset,      // Reset

    input  DataWAddr i_addr,
    input  logic     i_we,
    input  logic     i_re,
    input  logic     i_be,
    input  Data      i_wdata,
    output Data      o_rdata,

    // Interficie amb la memoria o amb el cache L2
    output DataWAddr o_mem_addr,   // Adressa en words
    output logic     o_mem_we,     // Habilita escriptura
    output logic     o_mem_re,     // Habilita lectura
    output Data      o_mem_wdata,  // Dades per escriure
    input  logic     i_mem_rdata,  // Dades lleigides

    output logic     o_busy,
    output logic     o_hit);


endmodule