AS = "/cygdrive/c/program files/MIPS-gcc/bin/mips-mti-elf-as.exe"
AS_FLAGS = -a 

CC = "/cygdrive/c/program files/MIPS-gcc/bin/mips-mti-elf-gcc.exe"
CC_FLAGS = -g -Wall

OC = "/cygdrive/c/program files/MIPS-gcc/bin/mips-mti-elf-objcopy.exe"
OC_FLAGS = --output-target=verilog --only-section=.text


default: demo.txt

demo.txt: demo.out
	$(OC) $(OC_FLAGS) $< $@

demo.out: demo.S
	$(AS) $(AS_FLAGS) $< -o $@
	