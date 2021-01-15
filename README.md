# Experimental RISCV implementation on FPGA

## CPU features
- Base RV32I, RV64I or RV32E
- Optional extensions M & C
- Clasic five pipeline stages
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
- ProcessorPP.v : 5 stage pipeline
- ProcessorSC.v : Single cycle processor for verification/Comparation purposes
- Stage/*.v     : Files for stages
- Pipeline/*.v  : Files for pipeline registers*.v 
    