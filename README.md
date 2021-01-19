# Experimental RISCV implementation on FPGA

## CPU features
- Base RV32I, RV64I or RV32E
- Optional extensions M and C
- Clasic five pipeline stages
- Harvard architecture
- Machine mode only
- CSR block
- For use in embedded systems. No caches, use internal FPGA memory.
- Jump address recalculated in ID stage. Zero jump flushes/stalls

## Simulation
- Verilator RTL simulation
- Custom C++ app for behavioral simulation

## Implementation
- Quartus Prime 20.1
- Terasic DE0-Nano (Cyclone-IV)

## Core main files
- ProcessorPP.sv : 5 stage pipeline
- ProcessorSC.sv : Single cycle processor for verification and comparation purposes
- Stage/*.sv     : Files for stages
- Pipeline/*.sv  : Files for pipeline registers
    
    
## Future things
-  L1 Instruction cache 
-  L1 Data cache
-  L2 Cache and SDRAM interface
-  Peripherical bus (Wishbone ?)
-  UART
-  GPIO
-  Debug interface