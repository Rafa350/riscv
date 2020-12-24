module DataMemoryAdapter
    import Types::*;
(
    input  DataAddr      i_addr,
    input  DataSize      i_size,
    input  logic         i_unsigned,
    input  logic         i_wrEnable,
    input  Data          i_wrData,
    input  logic         i_rdEnable,
    output Data          o_rdData,
    output logic         o_alignError,
    DataMemoryBus.master bus);

    logic [3:0]  wrMask;

    always_comb begin

        alignError = 1'b0;

        unique casez ({i_size, i_addr[1:0]})
            {DataSize_8, 2'b00}:
                begin
                    bus.wrData = {i_wrData[7:0], 24'b0};
                    wrMask = 4'b1000;
                end

            {DataSize_8, 2'b01}:
                begin
                    bus.wrData = {8'b0, i_wrData[7:0], 16'b0};
                    wrMask = 4'b0100;
                end

            {DataSize_8, 2'b10}:
                begin
                    bus.wrData = {16'b0, i_wrData[7:0], 8'b0};
                    wrMask = 4'b0010;
                end

            {DataSize_8, 2'b11}:
                begin
                    bus.wrData = {24'b0, i_wrData[7:0]};
                    wrMask = 4'b0001;
                end

            {DataSize_16, 2'b00}:
                begin
                    bus.wrData = {i_wrData[15:0], 16'b0};
                    wrMask = 4'b1100;
                end

            {DataSize_16, 2'b10}:
                begin
                    bus.wrData = {16'b0, i_wrData[15:0]};
                    wrMask = 4'b0011;
                end

            {DataSize_32, 2'b00}:
                begin
                    bus.wrData = i_wrData;
                    wrMask = 4'b1111;
                end

            default:
                o_alignError = 1'b1;
        endcase

        unique casez ({i_size, i_unsigned, i_addr[1:0]})
            {DataSize_8, 3'b000}:
                o_rdData = {{24{bus[7]}}, bus.rdData[6:0]};

            {DataSize_8, 3'b001}:
                o_rdData = {{24{bus[15]}}, bus.rdData[14:8]};

            {DataSize_8, 3'b010}:
                o_rdData = {{24{bus[23]}}, bus.rdData[22:16]};

            {DataSize_8, 3'b011}:
                o_rdData = {{24{bus[31]}}, bus.rdData[30:24]};

            {DataSize_32, 3b???}:
                o_rdData = bus.rdData;

            default:
                o_alignError = 1'b1;

        endcase
    end

endmodule
