module DataMemoryAdapter
    import Types::*;
(
    input  logic      i_clock,      // Clock
    input  logic      i_reset,      // Reset
    input  DataAddr   i_addr,       // Adressa en bytes
    input  DataAccess i_access,     // Modus d'access (byte, half o word)
    input  logic      i_unsigned,   // Lectura en modus sense signe
    input  logic      i_wrEnable,   // Autoritza escriptura
    input  logic      i_rdEnable,   // Autoritza lectura
    input  Data       i_wrData,     // Dades per escriure
    output Data       o_rdData,     // Dades lleigides
    output logic      o_busy,       // Indica que esta ocupat
    output logic      o_alignError, // Indica error d'aliniacio
    DataBus.master    bus);         // Interficie amb la memoria


    ByteMask wb;


    assign bus.addr  = {i_addr[31:2], 2'b00};
    assign bus.re    = i_rdEnable & ~o_alignError;
    assign bus.we    = i_wrEnable & ~o_alignError;
    assign bus.wb    = i_wrEnable & ~o_alignError ? wb : ByteMask'(0);

    assign o_busy = bus.busy;

    always_comb begin

        o_alignError = 1'b0;
        o_rdData = Data'(0);

        bus.wdata = Data'(0);
        wb = 4'b0000;

        // verilator lint_off CASEINCOMPLETE
        unique case (i_access)
            DataAccess_Byte:
                unique case (i_addr[1:0])
                    2'b00: o_rdData = {i_unsigned ? 24'b0 : {24{bus.rdata[7]}}, bus.rdata[7:0]};
                    2'b01: o_rdData = {i_unsigned ? 24'b0 : {24{bus.rdata[15]}}, bus.rdata[15:8]};
                    2'b10: o_rdData = {i_unsigned ? 24'b0 : {24{bus.rdata[23]}}, bus.rdata[23:16]};
                    2'b11: o_rdData = {i_unsigned ? 24'b0 : {24{bus.rdata[31]}}, bus.rdata[31:24]};
                endcase

            DataAccess_Half:
                unique case (i_addr[1:0])
                    2'b00: o_rdData = {i_unsigned ? 16'b0 : {16{bus.rdata[15]}}, bus.rdata[15:0]};
                    2'b10: o_rdData = {i_unsigned ? 16'b0 : {16{bus.rdata[31]}}, bus.rdata[31:16]};
                    default: o_alignError = 1'b1;
                endcase

            DataAccess_Word:
                unique case (i_addr[1:0])
                    2'b00: o_rdData = bus.rdata;
                    default: o_alignError = 1'b1;
                endcase
        endcase
        // verilator lint_on CASEINCOMPLETE

        // verilator lint_off CASEINCOMPLETE
        unique case (i_access)
            DataAccess_Byte:
                unique case (i_addr[1:0])
                    2'b00: begin
                        bus.wdata = {24'b0, i_wrData[7:0]};
                        wb = 4'b0001;
                    end
                    2'b01: begin
                        bus.wdata = {16'b0, i_wrData[7:0], 8'b0};
                        wb = 4'b0010;
                    end
                    2'b10: begin
                        bus.wdata = {8'b0, i_wrData[7:0], 16'b0};
                        wb = 4'b0100;
                    end
                    2'b11: begin
                        bus.wdata = {i_wrData[7:0], 24'b0};
                        wb = 4'b1000;
                    end
                endcase

            DataAccess_Half:
                unique case (i_addr[1:0])
                    2'b00: begin
                        bus.wdata = {16'b0, i_wrData[15:0]};
                        wb = 4'b0011;
                    end
                    2'b10: begin
                        bus.wdata = {i_wrData[15:0], 16'b0};
                        wb = 4'b1100;
                    end
                    default:
                        o_alignError = 1'b1;
                endcase

            DataAccess_Word:
                unique case (i_addr[1:0])
                    2'b00: begin
                        bus.wdata = i_wrData;
                        wb = 4'b1111;
                    end
                    default:
                        o_alignError = 1'b1;
                endcase
        endcase
        // verilator lint_on CASEINCOMPLETE
    end


endmodule
