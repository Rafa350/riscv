// Patent US5978822A expired 2015.
// Circuit for Rotating, Left Shifting, or Right Shifting Bits

module BarrelShifter
#(
    parameter WIDTH = 32)
(
    input  logic [WIDTH-1:0]         i_data,  // Dades d'entrada
    input  logic [$clog2(WIDTH)-1:0] i_bits,  // Nombre de bits a moure
    input  logic                     i_dir,   // Direccio: 0=Left, 1=Right
    input  logic                     i_sr,    // 0=Shift, 1=Rotate
    output logic [WIDTH-1:0]         o_data); // Dasdes de sortida


    localparam BITS_WIDTH = $clog2(WIDTH);


    logic [WIDTH-1:0] datax;


    function logic[WIDTH-1:0] reverse(input logic [WIDTH-1:0] inp);

        logic [WIDTH-1:0] out;

        for (int unsigned i = 0; i < WIDTH; i++) begin : L1
            out[i] = inp[WIDTH-i-1];
        end

        return out;

    endfunction


    generate

        // Inversio de i_data si el desplaçament es a l'esquerra
        //
        assign datax = i_dir ? reverse(i_data) : i_data;

        // Deplaçament de bits
        //
        genvar i;
        for (i = 0; i < BITS_WIDTH; i++) begin : LL

            logic [WIDTH-1:0] data;

            if (i == 0) begin
                SRL #(
                    .WIDTH (WIDTH),
                    .BITS (2**i))
                srl (
                    .i_enable (i_bits[i] ^ i_dir),
                    .i_input  (datax),
                    .i_sr     (i_sr),
                    .o_output (LL[i].data));
            end
            else begin
                SRL #(
                    .WIDTH (WIDTH),
                    .BITS (2**i))
                srl (
                    .i_enable (i_bits[i] ^ i_dir),
                    .i_input  (LL[i-1].data),
                    .i_sr     (i_sr),
                    .o_output (LL[i].data));
            end


            if (i == BITS_WIDTH-1) begin

                logic [WIDTH-1:0] srlx_output;
                SRL #(
                    .WIDTH (WIDTH),
                    .BITS (1))
                srlx (
                    .i_enable (1'b1),
                    .i_input  (LL[i].data),
                    .i_sr     (i_sr),
                    .o_output (srlx_output));

                assign o_data = i_dir ? reverse(srlx_output) : LL[i].data;
            end
        end

    endgenerate

endmodule


module SRL
#(
    parameter WIDTH = 32,
    parameter BITS = 1)
(
    input  logic [WIDTH-1:0] i_input,   // Dades d'entrada
    input  logic             i_enable,  // Habilita el desplaçament
    input  logic             i_sr,      // 0=Shift, 1=Rotate
    output logic [WIDTH-1:0] o_output); // Dades de sortida


    logic [BITS-1:0] fill;
    assign fill = i_sr ? i_input[BITS-1:0] : {BITS{1'b0}};
    assign o_output = i_enable ? {i_input[WIDTH-BITS-1:0], fill} : i_input;

endmodule
