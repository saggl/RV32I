import cocotb
from cocotb.triggers import Timer


async def bc_check(dut, br_un, a, b, exp_eq, exp_lt):
    dut.br_un.value = br_un
    dut.a.value = a
    dut.b.value = b
    await Timer(1, units="ns")
    eq = dut.br_eq.value.integer
    lt = dut.br_lt.value.integer
    assert eq == exp_eq and lt == exp_lt, (
        f"br_un={br_un} a={a:#010x} b={b:#010x}: "
        f"got eq={eq} lt={lt}, expected eq={exp_eq} lt={exp_lt}"
    )


@cocotb.test()
async def test_equal_signed(dut):
    await bc_check(dut, 0, 0x00000000, 0x00000000, 1, 0)
    await bc_check(dut, 0, 0xFFFFFFFF, 0xFFFFFFFF, 1, 0)


@cocotb.test()
async def test_equal_unsigned(dut):
    await bc_check(dut, 1, 0x00000000, 0x00000000, 1, 0)
    await bc_check(dut, 1, 0xFFFFFFFF, 0xFFFFFFFF, 1, 0)


@cocotb.test()
async def test_signed_comparison(dut):
    await bc_check(dut, 0, 0x0000000A, 0x00000005, 0, 0)  # 10 > 5
    await bc_check(dut, 0, 0x00000005, 0x0000000A, 0, 1)  # 5 < 10
    await bc_check(dut, 0, 0xFFFFFFFF, 0x00000005, 0, 1)  # -1 < 5
    await bc_check(dut, 0, 0x00000005, 0xFFFFFFFF, 0, 0)  # 5 > -1
    await bc_check(dut, 0, 0xFFFFFFFF, 0xFFFFFFFE, 0, 0)  # -1 > -2
    await bc_check(dut, 0, 0xFFFFFFFE, 0xFFFFFFFF, 0, 1)  # -2 < -1
    await bc_check(dut, 0, 0x80000000, 0x000007FF, 0, 1)  # -2^31 < 2047


@cocotb.test()
async def test_unsigned_comparison(dut):
    await bc_check(dut, 1, 0x0000000A, 0x00000005, 0, 0)
    await bc_check(dut, 1, 0x00000005, 0x0000000A, 0, 1)
    await bc_check(dut, 1, 0xFFFFFFFF, 0x00000005, 0, 0)  # large unsigned > 5
    await bc_check(dut, 1, 0x00000005, 0xFFFFFFFF, 0, 1)  # 5 < large unsigned
    await bc_check(dut, 1, 0xFFFFFFFF, 0xFFFFFFFE, 0, 0)
    await bc_check(dut, 1, 0xFFFFFFFE, 0xFFFFFFFF, 0, 1)
    await bc_check(dut, 1, 0x80000000, 0x000007FF, 0, 0)  # 2^31 > 2047 unsigned
