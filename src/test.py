import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Edge, RisingEdge

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
    
    # Use Gate level test or not
    gate_level_test = False
    
    # Check if is gate level test
    try:
        dut.tt_um_fsm.current_state.value
        dut._log.info("Pre-Sythnesis test")
    except:
        dut._log.info("Gate level test")
        gate_level_test = True
    
    # Check state
    if (not gate_level_test):
        dut._log.info("Checking finite state machine")
        for i in range(20):
            await RisingEdge(dut.clk) 
            state = dut.tt_um_fsm.current_state.value
            dut._log.info("State: %d", dut.tt_um_fsm.current_state.value)
            await RisingEdge(dut.clk)
            output = dut.salida.value
            dut._log.info("Value: %d", dut.salida.value)
            if state == 0:
                assert output == 10
            elif state == 1:
                assert output == 5
            elif state == 2:
                assert output == 15
            else:
                assert output == 3
    else:
        dut._log.info("Gate level test")
        for i in range(20):
            await RisingEdge(dut.clk) 
            await RisingEdge(dut.clk)
            output = dut.salida.value
            dut._log.info(f"Value: {dut.salida.value}")

    
    