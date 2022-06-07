TOPLEVEL_LANG ?= vhdl
SIM ?= ghdl

PWD=$(shell pwd)

VHDL_SOURCES = $(PWD)/../../HDL/ads92x4.vhd $(PWD)/../../HDL/clk_gen.vhd $(PWD)/../../HDL/pulse_gen.vhd

ifeq ($(SIM),ghdl)
	EXTRA_ARGS += --std=08
	SIM_ARGS += --wave=wave.ghw
else ifneq ($(filter $(SIM),questa modelsim riviera activehdl),)
	COMPILE_ARGS += -2008
endif

TOPLEVEL    := ads92x4
MODULE      := test

include $(shell cocotb-config --makefiles)/Makefile.sim


# Profiling

DOT_BINARY ?= dot

test_profile.pstat: sim

callgraph.svg: test_profile.pstat
	$(shell cocotb-config --python-bin) -m gprof2dot -f pstats ./$< | $(DOT_BINARY) -Tsvg -o $@

.PHONY: profile
profile:
	COCOTB_ENABLE_PROFILING=1 $(MAKE) callgraph.svg