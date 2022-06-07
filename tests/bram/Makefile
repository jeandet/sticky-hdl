TOPLEVEL_LANG ?= vhdl
SIM ?= ghdl

PWD=$(shell pwd)

VHDL_SOURCES = $(PWD)/../../HDL/bram_256x16.vhd $(PWD)/../../Sim_Models/SB_RAM40_4K.vhd

ifeq ($(SIM),ghdl)
	EXTRA_ARGS += --std=08
	SIM_ARGS += --wave=wave.ghw
else ifneq ($(filter $(SIM),questa modelsim riviera activehdl),)
	COMPILE_ARGS += -2008
endif

TOPLEVEL    := bram_256x16
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