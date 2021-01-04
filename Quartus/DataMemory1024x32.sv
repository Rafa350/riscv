module DataMemory1024x32
    import Types::*;
(
    input               i_clock, // Clock
    DataMemoryBus.slave bus);    // Bus de memoria de dades
          
    Data data;
    logic [3:0] we;
    
    always_comb begin

        data = bus.wrData;
        we = 4'b0;

        unique casez ({bus.access, bus.addr[1:0]})
            {DataAccess_Byte, 2'b00}: begin
                data = {24'b0, bus.wrData[7:0]};
                we = 4'b0001;
            end
            
            {DataAccess_Byte, 2'b01}: begin
                data = {16'b0, bus.wrData[7:0], 8'b0};
                we = 4'b0010;
            end
            
            {DataAccess_Byte, 2'b10}: begin
                data = {8'b0, bus.wrData[7:0], 16'b0};
                we = 4'b0100;
            end
            
            {DataAccess_Byte, 2'b11}: begin
                data = {bus.wrData[7:0], 24'b0};
                we = 4'b1000;
            end
        
            {DataAccess_Half, 2'b0?}: begin
                data = {16'b0, bus.wrData[15:0]};
                we = 4'b0011;
            end
            
            {DataAccess_Half, 2'b1?}: begin
                data = {bus.wrData[15:0], 16'b0};
                we = 4'b1100;
            end
        
            {DataAccess_Word, 2'b??}: begin
                data = bus.wrData;
                we = 4'b1111;
            end
        endcase
    end        

    ram1024x8 
    ram0(
        .clock     (i_clock),
        .address   (bus.addr[11:2]),
        .wren      (we[0] & bus.wrEnable),
        .data      (data),
        .q         (bus.rdData[7:0]));
        
    ram1024x8 
    ram1(
        .clock     (i_clock),
        .address   (bus.addr[11:2]),
        .wren      (we[1] & bus.wrEnable),
        .data      (data),
        .q         (bus.rdData[15:8]));

    ram1024x8 
    ram2(
        .clock     (i_clock),
        .address   (bus.addr[11:2]),
        .wren      (we[2] & bus.wrEnable),
        .data      (data),
        .q         (bus.rdData[23:16]));

    ram1024x8 
    ram3(
        .clock     (i_clock),
        .address   (bus.addr[11:2]),
        .wren      (we[3] & bus.wrEnable),
        .data      (data),
        .q         (bus.rdData[31:24]));        

endmodule
