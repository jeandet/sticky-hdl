import math
import os
from random import getrandbits, randint

import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.regression import TestFactory
from cocotb.triggers import RisingEdge, ReadOnly, Timer, FallingEdge

async def read_FMC(dut):
    if dut.has_data == 0:
        await RisingEdge(dut.has_data)
    for _ in range(16):
        dut.rd <= 0
        await Timer(104, units='ns')
        dut.rd <= 1
        await Timer(int(122), units='ns')
        await Timer(randint(1,1000), units='ps')


        

@cocotb.test()
async def test_fmc(dut):
    dut.reset <= 0
    await Timer(100, units='ns')
    dut.reset <= 1
    dut.rd <= 1
    dut.cs <= 0
    dut.wr <= 1
    dut.rs <= 1
    await Timer(100, units='ns')
    for _ in range(100):
        await read_FMC(dut)
        await Timer(randint(1,100000), units='ns')
    


    

    