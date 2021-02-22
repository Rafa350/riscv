`include "RV.svh"


`ifdef VERILATOR
`include "Config.sv"
`include "Types.sv"
`endif


module top
(
    input   i_clock,   // Clock
    input   i_reset);  // Reset


    int counter;
    logic [15:0] dataIn, dataOut;


    BarrelShifter #(
        .WIDTH (16))
    barrelShifter (
        .i_data   (dataIn),
        .i_bits   (3),
        .i_rotate (1),
        .i_left   (1),
        .o_data   (dataOut));


    always_ff @(posedge i_clock) begin
        if (i_reset) begin
            counter <= 0;
            dataIn <= 16'b0000_1111_1010_1010;
            $display("%b", 16'b0000_1111_1010_1010);
        end
        else begin
            $display("%b", dataOut);
            if (counter == 32)
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
