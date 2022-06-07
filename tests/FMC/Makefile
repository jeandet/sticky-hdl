TOPLEVEL_LANG ?= vhdl
SIM ?= ghdl

PWD=$(shell pwd)

VHDL_SOURCES = $(PWD)/../../top/test_FMC/top.vhdl $(PWD)/../../HDL/fifo.vhd $(PWD)/../../HDL/bram_256x16.vhd\
               $(PWD)/../../Sim_Models/SB_RAM40_4K.vhd $(PWD)/../../HDL/rcc.vhdl $(PWD)/../../HDL/nor_interface.vhd\
			   $(PWD)/../../HDL/clk_gen.vhdl $(PWD)/../../Sim_Models/SB_HFOSC.vhd $(PWD)/../../HDL/io_pin.vhd

ifeq ($(SIM),ghdl)
	EXTRA_ARGS += --std=08
	SIM_ARGS += --wave=wave.ghw
else ifneq ($(filter $(SIM),questa modelsim riviera activehdl),)
	COMPILE_ARGS += -2008
endif

TOPLEVEL    := top
MODULE      := test

include $(shell ~/.local/bin/cocotb-config --makefiles)/Makefile.sim


# Profiling

DOT_BINARY ?= dot

test_profile.pstat: sim

callgraph.svg: test_profile.pstat
	$(shell ~/.local/bin/cocotb-config --python-bin) -m gprof2dot -f pstats ./$< | $(DOT_BINARY) -Tsvg -o $@

.PHONY: profile
profile:
	COCOTB_ENABLE_PROFILING=1 $(MAKE) callgraph.svg