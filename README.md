# Experimental RISCV implementacion on FPGA

## CPU features
- Base RV32I
- Optional sxtensions M & C
- Clasic five pipeline stages
- Machine mode only
- CSR block
- For use in embedded systems. No caches, use internal FPGA memory.
- Jump address recalculated in ID stage. Zero jump flushes/stalls

## Simulation
- Verilator RTL simulation
- Custom C++ app for behavioral simulation
