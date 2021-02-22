module BarrelShifter
#(
    parameter WIDTH = 32)
(
    input  logic [WIDTH-1:0]         i_data,   // Dades d'entrada
    input  logic [$clog2(WIDTH)-1:0] i_bits,   // Nombre de bits a moure
    input  logic                     i_left,   // Selecciona esquerra
    input  logic                     i_rotate, // Selecciona rotacio
    output logic [WIDTH-1:0]         o_data);  // Dasdes de sortida


    logic [WIDTH-1:0] d0, dx0;

    BarrelShifter_ROTATOR #(
        .WIDTH(WIDTH),
        .BITS(1))
    rotator0 (
        .i_data   (i_data),
        .i_rotate (i_rotate),
        .o_data   (dx0));

    Mux2To1 #(
        .WIDTH (WIDTH))
    mux0 (
        .i_select (i_left),
        .i_input0 (i_data),
        .i_input1 (dx0),
        .o_output (d0));

    generate
        genvar i;
        for (i = 0; i < $clog2(WIDTH); i++) begin : BLK1

            logic [WIDTH-1:0] d, dx;

            if (i == 0) begin
                BarrelShifter_ROTATOR #(
                    .WIDTH(WIDTH),
                    .BITS(2**i))
                rotator (
                    .i_data   (d0),
                    .i_rotate (i_rotate),
                    .o_data   (BLK1[i].dx));

                Mux2To1 #(
                    .WIDTH (WIDTH))
                mux (
                    .i_select (i_left ^ i_bits[i]),
                    .i_input0 (d0),
                    .i_input1 (BLK1[i].dx),
                    .o_output (BLK1[i].d));
            end

            else begin
                BarrelShifter_ROTATOR #(
                    .WIDTH(WIDTH),
                    .BITS(2**i))
                rotator (
                    .i_data   (BLK1[i-1].d),
                    .i_rotate (i_rotate),
                    .o_data   (BLK1[i].dx));

                Mux2To1 #(
                    .WIDTH (WIDTH))
                mux (
                    .i_select (i_left ^ i_bits[i]),
                    .i_input0 (BLK1[i-1].d),
                    .i_input1 (BLK1[i].dx),
                    .o_output (BLK1[i].d));
            end

            if (i == $clog2(WIDTH)-1)
                assign o_data = BLK1[i].d;
        end

    endgenerate

endmodule



module BarrelShifter_ROTATOR
#(
    parameter WIDTH = 32,
    parameter BITS = 1)
(
    input  logic [WIDTH-1:0] i_data,  // Dades d'entrada
    input  logic i_rotate,            // Selecciona rotacio
    output logic [WIDTH-1:0] o_data); // Dades de sortida

    assign o_data = { i_rotate ? i_data[BITS-1:0] : {BITS{1'b0}},  i_data[WIDTH-1:BITS]};

endmodule