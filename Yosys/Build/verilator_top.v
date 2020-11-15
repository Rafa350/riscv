module top (
	i_Clock,
	i_Reset,
	i_ram_rdata,
	o_ram_wdata,
	o_ram_addr,
	o_ram_we,
	i_rom_rdata,
	o_rom_addr
);
	parameter DATA_DBUS_WIDTH = 32;
	parameter ADDR_DBUS_WIDTH = 32;
	parameter DATA_IBUS_WIDTH = 32;
	parameter ADDR_IBUS_WIDTH = 32;
	input i_Clock;
	input i_Reset;
	input [DATA_DBUS_WIDTH - 1:0] i_ram_rdata;
	output [DATA_DBUS_WIDTH - 1:0] o_ram_wdata;
	output [ADDR_DBUS_WIDTH - 1:0] o_ram_addr;
	output o_ram_we;
	input [DATA_IBUS_WIDTH - 1:0] i_rom_rdata;
	output [ADDR_IBUS_WIDTH - 1:0] o_rom_addr;
	ProcessorSC #(
		.DATA_DBUS_WIDTH(DATA_DBUS_WIDTH),
		.ADDR_DBUS_WIDTH(ADDR_DBUS_WIDTH),
		.DATA_IBUS_WIDTH(DATA_IBUS_WIDTH),
		.ADDR_IBUS_WIDTH(ADDR_IBUS_WIDTH)
	) Cpu(
		.i_Clock(i_Clock),
		.i_Reset(i_Reset),
		.o_PgmAddr(o_rom_addr),
		.i_PgmInst(i_rom_rdata),
		.o_MemAddr(o_ram_addr),
		.o_MemWrEnable(o_ram_we),
		.o_MemWrData(o_ram_wdata),
		.i_MemRdData(i_ram_rdata)
	);
endmodule
