cmake_minimum_required(VERSION 3.16.3)
project("syntesis")


# Capeta del s fitxers font
#
set(SOURCE_DIR ../../HDL)

# Llista dels fitxers font
#
set(SOURCE_FILE_LIST
    Processor/Processor.sv
    Processor/Core/CorePP.sv
    Processor/Core/CoreSC.sv
    Processor/Core/CSRUnit.sv)



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

message("* ------------------------------------------------------------------------------------")
message("* Sub-project '${PROJECT_NAME}' configuration.")
message("*   Toochain:")
message("*     sv2v    : " ${SV2V_CMD})
message("*     yosys   : " ${YOSYS_CMD})
message("*")
message("*   Directories:")
message("*     Root    : " ${PROJECT_DIR})
message("*     Current : " ${CMAKE_CURRENT_SOURCE_DIR})
message("*")

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
        COMMAND ${SV2V_CMD} ${SOURCE_DIR}/${SOURCE_FILE} 
    )
endforeach()