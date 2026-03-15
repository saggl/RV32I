import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


@cocotb.test()
async def test_nop_sequence(dut):
    """Basic test: reset and execute NOP (ADDI x0, x0, 0) instructions."""
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    # Apply reset
    dut.reset.value = 1
    dut.irq.value = 0
    dut.inst_rdata.value = 0x00000013  # NOP = ADDI x0, x0, 0
    dut.data_rdata.value = 0

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # Release reset
    dut.reset.value = 0
    await RisingEdge(dut.clk)

    # PC should start at 0 after reset
    # After first cycle, it should advance to 4
    await Timer(20, units="ns")
    assert dut.inst_addr.value.integer == 4, (
        f"PC after first NOP should be 4, got {dut.inst_addr.value.integer:#x}"
    )


@cocotb.test()
async def test_pc_increments(dut):
    """Verify PC increments by 4 each cycle with NOP instructions."""
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    dut.reset.value = 1
    dut.irq.value = 0
    dut.inst_rdata.value = 0x00000013  # NOP
    dut.data_rdata.value = 0

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.reset.value = 0

    for i in range(5):
        await RisingEdge(dut.clk)
        await Timer(20, units="ns")
        expected_pc = (i + 1) * 4
        actual_pc = dut.inst_addr.value.integer
        assert actual_pc == expected_pc, (
            f"Cycle {i+1}: PC={actual_pc:#x}, expected {expected_pc:#x}"
        )


@cocotb.test()
async def test_addi(dut):
    """Test ADDI x1, x0, 42 — should write 42 to register x1."""
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    dut.reset.value = 1
    dut.irq.value = 0
    dut.data_rdata.value = 0

    # ADDI x1, x0, 42 = imm[11:0]=42, rs1=x0, funct3=000, rd=x1, opcode=0010011
    # 000000101010_00000_000_00001_0010011
    addi_inst = 0x02A00093

    dut.inst_rdata.value = 0x00000013  # NOP during reset
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.reset.value = 0

    # Feed the ADDI instruction
    dut.inst_rdata.value = addi_inst
    await RisingEdge(dut.clk)

    # Feed NOP to let the write complete
    dut.inst_rdata.value = 0x00000013
    await RisingEdge(dut.clk)
    await Timer(20, units="ns")

    # Verify PC advanced
    assert dut.inst_addr.value.integer == 8, (
        f"PC should be 8 after 2 instructions, got {dut.inst_addr.value.integer:#x}"
    )


@cocotb.test()
async def test_lui(dut):
    """Test LUI x1, 0xDEADB — should load 0xDEADB000 into x1."""
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    dut.reset.value = 1
    dut.irq.value = 0
    dut.data_rdata.value = 0

    # LUI x1, 0xDEADB = imm[31:12]=0xDEADB, rd=x1, opcode=0110111
    lui_inst = 0xDEADB0B7

    dut.inst_rdata.value = 0x00000013  # NOP during reset
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.reset.value = 0

    dut.inst_rdata.value = lui_inst
    await RisingEdge(dut.clk)

    dut.inst_rdata.value = 0x00000013  # NOP
    await RisingEdge(dut.clk)
    await Timer(20, units="ns")

    assert dut.inst_addr.value.integer == 8


@cocotb.test()
async def test_trap_on_ecall(dut):
    """ECALL instruction should raise the trap signal."""
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    dut.reset.value = 1
    dut.irq.value = 0
    dut.data_rdata.value = 0

    # ECALL = 00000000000000000000000001110011
    ecall_inst = 0x00000073

    dut.inst_rdata.value = 0x00000013
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.reset.value = 0

    dut.inst_rdata.value = ecall_inst
    await RisingEdge(dut.clk)
    await Timer(20, units="ns")

    assert dut.trap.value.integer == 1, "ECALL should assert trap"
