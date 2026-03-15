import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


@cocotb.test()
async def test_x0_always_zero(dut):
    """Register x0 should always read as zero, even after write."""
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Try to write to x0
    dut.a_rd.value = 0
    dut.rd.value = 0xDEADBEEF
    dut.we.value = 1
    dut.a_rs1.value = 0
    dut.a_rs2.value = 0
    await RisingEdge(dut.clk)

    dut.we.value = 0
    await RisingEdge(dut.clk)

    assert dut.rs1.value.integer == 0, f"x0 via rs1 should be 0, got {dut.rs1.value.integer:#x}"
    assert dut.rs2.value.integer == 0, f"x0 via rs2 should be 0, got {dut.rs2.value.integer:#x}"


@cocotb.test()
async def test_write_read(dut):
    """Write to a register and read it back via both ports."""
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Write 0x00000001 to register 1
    dut.a_rd.value = 1
    dut.rd.value = 0x00000001
    dut.we.value = 1
    dut.a_rs1.value = 0
    dut.a_rs2.value = 0
    await RisingEdge(dut.clk)

    # Read register 1 via both ports
    dut.we.value = 0
    dut.a_rs1.value = 1
    dut.a_rs2.value = 1
    await RisingEdge(dut.clk)

    assert dut.rs1.value.integer == 1, f"Expected 1, got {dut.rs1.value.integer:#x}"
    assert dut.rs2.value.integer == 1, f"Expected 1, got {dut.rs2.value.integer:#x}"


@cocotb.test()
async def test_write_all_ones(dut):
    """Write 0xFFFFFFFF to register 31 and read it back."""
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Write 0xFFFFFFFF to register 31
    dut.a_rd.value = 31
    dut.rd.value = 0xFFFFFFFF
    dut.we.value = 1
    dut.a_rs1.value = 0
    dut.a_rs2.value = 0
    await RisingEdge(dut.clk)

    # Read register 31 via both ports
    dut.we.value = 0
    dut.a_rs1.value = 31
    dut.a_rs2.value = 31
    await RisingEdge(dut.clk)

    assert dut.rs1.value.integer == 0xFFFFFFFF, f"Expected 0xFFFFFFFF, got {dut.rs1.value.integer:#x}"
    assert dut.rs2.value.integer == 0xFFFFFFFF, f"Expected 0xFFFFFFFF, got {dut.rs2.value.integer:#x}"


@cocotb.test()
async def test_dual_port_read(dut):
    """Read two different registers simultaneously."""
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Write to reg 1
    dut.a_rd.value = 1
    dut.rd.value = 0x00000001
    dut.we.value = 1
    dut.a_rs1.value = 0
    dut.a_rs2.value = 0
    await RisingEdge(dut.clk)

    # Write to reg 31
    dut.a_rd.value = 31
    dut.rd.value = 0xFFFFFFFF
    dut.we.value = 1
    await RisingEdge(dut.clk)

    # Read reg 1 on rs1, reg 31 on rs2
    dut.we.value = 0
    dut.a_rs1.value = 1
    dut.a_rs2.value = 31
    await RisingEdge(dut.clk)

    assert dut.rs1.value.integer == 0x00000001, f"rs1: expected 0x1, got {dut.rs1.value.integer:#x}"
    assert dut.rs2.value.integer == 0xFFFFFFFF, f"rs2: expected 0xFFFFFFFF, got {dut.rs2.value.integer:#x}"


@cocotb.test()
async def test_we_disabled(dut):
    """Register should not be written when we=0."""
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Write to reg 2
    dut.a_rd.value = 2
    dut.rd.value = 0x12345678
    dut.we.value = 1
    dut.a_rs1.value = 0
    dut.a_rs2.value = 0
    await RisingEdge(dut.clk)

    # Attempt write with we=0
    dut.a_rd.value = 2
    dut.rd.value = 0xDEADBEEF
    dut.we.value = 0
    await RisingEdge(dut.clk)

    # Should still have old value
    dut.a_rs1.value = 2
    await RisingEdge(dut.clk)

    assert dut.rs1.value.integer == 0x12345678, f"Expected 0x12345678, got {dut.rs1.value.integer:#x}"
