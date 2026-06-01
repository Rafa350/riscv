cmake_minimum_required(VERSION 3.28)
project("RISCV" LANGUAGES CXX C)

add_subdirectory(SimulatorRTL)
add_subdirectory(SimulatorBHV)

#add_subdirectory(Yosys)
#add_subdirectory(Testbench)
