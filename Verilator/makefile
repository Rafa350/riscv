default: show_config test_default


# This must point to the root of the VERILATOR kit
ifeq ($(OS),Windows_NT)
OSNAME         := WINDOWS
VERILATOR_ROOT := /home/rafael/projectes/Projectes/verilator
VERILATOR_BIN  := $(VERILATOR_ROOT)/bin
VERILATOR_INC  := $(VERILATOR_ROOT)/include
else
OSNAME         := LINUX
VERILATOR_ROOT := /home/rafael/Projectes/verilator
VERILATOR_BIN  := $(VERILATOR_ROOT)/bin
VERILATOR_INC  := $(VERILATOR_ROOT)/include
endif


export VERILATOR_ROOT


# Pick up PERL and other variable settings
include $(VERILATOR_INC)/verilated.mk

DEBUG_QUIET = --debug --debugi 0 --gdbbt --no-dump-tree
DEBUG_ON = --debug --trace-dups --gdbbt
#DEBUG = $(DEBUG_ON)
VALGRIND_ON = $(DEBUG_ON) --gdb "valgrind -v --leak-check=yes"

######################################################################
test_default:   prep     compile run
test_debug:     prep_dbg compile run
test_valgrind:  prep_vg  compile run

VERILATOR       = $(VERILATOR_BIN)/verilator
VERILATOR_FLAGS = --cc verilator_top.sv --top-module top -y ../HDL -y ../HDL/Base -y ../HDL/Core -Wall
VERILATOR_FLAGS += --trace-fst

#show_config: Is the very first time we've executed Verilator after building
#so we make sure to run with --gdbbt, so if it dumps we'll get a trace.
show_config:
	@echo ------------------------------------------------------------
	@echo OS......: $(OSNAME)
	@echo ROOT....: $(VERILATOR_ROOT)
	@echo BIN.....: $(VERILATOR_BIN)
	@echo INC.....: $(VERILATOR_INC)
	@echo ------------------------------------------------------------
	$(PERL) $(VERILATOR) $(DEBUG_QUIET) -V

#prep: Is the very first time we're running a Verilation
#so we make sure to run with --gdbbt, so if it dumps we'll get a trace.
prep:
	$(PERL) $(VERILATOR) $(DEBUG_QUIET) $(VERILATOR_FLAGS)
	
prep_dbg:
	$(PERL) $(VERILATOR) $(DEBUG_ON)    $(VERILATOR_FLAGS)
	
prep_vg:
	$(PERL) $(VERILATOR) $(VALGRIND_ON) $(VERILATOR_FLAGS)

compile:
	cd obj_dir ; $(MAKE) -j 3 -f ../Makefile_obj

run:
	obj_dir/simx

######################################################################

obj_dir:
	mkdir $@

######################################################################

maintainer-copy::
clean mostlyclean distclean maintainer-clean::
	-rm -rf obj_dir *.log *.dmp *.vpd core
