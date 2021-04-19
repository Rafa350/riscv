module CacheMem
    import
        Config::*;
#(
    parameter int unsigned DATA_WIDTH = 32,
    parameter int unsigned ADDR_WIDTH = 32)
(
    input  logic            i_clock,  // Clock
    input  logic            i_we,     // Habilita escriptura
    input  [ADDR_WIDTH-1:0] i_addr,   // Adressa
    input  [DATA_WIDTH-1:0] i_wdata,  // Dades per escriptura
    output [DATA_WIDTH-1:0] o_rdata); // Dades lleigides


    generate
        if (RV_TARGET_COMPILER == "VERILATOR") begin

            RwMemory #(
                .DATA_WIDTH (DATA_WIDTH),
                .ADDR_WIDTH (ADDR_WIDTH))
            mem (
                .i_clock (i_clock),
                .i_we    (i_we),
                .i_addr  (i_addr),
                .i_wdata (i_wdata),
                .o_rdata (o_rdata));
        end

        else if (RV_TARGET_COMPILER == "QUARTUS") begin
            altsyncram
            altsyncram_component (
                .address_a      (i_addr),
                .clock0         (i_clock),
                .data_a         (i_wdata),
                .wren_a         (i_we),
                .q_a            (o_rdata),
                .aclr0          (1'b0),
                .aclr1          (1'b0),
                .address_b      (1'b1),
                .addressstall_a (1'b0),
                .addressstall_b (1'b0),
                .byteena_a      (1'b1),
                .byteena_b      (1'b1),
                .clock1         (1'b1),
                .clocken0       (1'b1),
                .clocken1       (1'b1),
                .clocken2       (1'b1),
                .clocken3       (1'b1),
                .data_b         (1'b1),
                .eccstatus      (),
                .q_b            (),
                .rden_a         (1'b1),
                .rden_b         (1'b1),
                .wren_b         (1'b0));

            defparam
                altsyncram_component.clock_enable_input_a          = "BYPASS",
                altsyncram_component.clock_enable_output_a         = "BYPASS",
                altsyncram_component.intended_device_family        = "Cyclone IV E",
                altsyncram_component.lpm_hint                      = "ENABLE_RUNTIME_MOD=NO",
                altsyncram_component.lpm_type                      = "altsyncram",
                altsyncram_component.numwords_a                    = 2**ADDR_WIDTH,
                altsyncram_component.operation_mode                = "SINGLE_PORT",
                altsyncram_component.outdata_aclr_a                = "NONE",
                altsyncram_component.outdata_reg_a                 = "UNREGISTERED",
                altsyncram_component.power_up_uninitialized        = "FALSE",
                altsyncram_component.ram_block_type                = "M9K",
                altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
                altsyncram_component.widthad_a                     = ADDR_WIDTH,
                altsyncram_component.width_a                       = DATA_WIDTH,
                altsyncram_component.width_byteena_a               = 1;
        end
    endgenerate

endmodule