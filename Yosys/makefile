DOT = dot
DOT_FLAGS = -Tpdf -O

YS = yosys
YS_FLAGS =

SV = sv2v
SV_FLAGS = -I ..\HDL -I ..\HDL\Base

.SUFFIXES: .dot .pdf .ys
.PHONY: all clean

SV_FILES = \
	verilator_top.sv \
	Register.sv \
	Mux2To1.sv \
	Mux4To1.sv \
	Mux8To1.sv 

V_FILES = $(SV_FILES:.sv=.v)

vpath %.sv ../Verilator ../HDL ../HDL/Base
vpath %.v  Build

all: $(V_FILES) script2.ys

script2.ys:
	cp &&|
	# Generado con MAKE, no modificar	
	| $@

clean:
	@rm -rf *.v *.pdf *.dot Build/*
	
graphic.dot: script.ys
	$(YS) $(YS_FLAGS) -s script.ys 

.dot.pdf:
	$(DOT) $(DOT_FLAGS) $*.dot -o $*.pdf
	
# Converteix arxius *.sv a *v
%.v: %.sv 
	$(SV) $(SV_FLAGS) $< > Build/$(@F)