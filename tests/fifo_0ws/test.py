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
    fifo.data_in <= data
    fifo.wr <= 1
    await RisingEdge(fifo.clk)
    await FallingEdge(fifo.clk)
    fifo.wr <= 0 


async def read_fifo(fifo):
    if fifo.empty == 1:
        raise TestFailure("FIFO is empty")
    fifo.rd <= 1
    await RisingEdge(fifo.clk)
    await FallingEdge(fifo.clk)
    fifo.rd <= 0 
    await RisingEdge(fifo.clk)
    await FallingEdge(fifo.clk)
    await RisingEdge(fifo.clk)
    await FallingEdge(fifo.clk)
    return fifo.data_out.value


async def continuous_write(fifo):
    while fifo.empty != 1:
        fifo.rd <= 1
        await RisingEdge(fifo.clk)
    fifo.rd <= 0
    data = 0
    fifo.wr <= 1
    while fifo.full != 1:
        fifo.data_in <= data
        data += 1
        await RisingEdge(fifo.clk)
        await FallingEdge(fifo.clk)
    fifo.wr <= 0 

async def continuous_read(fifo):
    while fifo.full != 1:
        fifo.wr <= 1
        await RisingEdge(fifo.clk)
    fifo.wr <= 0
    fifo.rd <= 1
    while fifo.empty != 1:
        await RisingEdge(fifo.clk)
        await FallingEdge(fifo.clk)
    fifo.rd <= 0 



async def write_test(fifo):
    while fifo.empty != 1:
        fifo.rd <= 1
        await RisingEdge(fifo.clk)
    for i in range(300):
        await write_fifo(fifo,i)
        await RisingEdge(fifo.clk)
        if fifo.empty.value != 0:
            await with_timeout(FallingEdge(fifo.empty),200,'ns')
        await RisingEdge(fifo.clk)
        assert i == await read_fifo(fifo)
    
        

@cocotb.test()
async def test_fifo(dut):
    clk   = Clock(dut.clk, 10, units='ns')
    clk_gen = cocotb.fork(clk.start())
    dut.reset <= 0
    dut.rd <= 0
    dut.wr <= 0
    await Timer(100, units='ns')
    dut.reset <= 1
    await RisingEdge(dut.clk)
    await write_test(dut)
    await continuous_write(dut)
    await continuous_read(dut)
    


    

    