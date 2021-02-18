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

    always_ff @(posedge i_clock) begin
        if (i_reset)
            counter <= 0;
        else
            counter <= counter + 1;
    end


    initial begin
        $display("Start testbench");
        $finish();
    end

endmodule
