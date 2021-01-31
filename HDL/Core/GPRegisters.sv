// -----------------------------------------------------------------------
// Implementa un bloc de registres tipus MIPS
// -Un port d'entrada per escriptura del registre 1..N
// -Dos ports independents de lectura dels registres 0 a N
// -El registre 0 sempre val zero
// -Durant el reset, tots els registres s'asignen al valor zero.
//
module GPRegisters
    import Types::*;
(
    // Control
    input  logic   i_clock,  // Clock
    input  logic   i_reset,  // Reset

    // Interficie
    GPRegistersBus bus);     // Interficie


    localparam SIZE = 2**$size(GPRAddr);


    Data data[1:SIZE-1];


    // Proces d'escriptura sincrona
    //
    always_ff @(posedge i_clock)
        if (i_reset) begin
            for (int i = $left(data); i <= $right(data); i++)
                data[i] <= Data'(0);
        end
        else if (bus.slaveWriter.wr & (bus.slaveWriter.wrAddr != GPRAddr'(0)))
            data[bus.slaveWriter.wrAddr] <= bus.slaveWriter.wrData;

    // Proces de lectura asincrona
    //
    always_comb begin
        bus.slaveReader.rdDataA = (i_reset | (bus.slaveReader.rdAddrA == GPRAddr'(0))) ? Data'(0) : data[bus.slaveReader.rdAddrA];
        bus.slaveReader.rdDataB = (i_reset | (bus.slaveReader.rdAddrB == GPRAddr'(0))) ? Data'(0) : data[bus.slaveReader.rdAddrB];
    end


endmodule
