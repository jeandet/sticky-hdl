TOPLEVEL_LANG ?= vhdl
SIM ?= ghdl

PWD=$(shell pwd)

VHDL_SOURCES = $(PWD)/../../HDL/ads92x4.vhdl $(PWD)/../../HDL/clk_gen.vhdl $(PWD)/../../HDL/pulse_gen.vhdl $(PWD)/../../HDL/rcc.vhdl $(PWD)/../../HDL/SB_HFOSC_SIM.vhd $(PWD)/../../HDL/UART.vhdl $(PWD)/../../HDL/adc_uart.vhdl $(PWD)/../../top/adc_uart/top.vhdl

ifeq ($(SIM),ghdl)
	EXTRA_ARGS += --std=08
	SIM_ARGS += --wave=wave.ghw
	#SIM_ARGS += --vcd=wave.vcd
else ifneq ($(filter $(SIM),questa modelsim riviera activehdl),)
	COMPILE_ARGS += -2008
endif

TOPLEVEL    := top
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