import types::*;


module pgm
#(
    parameter ADDR_WIDTH = 32,
    parameter INST_WIDTH = 32)
(   
    RdBusInterface.Slave io_PgmBus);
    
    logic [7:0] data[0:1024];
    
    /*
    initial
        $readmemh("../Firmware/a.txt", data);
        
    always io_PgmBus.RdData = { data[i_addr], data[i_addr+1], data[i_addr+2], data[i_addr+3]};
    */
    always_comb
        case (io_PgmBus.Addr[31:2]) 
            32'h0  : io_PgmBus.RdData = { InstOp_LW,     5'd0, 5'd1, 16'd0             }; // LW  $1, 0($0)
            32'h1  : io_PgmBus.RdData = { InstOp_LW,     5'd0, 5'd2, 16'd1             }; // LW  $2, 1($0)
            32'h2  : io_PgmBus.RdData = { InstOp_Type_R, 5'd3, 5'd1, 5'd2, InstFn_ADD  }; // ADD $3, $1, $2)
            32'h3  : io_PgmBus.RdData = { InstOp_SW,     5'd0, 5'd3, 16'd3             }; // SW  $3, 2($0)
            default: io_PgmBus.RdData = { InstOp_J,      26'd0                         }; // J   0
        endcase

endmodule