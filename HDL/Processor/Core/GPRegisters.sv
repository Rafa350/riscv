module GPRegisters (
    input  logic                  i_clock,  // Clock
    input  logic                  i_reset,  // Reset
    input  ProcessorDefs::GPRAddr i_raddrA, // Adressa de lectura del port A
    input  ProcessorDefs::GPRAddr i_raddrB, // Adressa de lectura del port B
    input  ProcessorDefs::GPRAddr i_waddr,  // Adressa d'escriptura
    output ProcessorDefs::Data    o_rdataA, // Dades lleigides del port A
    output ProcessorDefs::Data    o_rdataB, // Dades lleigides del port B
    input  logic                  i_we,     // Habilita escriptura
    input  ProcessorDefs::Data    i_wdata); // Dades per escriure


    localparam int unsigned SIZE = 2**$size(ProcessorDefs::GPRAddr);


    ProcessorDefs::Data data[1:SIZE-1];


    // Proces d'escriptura sincrona
    //
    always_ff @(posedge i_clock)
        if (i_reset & Config::RV_GPR_RESET) begin
            for (int unsigned i = $left(data); i <= $right(data); i++)
                data[i] <= ProcessorDefs::Data'(0);
        end
        else if (i_we & (i_waddr != ProcessorDefs::GPRAddr'(0)))
            data[i_waddr] <= i_wdata;

    // Proces de lectura asincrona
    //
    always_comb begin
        o_rdataA = (i_reset | (i_raddrA == ProcessorDefs::GPRAddr'(0))) ? ProcessorDefs::Data'(0) : data[i_raddrA];
        o_rdataB = (i_reset | (i_raddrB == ProcessorDefs::GPRAddr'(0))) ? ProcessorDefs::Data'(0) : data[i_raddrB];
    end


endmodule
