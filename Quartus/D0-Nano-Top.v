

`define RAM_DATA_WIDTH 16
`define RAM_ADDR_WIDTH 8
`define ROM_DATA_WIDTH 16
`define ROM_ADDR_WIDTH 12
`define IO_DATA_WIDTH 8


// Tipus d'instruccio (Intruction Type)
//
`define LIT             16'h8000
`define JMP             16'h0000
`define BRZ             16'h2000
`define JSR             16'h4000
`define DO              16'h6000

// Operacio amb la ALU
//
`define OP_T            16'h0000
`define OP_N            16'h0100
`define OP_TaddN        16'h0200
`define OP_TandN        16'h0300
`define OP_TorN         16'h0400
`define OP_TxorN        16'h0500
`define OP_notT         16'h0600
`define OP_NeqT         16'h0700
`define OP_NltT         16'h0800
`define OP_Tright       16'h0900
`define OP_Tleft        16'h0A00
`define OP_MEM          16'h0B00

// Operacions amb el D-Stack
//
`define D_              16'h0000  // Sense canvis
`define Ddec            16'h0003  // Dsp--
`define Dinc            16'h0001  // Dsp++

// Operacio amb el R-Stack
//
`define R_              16'h0000  // Sense canvis
`define Rdec            16'h000C  // Rsp--
`define Rinc            16'h0004  // Rsp++

// Operacio de transferencia
//
`define M_              16'h0000  // Sense canvis
`define TtoN            16'h0010  // Mou T a N
`define TtoR            16'h0020  // Mou T a R
`define NtoMEM          16'h0030  // Mou N a ram[T]
`define NtoIO           16'h0040  // Mou N a io[T]

// Sufixos de la intruccio DO
//
`define _RET            | 16'h1000 | `Rdec

// Instruccions literals (LIT)
//
`define PUSH(a)         (`LIT | ((a) & 16'h7FFF))

// Instruccions de salt (JMP, JUMPZ, CALL, RET)
//
`define JUMP(a)         (`JMP | ((a) & 16'h1FFF))
`define JUMPZ(a)        (`BRZ | ((a) & 16'h1FFF))
`define CALL(a)         (`JSR | ((a) & 16'h1FFF))
`define RET             (`DO `_RET)

// Instruccions ALU            op-code     mov     dsp     rsp
//                           +-----------+-------+-------+-------+
`define ADD             (`DO | `OP_TaddN | `M_   | `Ddec | `R_   )
`define DUP             (`DO | `OP_T     | `TtoN | `Dinc | `R_   )
`define DROP            (`DO | `OP_N     | `M_   | `Ddec | `R_   )
`define INVERT          (`DO | `OP_notT  | `M_   | `D_   | `R_   )
`define NIP
`define OVER
`define READ            (`DO | `OP_MEM   | `M_   | `D_   | `R_   )
`define SWAP
`define WRITE           (`DO | `OP_N     | `M_   | `D_   | `R_   )


module top(
    input wire CLOCK_50,
    input wire [1:0] KEY,
    input wire [3:0] SW,
    output wire [7:0] LED);
    
    wire clk = ~KEY[0];
    wire rst = ~KEY[1];
    
    wire ram_we;
    wire [`RAM_ADDR_WIDTH-1:0] ram_din, ram_dout;
    wire [`RAM_ADDR_WIDTH-1:0] ram_addr;
    
    wire [`ROM_ADDR_WIDTH-1:0] rom_addr;
    reg [`ROM_DATA_WIDTH-1:0] rom_din;
    
    ram ram0(
        .clk(clk),
        .din(ram_dout),
        .dout(ram_din),
        .we(ram_we),
        .raddr(ram_addr[5:0]),
        .waddr(ram_addr[5:0]));

    cpu #(
        .RAM_DATA_WIDTH(`RAM_DATA_WIDTH), 
        .RAM_ADDR_WIDTH(`RAM_ADDR_WIDTH),
        .ROM_DATA_WIDTH(`ROM_DATA_WIDTH),
        .ROM_ADDR_WIDTH(`ROM_ADDR_WIDTH)) 
    cpu0(
        .i_clk(clk),
        .i_rst(rst),
        .rom_din(rom_din),
        .rom_addr(rom_addr),
        .ram_we(ram_we),
        .ram_din(ram_din),
        .ram_dout(ram_dout),
        .ram_addr(ram_addr));
    
    always @* begin
        case (rom_addr)
            12'd0: rom_din = `PUSH(16'h001A);
            12'd1: rom_din = `INVERT;
            12'd2: rom_din = `PUSH(16'h001C);
            12'd3: rom_din = `CALL(16'd8);
            12'd4: rom_din = `JUMP(16'd0);
            12'd5: rom_din = 16'h0;
            12'd6: rom_din = `PUSH(16'h0000);
            12'd7: rom_din = `READ;
            12'd8: rom_din = 16'h0;
            12'd9: rom_din = 16'h0;
            12'd10: rom_din = `PUSH(16'h002A);
            12'd11: rom_din = `PUSH(16'h002B);
            12'd12: rom_din = `PUSH(16'h002C);
            12'd13: rom_din = `DROP;
            12'd14: rom_din = `DROP;
            12'd15: rom_din = `DROP `_RET;
            12'd16: rom_din = `PUSH(16'h0);
            12'd17: rom_din = `JUMPZ(16'h1);
            12'd18: rom_din = `JUMP(16'h0);
            12'd19: rom_din = 16'h0;
            12'd20: rom_din = 16'h0;
            default: rom_din = `JUMP(16'd0);
        endcase
    end
    
    assign LED = rom_addr[7:0];
        
endmodule
