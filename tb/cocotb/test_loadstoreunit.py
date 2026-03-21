import cocotb
from cocotb.triggers import Timer

# funct3 encoding for loads
LB  = 0b000
LH  = 0b001
LW  = 0b010
LBU = 0b100
LHU = 0b101

# funct3 encoding for stores (bit pattern reuse)
SB = 0b000
SH = 0b001
SW = 0b010

# For stores we set mem_rw=1, and the load funct3 values differ from store by bit[2]
# but since the LSU uses funct3[1:0] for size, we use the same lower bits


async def load_check(dut, funct3, addr, data_rdata, exp_data_r, exp_data_addr, label=""):
    """Check a load operation."""
    dut.funct3.value = funct3
    dut.mem_rw.value = 0
    dut.addr.value = addr
    dut.data_rdata.value = data_rdata
    dut.data_w.value = 0
    await Timer(1, units="ns")

    data_r = dut.data_r.value.integer
    data_addr = dut.data_addr.value.integer
    data_we = dut.data_we.value.integer

    assert data_r == exp_data_r, (
        f"{label}: data_r={data_r:#010x}, expected {exp_data_r:#010x}"
    )
    assert data_addr == exp_data_addr, (
        f"{label}: data_addr={data_addr:#010x}, expected {exp_data_addr:#010x}"
    )
    assert data_we == 0, f"{label}: data_we={data_we:#06b}, expected 0 (load)"


async def store_check(dut, funct3, addr, data_w, exp_data_wdata, exp_data_addr, exp_data_we, label=""):
    """Check a store operation."""
    # Store funct3 values have bit[2]=0, but we need to set the correct size bits
    # For stores: SB=000, SH=001, SW=010 — already match funct3[1:0]
    # We pass the store funct3 directly (000, 001, 010) + mem_rw=1
    store_funct3 = funct3 | 0b000  # lower bits match
    dut.funct3.value = store_funct3
    dut.mem_rw.value = 1
    dut.addr.value = addr
    dut.data_w.value = data_w
    dut.data_rdata.value = 0
    await Timer(1, units="ns")

    data_wdata = dut.data_wdata.value.integer
    data_addr = dut.data_addr.value.integer
    data_we = dut.data_we.value.integer

    assert data_wdata == exp_data_wdata, (
        f"{label}: data_wdata={data_wdata:#010x}, expected {exp_data_wdata:#010x}"
    )
    assert data_addr == exp_data_addr, (
        f"{label}: data_addr={data_addr:#010x}, expected {exp_data_addr:#010x}"
    )
    assert data_we == exp_data_we, (
        f"{label}: data_we={data_we:#06b}, expected {exp_data_we:#06b}"
    )


@cocotb.test()
async def test_lb(dut):
    """LB: load byte with sign extension."""
    await load_check(dut, LB, 0x00000000, 0xAABBCC5D, 0x0000005D, 0x00000000, "LB byte0 pos")
    await load_check(dut, LB, 0x00000000, 0xAABBCCDD, 0xFFFFFFDD, 0x00000000, "LB byte0 neg")
    await load_check(dut, LB, 0x00000001, 0xAABBCCDD, 0xFFFFFFCC, 0x00000000, "LB byte1")
    await load_check(dut, LB, 0x00000002, 0xAABBCCDD, 0xFFFFFFBB, 0x00000000, "LB byte2")
    await load_check(dut, LB, 0x00000003, 0xAABBCCDD, 0xFFFFFFAA, 0x00000000, "LB byte3")
    await load_check(dut, LB, 0x00000004, 0xAABBCCDD, 0xFFFFFFDD, 0x00000004, "LB aligned+4")


@cocotb.test()
async def test_lh(dut):
    """LH: load halfword with sign extension."""
    await load_check(dut, LH, 0x00000000, 0xAABB4CDD, 0x00004CDD, 0x00000000, "LH hw0 pos")
    await load_check(dut, LH, 0x00000000, 0xAABBCCDD, 0xFFFFCCDD, 0x00000000, "LH hw0 neg")
    await load_check(dut, LH, 0x00000002, 0xAABBCCDD, 0xFFFFAABB, 0x00000000, "LH hw1")
    await load_check(dut, LH, 0x00000004, 0xAABBCCDD, 0xFFFFCCDD, 0x00000004, "LH aligned+4")


@cocotb.test()
async def test_lw(dut):
    """LW: load word (no extension)."""
    await load_check(dut, LW, 0x00000000, 0x00000000, 0x00000000, 0x00000000, "LW zero")
    await load_check(dut, LW, 0x00000000, 0xFFFFFFFF, 0xFFFFFFFF, 0x00000000, "LW all ones")
    await load_check(dut, LW, 0x00000004, 0xFFFFFFFF, 0xFFFFFFFF, 0x00000004, "LW aligned+4")


@cocotb.test()
async def test_lbu(dut):
    """LBU: load byte unsigned (zero extension)."""
    await load_check(dut, LBU, 0x00000000, 0xAABBCCDD, 0x000000DD, 0x00000000, "LBU byte0")
    await load_check(dut, LBU, 0x00000001, 0xAABBCCDD, 0x000000CC, 0x00000000, "LBU byte1")
    await load_check(dut, LBU, 0x00000002, 0xAABBCCDD, 0x000000BB, 0x00000000, "LBU byte2")
    await load_check(dut, LBU, 0x00000003, 0xAABBCCDD, 0x000000AA, 0x00000000, "LBU byte3")


@cocotb.test()
async def test_lhu(dut):
    """LHU: load halfword unsigned (zero extension)."""
    await load_check(dut, LHU, 0x00000000, 0xAABBCCDD, 0x0000CCDD, 0x00000000, "LHU hw0")
    await load_check(dut, LHU, 0x00000002, 0xAABBCCDD, 0x0000AABB, 0x00000000, "LHU hw1")


@cocotb.test()
async def test_sb(dut):
    """SB: store byte to correct lane."""
    await store_check(dut, SB, 0x00000000, 0xAABBCCDD, 0xDDDDDDDD, 0x00000000, 0b0001, "SB byte0")
    await store_check(dut, SB, 0x00000001, 0xAABBCCDD, 0xDDDDDDDD, 0x00000000, 0b0010, "SB byte1")
    await store_check(dut, SB, 0x00000002, 0xAABBCCDD, 0xDDDDDDDD, 0x00000000, 0b0100, "SB byte2")
    await store_check(dut, SB, 0x00000003, 0xAABBCCDD, 0xDDDDDDDD, 0x00000000, 0b1000, "SB byte3")


@cocotb.test()
async def test_sh(dut):
    """SH: store halfword to correct lane."""
    await store_check(dut, SH, 0x00000000, 0xAABBCCDD, 0xCCDDCCDD, 0x00000000, 0b0011, "SH hw0")
    await store_check(dut, SH, 0x00000002, 0xAABBCCDD, 0xCCDDCCDD, 0x00000000, 0b1100, "SH hw1")


@cocotb.test()
async def test_sw(dut):
    """SW: store word."""
    await store_check(dut, SW, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0b1111, "SW zero")
    await store_check(dut, SW, 0x00000000, 0xAABBCCDD, 0xAABBCCDD, 0x00000000, 0b1111, "SW data")
    await store_check(dut, SW, 0x00000004, 0xAABBCCDD, 0xAABBCCDD, 0x00000004, 0b1111, "SW aligned+4")
