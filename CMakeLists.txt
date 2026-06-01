cmake_minimum_required(VERSION 3.28)
project("RISCV" LANGUAGES CXX C)

add_subdirectory(Verilator)
add_subdirectory(Simulator)

#add_subdirectory(Yosys)
#add_subdirectory(Testbench)
