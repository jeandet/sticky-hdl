import math
import os
from random import getrandbits

import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.regression import TestFactory
from cocotb.triggers import RisingEdge, ReadOnly, Timer, FallingEdge, with_timeout

async def write_fifo(fifo, data):
    if fifo.full == 1:
        raise TestFailure("FIFO is full")
    fifo.data_in.value = data
    fifo.wr.value = 1
    await RisingEdge(fifo.clk)
    await FallingEdge(fifo.clk)
    fifo.wr.value = 0 


async def read_fifo(fifo):
    if fifo.empty == 1:
        raise TestFailure("FIFO is empty")
    data = fifo.data_out.value
    fifo.rd.value = 1
    await RisingEdge(fifo.clk)
    await FallingEdge(fifo.clk)
    fifo.rd.value = 0 
    return data


async def continuous_write(fifo, data):
    while fifo.empty != 1:
        fifo.rd.value = 1
        await RisingEdge(fifo.clk)
    fifo.rd.value = 0
    fifo.wr.value = 1
    for v in data:
        assert fifo.full != 1
        fifo.data_in.value = v
        await RisingEdge(fifo.clk)
        await FallingEdge(fifo.clk)
    fifo.wr.value = 0 

async def continuous_read(fifo):
    while fifo.full != 1:
        fifo.wr.value = 1
        await RisingEdge(fifo.clk)
    data = []
    fifo.wr.value = 0
    data.append(fifo.data_out.value)
    fifo.rd.value = 1
    while fifo.empty.value != 1:
        await RisingEdge(fifo.clk)
        await FallingEdge(fifo.clk)
        if fifo.empty.value != 1:
            data.append(fifo.data_out.value)
    fifo.rd.value = 0 
    return data



async def write_test(fifo):
    while fifo.empty != 1:
        fifo.rd.value = 1
        await RisingEdge(fifo.clk)
    for i in range(300):
        await write_fifo(fifo,i)
        await RisingEdge(fifo.clk)
        if fifo.empty.value != 0:
            await with_timeout(FallingEdge(fifo.empty),200,'ns')
        assert i == await read_fifo(fifo)
    
        

@cocotb.test()
async def test_fifo(dut):
    clk   = Clock(dut.clk, 10, units='ns')
    clk_gen = cocotb.fork(clk.start())
    dut.reset.value = 0
    dut.rd.value = 0
    dut.wr.value = 0
    await Timer(100, units='ns')
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    await write_test(dut)
    data = list(range(16))
    await continuous_write(dut, data)
    data = await continuous_read(dut)
    


    

    