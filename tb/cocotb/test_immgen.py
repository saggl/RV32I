import cocotb
from cocotb.triggers import Timer

# Immediate format select encoding
IMM_I = 0b000
IMM_S = 0b001
IMM_B = 0b010
IMM_U = 0b011
IMM_J = 0b100


def make_inst_bits(inst31_7):
    """Convert a 25-bit integer to the inst[31:7] field."""
    return inst31_7 & 0x1FFFFFF


async def imm_check(dut, imm_sel, inst_31_7, expected, label=""):
    dut.imm_sel.value = imm_sel
    dut.inst.value = inst_31_7
    await Timer(1, units="ns")
    result = dut.imm.value.integer
    assert result == expected, (
        f"{label}: imm_sel={imm_sel:#05b} inst[31:7]={inst_31_7:#027b}: "
        f"got {result:#010x}, expected {expected:#010x}"
    )


@cocotb.test()
async def test_i_type(dut):
    """I-type immediate: sign-extended inst[31:20]."""
    # All zeros
    await imm_check(dut, IMM_I, 0b0000000000000000000000000, 0x00000000, "I zero")
    # Bit 20 (inst[20]) set -> imm[0]=1
    await imm_check(dut, IMM_I, 0b0000000000010000000000000, 0x00000001, "I imm=1")
    # Sign bit (inst[31]) set
    await imm_check(dut, IMM_I, 0b1000000000010000000000000, 0xFFFFF801, "I negative")
    # All ones
    await imm_check(dut, IMM_I, 0b1111111111110000000000000, 0xFFFFFFFF, "I all ones")


@cocotb.test()
async def test_s_type(dut):
    """S-type immediate: sign-extended {inst[31:25], inst[11:7]}."""
    await imm_check(dut, IMM_S, 0b0000000000000000000000000, 0x00000000, "S zero")
    # inst[7] set -> imm[0]=1, rest of [31:25] zero
    await imm_check(dut, IMM_S, 0b0000000000000000000000001, 0x00000001, "S imm=1")
    # Sign bit set, inst[7]=1
    await imm_check(dut, IMM_S, 0b1000000000000000000000001, 0xFFFFF801, "S negative")
    # All ones
    await imm_check(dut, IMM_S, 0b1111111000000000000011111, 0xFFFFFFFF, "S all ones")


@cocotb.test()
async def test_b_type(dut):
    """B-type immediate: sign-extended {inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}."""
    await imm_check(dut, IMM_B, 0b0000000000000000000000000, 0x00000000, "B zero")
    # inst[8]=1 -> imm[1]=1, imm[0]=0
    await imm_check(dut, IMM_B, 0b0000000000000000000000010, 0x00000002, "B imm=2")
    # Sign bit set
    await imm_check(dut, IMM_B, 0b1000000000000000000000010, 0xFFFFF002, "B negative")
    # All relevant bits set
    await imm_check(dut, IMM_B, 0b1111111000000000000011111, 0xFFFFFFFE, "B all ones")


@cocotb.test()
async def test_u_type(dut):
    """U-type immediate: {inst[31:12], 12'b0}."""
    await imm_check(dut, IMM_U, 0b0000000000000000000000000, 0x00000000, "U zero")
    # inst[12] set -> imm[12]=1
    await imm_check(dut, IMM_U, 0b0000000000000000001000000, 0x00001000, "U one page")
    # Sign bit set
    await imm_check(dut, IMM_U, 0b1000000000000000001000000, 0x80001000, "U high bit")
    # All upper bits set
    await imm_check(dut, IMM_U, 0b1111111111111111111000000, 0xFFFFF000, "U all ones")


@cocotb.test()
async def test_j_type(dut):
    """J-type immediate: sign-extended {inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}."""
    await imm_check(dut, IMM_J, 0b0000000000000000000000000, 0x00000000, "J zero")
    # Sign bit set, inst[20]=1 -> imm[11]=1
    await imm_check(dut, IMM_J, 0b1000000000100000000000000, 0xFFF00002, "J negative")
    # All relevant bits set
    await imm_check(dut, IMM_J, 0b1111111111111111111000000, 0xFFFFFFFE, "J all ones")
