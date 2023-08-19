import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_fsm(dut):
    dut._log.info("Running test!")
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut._log.info("Resetting DUT")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    
    # Enable
    dut._log.info("Enabling DUT")
    dut.ena.value = 1
    await ClockCycles(dut.clk, 10)
    
    # Check state
    dut._log.info("Checking finite state machine")
    for i in range(15):
        await ClockCycles(dut.clk, 1)
        if dut.tt_um_fsm.state_reg.value == 1:
            assert int(dut.salida.value) == 10
        elif dut.tt_um_fsm.state_reg.value == 2:
            assert int(dut.salida.value) == 5
        elif dut.tt_um_fsm.state_reg.value == 3:
            assert int(dut.salida.value) == 15
        elif dut.tt_um_fsm.state_reg.value == 0:
            assert int(dut.salida.value) == 0


    
    