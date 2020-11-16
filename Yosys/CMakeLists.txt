cmake_minimum_required(VERSION 3.16.3)


project(cpu-riscv-yosys
    VERSION 1.0
    DESCRIPTION "CPU-RISC-V: Yosys"
)

set(CMD_YPSYS yosys)
set(CMD_SV2V sv2v)


add_custom_target(
    yosys ALL
    DEPENDS verilog.v
)

add_custom_command(
    OUTPUT  verilog.v
    DEPENDS ../HDL/*.sv
    COMMAND ${CMD_SV2V}
    ARGS    
)