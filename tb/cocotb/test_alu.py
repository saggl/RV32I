import cocotb
from cocotb.triggers import Timer


# ALU operation encoding: {funct7[5], funct3}
ALU_ADD  = 0b0000
ALU_SUB  = 0b1000
ALU_SLL  = 0b0001
ALU_SLT  = 0b0010
ALU_SLTU = 0b0011
ALU_XOR  = 0b0100
ALU_SRL  = 0b0101
ALU_SRA  = 0b1101
ALU_OR   = 0b0110
ALU_AND  = 0b0111


def mask32(val):
    return val & 0xFFFFFFFF


async def alu_check(dut, aluop, a, b, expected):
    dut.aluop.value = aluop
    dut.a.value = a
    dut.b.value = b
    await Timer(1, units="ns")
    result = dut.result.value.integer
    assert result == expected, (
        f"ALU op={aluop:#06b} a={a:#010x} b={b:#010x}: "
        f"got {result:#010x}, expected {expected:#010x}"
    )


@cocotb.test()
async def test_add(dut):
    await alu_check(dut, ALU_ADD, 0x00000000, 0x00000000, 0x00000000)
    await alu_check(dut, ALU_ADD, 0x00000001, 0x00000000, 0x00000001)
    await alu_check(dut, ALU_ADD, 0x00000001, 0xFFFFFFFF, 0x00000000)
    await alu_check(dut, ALU_ADD, 0x7FFFFFFF, 0x00000001, 0x80000000)


@cocotb.test()
async def test_sub(dut):
    await alu_check(dut, ALU_SUB, 0x00000000, 0x00000001, 0xFFFFFFFF)
    await alu_check(dut, ALU_SUB, 0xFFFFFFFF, 0x00000001, 0xFFFFFFFE)
    await alu_check(dut, ALU_SUB, 0x00000001, 0x00000001, 0x00000000)


@cocotb.test()
async def test_sll(dut):
    await alu_check(dut, ALU_SLL, 0x00000001, 0x00000001, 0x00000002)
    await alu_check(dut, ALU_SLL, 0xFFFFFFFF, 0x0000001F, 0x80000000)
    await alu_check(dut, ALU_SLL, 0x00000001, 0x00000000, 0x00000001)


@cocotb.test()
async def test_slt(dut):
    await alu_check(dut, ALU_SLT, 0x0000000A, 0x00000005, 0x00000000)
    await alu_check(dut, ALU_SLT, 0x00000005, 0x0000000A, 0x00000001)
    await alu_check(dut, ALU_SLT, 0x80000000, 0x000007FF, 0x00000001)
    await alu_check(dut, ALU_SLT, 0xFFFFFFFF, 0x00000005, 0x00000001)
    await alu_check(dut, ALU_SLT, 0x00000005, 0xFFFFFFFF, 0x00000000)
    await alu_check(dut, ALU_SLT, 0xFFFFFFFF, 0xFFFFFFFE, 0x00000000)
    await alu_check(dut, ALU_SLT, 0xFFFFFFFE, 0xFFFFFFFF, 0x00000001)


@cocotb.test()
async def test_sltu(dut):
    await alu_check(dut, ALU_SLTU, 0x0000000A, 0x00000005, 0x00000000)
    await alu_check(dut, ALU_SLTU, 0x00000005, 0x0000000A, 0x00000001)
    await alu_check(dut, ALU_SLTU, 0xFFFFFFFF, 0x00000005, 0x00000000)
    await alu_check(dut, ALU_SLTU, 0x00000005, 0xFFFFFFFF, 0x00000001)
    await alu_check(dut, ALU_SLTU, 0xFFFFFFFF, 0xFFFFFFFE, 0x00000000)
    await alu_check(dut, ALU_SLTU, 0xFFFFFFFE, 0xFFFFFFFF, 0x00000001)


@cocotb.test()
async def test_xor(dut):
    await alu_check(dut, ALU_XOR, 0x01234567, 0x89ABCDEF, 0x88888888)


@cocotb.test()
async def test_srl(dut):
    await alu_check(dut, ALU_SRL, 0x00000001, 0x00000001, 0x00000000)
    await alu_check(dut, ALU_SRL, 0xFFFFFFFF, 0x00000001, 0x7FFFFFFF)


@cocotb.test()
async def test_sra(dut):
    await alu_check(dut, ALU_SRA, 0x00000001, 0x00000001, 0x00000000)
    await alu_check(dut, ALU_SRA, 0xFFFFFFFF, 0x00000001, 0xFFFFFFFF)
    await alu_check(dut, ALU_SRA, 0x80000001, 0x00000001, 0xC0000000)


@cocotb.test()
async def test_or(dut):
    await alu_check(dut, ALU_OR, 0x01234567, 0x89ABCDEF, 0x89ABCDEF)


@cocotb.test()
async def test_and(dut):
    await alu_check(dut, ALU_AND, 0x01234567, 0x89ABCDEF, 0x01234567)
