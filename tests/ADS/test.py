import math
import os
from random import getrandbits

import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.monitors import BusMonitor
from cocotb.regression import TestFactory
from cocotb.triggers import RisingEdge, ReadOnly, Timer, FallingEdge


async def gen_data(cs_sig, sclk_sig, serial_data, phi=0., f=lambda t: int(math.cos(t)*32765)):
    serial_data <= 0
    t = phi
    while True:
        data = f(t)
        for i in range(16):
            await RisingEdge(sclk_sig)
            serial_data <= (data & 0x8000)>>15
            data = data<<1
        t+=0.1

async def ready_strobe_gen(ready_sig, conv_sig):
    ready_sig <= 0
    while True:
        await RisingEdge(conv_sig)
        await Timer(315, units='ns')
        ready_sig <= 1
        await Timer(30, units='ns')
        ready_sig <= 0

@cocotb.test()
async def test_adc_if(dut):
    clk   = Clock(dut.clk, 20.8, units='ns')
    sampling_clock = Clock(dut.smp_clk, 500., units='ns')
    ready_strobe = cocotb.fork(ready_strobe_gen(dut.ready_strobe, dut.conv))
    serial_data_a = cocotb.fork(gen_data(dut.cs, dut.sclk, dut.miso_a))
    serial_data_b = cocotb.fork(gen_data(dut.cs, dut.sclk, dut.miso_b, 0., lambda t: int(t*10)))
    dut.reset <= 0
    clk_gen = cocotb.fork(clk.start())
    smp_clk_gen = cocotb.fork(sampling_clock.start())
    await Timer(100, units='ns')
    dut.reset <= 1
    await Timer(100, units='us')

    