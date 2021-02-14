# Experimental RISCV implementation on FPGA

## CPU features
- Base RV32 or RV64
- Optional extensions E, C and M
- Optional instruction and data caches
- Classic five pipeline stages
- Harvard architecture
- Machine mode only
- CSR block
- For use in embedded systems. Optional caches, use internal FPGA memory.
- Jump address recalculated in ID stage. Zero jump flushes/stalls

## Simulation
- Verilator RTL simulation
- Custom C++ app for behavioral simulation

## Implementation
- Quartus Prime 20.1
- Terasic DE0-Nano (Cyclone-IV)

## Core main files
- CorePP.sv      : 5 stage pipeline
- CoreSC.sv      : Single cycle processor for verification and comparation purposes
- Cache/*.sv     : L1 caches
- Stage/*.sv     : Files for stages
- Pipeline/*.sv  : Files for pipeline registers


## Future things
-  Unified instruction and data memory 
-  L2 Cache and SDRAM interface
-  Peripherical bus (Wishbone ?)
-  UART
-  GPIO
-  Debug interface