# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0
# Simple tests for an adder module
import random

import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock



@cocotb.test()
async def counter_basic_test(dut):
    dut.rst.value = 0
    dut.send.value = 0
    await Timer(2, units="ns")
    dut.rst.value = 1
    c = Clock(dut.serial_clk, 1, 'us')
    await cocotb.start(c.start())
    await RisingEdge(dut.serial_clk)
    for i in range(10):
       dut.data.value = i
       dut.send.value = 1
       await FallingEdge(dut.ready)
       dut.send.value = 0
       await RisingEdge(dut.ready)
       
