module DataMemoryAdapter
    import Types::*;
(
    input  logic         i_clock,      // Clock
    input  logic         i_reset,      // Reset
    input  DataAddr      i_addr,       // Adressa
    input  DataAccess    i_access,     // Modus d'access (byte, half o word)
    input  logic         i_unsigned,   // Lectura eun modus sense signe
    input  logic         i_wrEnable,   // Autoritza escriptura
    input  logic         i_rdEnable,   // Autoritza lectura
    input  Data          i_wrData,     // Dades per escriure
    output Data          o_rdData,     // Dades lleigides
    output logic         o_alignError, // Indica error d'aliniacio
    DataMemoryBus.master bus);         // Interficie amb la memoria

    always_comb begin

        o_alignError = 1'b0;

        bus.addr     = i_addr;
        bus.wrEnable = i_wrEnable;
        bus.rdEnable = i_rdEnable;
        bus.wrMask   = 4'b0000;

        unique casez ({i_access, i_addr[1:0]})
            {DataAccess_Byte, 2'b00}:
                begin
                    bus.wrData = {i_wrData[7:0], 24'b0};
                    bus.wrMask = 4'b1000;
                end

            {DataAccess_Byte, 2'b01}:
                begin
                    bus.wrData = {8'b0, i_wrData[7:0], 16'b0};
                    bus.wrMask = 4'b0100;
                end

            {DataAccess_Byte, 2'b10}:
                begin
                    bus.wrData = {16'b0, i_wrData[7:0], 8'b0};
                    bus.wrMask = 4'b0010;
                end

            {DataAccess_Byte, 2'b11}:
                begin
                    bus.wrData = {24'b0, i_wrData[7:0]};
                    bus.wrMask = 4'b0001;
                end

            {DataAccess_Half, 2'b00}:
                begin
                    bus.wrData = {i_wrData[15:0], 16'b0};
                    bus.wrMask = 4'b1100;
                end

            {DataAccess_Half, 2'b10}:
                begin
                    bus.wrData = {16'b0, i_wrData[15:0]};
                    bus.wrMask = 4'b0011;
                end

            {DataAccess_Word, 2'b00}:
                begin
                    bus.wrData = i_wrData;
                    bus.wrMask = 4'b1111;
                end

            default:
                o_alignError = i_wrEnable;
        endcase


        unique casez ({i_access, i_unsigned, i_addr[1:0]})
            {DataAccess_Byte, 3'b000}:
                o_rdData = {{25{bus.rdData[7]}}, bus.rdData[6:0]};

            {DataAccess_Byte, 3'b001}:
                o_rdData = {{25{bus.rdData[15]}}, bus.rdData[14:8]};

            {DataAccess_Byte, 3'b010}:
                o_rdData = {{25{bus.rdData[23]}}, bus.rdData[22:16]};

            {DataAccess_Byte, 3'b011}:
                o_rdData = {{25{bus.rdData[31]}}, bus.rdData[30:24]};

            {DataAccess_Word, 3'b???}:
                o_rdData = bus.rdData;

            default:
                o_alignError = i_rdEnable;

        endcase
    end

endmodule
