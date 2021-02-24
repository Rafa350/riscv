`include "RV.svh"


`ifdef VERILATOR
`include "Config.sv"
`include "Types.sv"
`endif


module top
(
    input   i_clock,   // Clock
    input   i_reset);  // Reset

    localparam DATA = 16'b_1000_0000_1100_0000;

    int counter;
    logic [15:0] dataIn, dataOut;


    Shifter #(
        .WIDTH (16))
    shifter (
        .i_data       (dataIn),
        .i_bits       (2),
        .i_rotate     (0),
        .i_left       (1),
        .i_arithmetic (0),
        .o_data       (dataOut));


    always_ff @(posedge i_clock) begin
        if (i_reset) begin
            counter <= 0;
            dataIn <= DATA;
            $display("%b", DATA);
        end
        else begin
            $display("%b", dataOut);
            if (counter == 16)
                $finish();
            counter <= counter + 1;
            dataIn <= dataOut;
        end
    end



    initial begin
        counter = 0;
        $display("Start testbench");
    end

endmodule
