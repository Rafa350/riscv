// -----------------------------------------------------------------------
// Implementa un bloc de registres tipus MIPS
// -Un port d'entrada per escriptura del registre 1..N
// -Dos ports independents de lectura dels registres 0 a N
// -El registre 0 sempre val zero
// -Durant el reset, tots els registres s'asignen al valor zero.
//
module RegisterFile
    import Types::*;
(
    // Control
    input  logic   i_clock,                     // Clock
    input  logic   i_reset,                     // Reset

    // Port d'escriptura
    input  RegAddr i_wrAddr,   // Adressa del registre del port escriptura
    input  Data    i_wrData,   // Dades d'escriptura
    input  logic   i_wrEnable, // Habilita l'escriptura

    // Port de lectura A
    input  RegAddr i_rdAddrA, // Adressa del registre del port de lectura A
    output Data    o_rdDataA, // Dades lleigides del port A

    // Port de lectura B
    input  RegAddr i_rdAddrB,  // Adressa del registre del port de lectura B
    output Data    o_rdDataB); // Dades lleigides del port B

    localparam SIZE = 2**$size(RegAddr);
    localparam ZERO = {$size(Data){1'b0}};


    Data data[1:SIZE-1];

    always_ff @(posedge i_clock)
        if (i_reset) begin
            for (int i = $left(data); i <= $right(data); i++)
                data[i] <= ZERO;
        end
        else if (i_wrEnable & (i_wrAddr != 0))
            data[i_wrAddr] <= i_wrData;

    always_comb begin
        o_rdDataA = (i_reset | (i_rdAddrA == 0)) ? ZERO : data[i_rdAddrA];
        o_rdDataB = (i_reset | (i_rdAddrB == 0)) ? ZERO : data[i_rdAddrB];
    end

endmodule
