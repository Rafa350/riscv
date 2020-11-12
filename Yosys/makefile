DOT = dot
DOT_FLAGS = -Tpdf -O

YS = yosys
YS_FLAGS =

.SUFFIXES: .dot .pdf .ys
.PHONY: all clean


all: graphic.pdf

clean:
	rm -rf *.pdf *.dot
	
graphic.dot: script.ys
	$(YS) $(YS_FLAGS) -s script.ys 

.dot.pdf:
	$(DOT) $(DOT_FLAGS) $*.dot -o $*.pdf