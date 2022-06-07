# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0
# Simple tests for an adder module
import random

import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock



@cocotb.test()
async def clock_basic_test(dut):
        
 
    
 Signal_ledoutput = 0
 expected = 0
 for _ in range(6000000):
        
        if  dut.cpt.value == 6000000: 
               LED = Signal_ledoutput
               expected = not expected
               assert expected == LED
        else :
              dut.cpt.value = dut.cpt.value +1
