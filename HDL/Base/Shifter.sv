module Shifter
#(
    parameter WIDTH = 32)
(
    input  logic [WIDTH-1:0]         i_data,       // Dades d'entrada
    input  logic [$clog2(WIDTH)-1:0] i_bits,       // Nombre de bits a moure
    input  logic                     i_left,       // Desplaçament a l'esquerra
    input  logic                     i_rotate,     // Selecciona rotacio
    input  logic                     i_arithmetic, // Desplaçament aritmetic
    output logic [WIDTH-1:0]         o_data);      // Dades de sortida


    localparam LEVELS = $clog2(WIDTH);


    // Quartus no soporta l'operador '{<<{xxx}}'
    function logic [WIDTH-1:0] reverse(input logic [WIDTH-1:0] data);

        logic [WIDTH-1:0] xdata;

        for (int i = 0; i < WIDTH; i++) begin
            xdata[i] = data[WIDTH-i-1];
        end

        return xdata;
    endfunction


    // verilator lint_off UNOPTFLAT
    logic [WIDTH-1:0] d[0:LEVELS];
    // verilator lint_on UNOPTFLAT
    logic b, s;

    assign d[0] = i_left ? reverse(i_data) : i_data;
    assign s = d[0][WIDTH-1];
    assign b = ~i_left & i_arithmetic ? s : 1'b0;
    generate
        genvar i;
        for (i = 0; i < LEVELS; i++) begin : BLK1
            assign d[i+1] = i_bits[i] ? { i_rotate ? d[i][(2**i)-1:0] : {2**i{b}}, d[i][WIDTH-1:2**i]} : d[i];
        end
    endgenerate

    assign o_data = i_left ? reverse(d[LEVELS]) : d[LEVELS];

endmodule
