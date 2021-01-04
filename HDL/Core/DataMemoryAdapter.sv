module DataMemoryAdapter
    import Types::*;
(
    input  logic         i_clock,      // Clock
    input  logic         i_reset,      // Reset
    input  DataAddr      i_addr,       // Adressa en bytes
    input  DataAccess    i_access,     // Modus d'access (byte, half o word)
    input  logic         i_unsigned,   // Lectura en modus sense signe
    input  logic         i_wrEnable,   // Autoritza escriptura
    input  logic         i_rdEnable,   // Autoritza lectura
    input  Data          i_wrData,     // Dades per escriure
    output Data          o_rdData,     // Dades lleigides
    output logic         o_alignError, // Indica error d'aliniacio
    DataMemoryBus.master bus);         // Interficie amb la memoria

    always_comb begin

        o_alignError = ((i_access == DataAccess_Word) & (i_addr[1:0] != 2'b00)) |
                       ((i_access == DataAccess_Half) & (i_addr[0] != 1'b0));

        bus.addr     = i_addr;
        bus.access   = i_access;
        bus.wrEnable = i_wrEnable & !o_alignError;
        bus.rdEnable = i_rdEnable & !o_alignError;
        bus.wrData   = i_wrData;

        unique casez ({i_access, i_unsigned})
            {DataAccess_Byte, 1'b0}:
                o_rdData = {{25{bus.rdData[7]}}, bus.rdData[6:0]};

            {DataAccess_Byte, 1'b1}:
                o_rdData = {24'b0, bus.rdData[7:0]};

            {DataAccess_Half, 1'b0}:
                o_rdData = {{17{bus.rdData[15]}}, bus.rdData[14:0]};

            {DataAccess_Half, 1'b1}:
                o_rdData = {16'b0, bus.rdData[15:0]};

            {DataAccess_Word, 1'b?}:
                o_rdData = bus.rdData;

            default:
                o_rdData = bus.rdData;

        endcase
    end

endmodule
