AS = riscv64-linux-gnu-as
AS_FLAGS = -a 

CC = riscv64-linux-gnu-gcc
CC_FLAGS = -g -Wall

OC = riscv64-linux-gnu-objcopy
OC_FLAGS = --output-target=verilog --only-section=.text


default: demo.txt

clean:
	rm *.out *.txt

demo.txt: demo.out
	$(OC) $(OC_FLAGS) $< $@

demo.out: demo.S
	$(AS) $(AS_FLAGS) $< -o $@
	