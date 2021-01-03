module DataMemoryAdapter
    import Types::*;
(
    input  logic         i_clock,      // Clock
    input  logic         i_reset,      // Reset
    input  DataAddr      i_addr,       // Adressa
    input  DataAccess    i_access,     // Modus d'access (byte, half o word)
    input  logic         i_unsigned,   // Lectura en modus sense signe
    input  logic         i_wrEnable,   // Autoritza escriptura
    input  logic         i_rdEnable,   // Autoritza lectura
    input  Data          i_wrData,     // Dades per escriure
    output Data          o_rdData,     // Dades lleigides
    output logic         o_alignError, // Indica error d'aliniacio
    DataMemoryBus.master bus);         // Interficie amb la memoria

    localparam BYTE_ADDR_WIDTH = $clog2(($size(Data)+7)/8);

    logic [BYTE_ADDR_WIDTH-1:0] byteAddr;
    assign byteAddr = i_addr[BYTE_ADDR_WIDTH-1:0];

    always_comb begin

        o_alignError = 1'b0;

        bus.addr     = i_addr;
        bus.wrEnable = i_wrEnable;
        bus.rdEnable = i_rdEnable;
        bus.wrMask   = 4'b0000;
        bus.wrData   = 32'b0;
        o_rdData     = bus.rdData;

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
            {DataAccess_Byte, 3'b0_00}:
                o_rdData = {{25{bus.rdData[7]}}, bus.rdData[6:0]};

            {DataAccess_Byte, 3'b0_01}:
                o_rdData = {{25{bus.rdData[15]}}, bus.rdData[14:8]};

            {DataAccess_Byte, 3'b0_10}:
                o_rdData = {{25{bus.rdData[23]}}, bus.rdData[22:16]};

            {DataAccess_Byte, 3'b0_11}:
                o_rdData = {{25{bus.rdData[31]}}, bus.rdData[30:24]};

            {DataAccess_Half, 3'b0_00}:
                o_rdData = {{17{bus.rdData[15]}}, bus.rdData[14:0]};

            {DataAccess_Half, 3'b0_10}:
                o_rdData = {{17{bus.rdData[31]}}, bus.rdData[30:16]};

            {DataAccess_Word, 3'b?_00}:
                o_rdData = bus.rdData;

            default:
                o_alignError = i_rdEnable;

        endcase
    end

endmodule
