import math
import os
from random import randint, shuffle

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, FallingEdge, with_timeout, ClockCycles

async def write_ram(ram, address, data):
    ram.WADDR.value = address
    ram.WDATA.value = data
    ram.WE.value = 1
    await RisingEdge(ram.WCLK)
    await FallingEdge(ram.WCLK)
    ram.WE.value = 0


async def read_ram(ram, address):
    ram.RADDR.value = address
    ram.RE.value = 1
    await RisingEdge(ram.RCLK)
    await FallingEdge(ram.RCLK)
    ram.RE.value = 0
    return ram.RDATA.value
        

def shuffle_range(len):
    r = list(range(len))
    shuffle(r)
    return r

@cocotb.test()
async def test_bram(dut):
    wclk   = Clock(dut.WCLK, int(1e12/24e6), units='ps')
    wclk_gen = cocotb.fork(wclk.start())
    rclk   = Clock(dut.RCLK, int(1e12/24e6), units='ps')
    rclk_gen = cocotb.fork(rclk.start())

    dut.RCLKE.value = 1
    dut.WCLKE.value = 1
    
    dut.RE.value = 0
    dut.WE.value = 0

    await Timer(3, units='ns')
    await write_ram(dut,0,0)

    assert 0 == await read_ram(dut, 0)

    await write_ram(dut,1,1)
    await write_ram(dut,2,2)
    assert (1,2) == (await read_ram(dut, 1), await read_ram(dut, 2))

    values = [
        (addr,randint(0,65535)) for addr in shuffle_range(256)
    ]

    for addr, value in values:
        await Timer(randint(1, 40000), units='ps')
        await write_ram(dut,addr,value)

    for addr, value in values:
        await Timer(randint(1, 40000), units='ps')
        value == await read_ram(dut, addr)


    

    