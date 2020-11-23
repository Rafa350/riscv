cmake_minimum_required(VERSION 3.16.3)

project(cpu-riscv-yosys
    VERSION 1.0
    DESCRIPTION "CPU-RISC-V: Yosys"
    LANGUAGES NONE
)


# Capeta del s fitxers font
#
set(SOURCE_DIR ../../HDL)

# Llista dels fitxers font
#
set(SOURCE_FILE_LIST
    ProcessorPP.sv
    ProcessorSC.sv)


# Busca la ubicacio de sv2v
#
find_program(
    SV2V_CMD
    NAMES sv2v
)

# Busca la ubicacio de yosys
#
find_program(
    YOSYS_CMD
    NAMES yosys
)


# Target
#    
set(DEPENDS_FILE_LIST ${SOURCE_FILE_LIST})    
list(TRANSFORM DEPENDS_FILE_LIST APPEND .v)

add_custom_target(
    yosys ALL
    DEPENDS ${DEPENDS_FILE_LIST}
)


# Genera el arxiu verilog
#
foreach(SOURCE_FILE ${SOURCE_FILE_LIST})
    add_custom_command(
        OUTPUT  ${SOURCE_FILE}.v
        SOURCES ${SOURCE_DIR}/${SOURCE_FILE}
        COMMAND ${SV2V_CMD} ${SOURCE_DIR}/${SOURCE_FILE} > ${SOURCE_FILE}.v
    )
endforeach()