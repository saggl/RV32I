import cocotb
from cocotb.triggers import Timer

# Opcode encodings (inst[6:2])
LOAD     = 0b00000
MISC_MEM = 0b00011
OP_IMM   = 0b00100
AUIPC    = 0b00101
STORE    = 0b01000
OP       = 0b01100
LUI      = 0b01101
BRANCH   = 0b11000
JALR     = 0b11001
JAL      = 0b11011
SYSTEM   = 0b11100

# Branch funct3
BEQ  = 0b000
BNE  = 0b001
BLT  = 0b100
BGE  = 0b101
BLTU = 0b110
BGEU = 0b111


async def ctrl_check(dut, opcode, funct3, funct7, br_eq, br_lt,
                     exp_pc_sel, exp_imm_sel, exp_reg_wen, exp_br_un,
                     exp_a_sel, exp_b_sel, exp_alu_sel, exp_mem_rw,
                     exp_wb_sel, exp_trap, label=""):
    dut.opcode.value = opcode
    dut.funct3.value = funct3
    dut.funct7.value = funct7
    dut.br_eq.value = br_eq
    dut.br_lt.value = br_lt
    await Timer(1, units="ns")

    checks = [
        ("pc_sel",  dut.pc_sel.value.integer,  exp_pc_sel),
        ("imm_sel", dut.imm_sel.value.integer, exp_imm_sel),
        ("reg_wen", dut.reg_wen.value.integer, exp_reg_wen),
        ("br_un",   dut.br_un.value.integer,   exp_br_un),
        ("a_sel",   dut.a_sel.value.integer,   exp_a_sel),
        ("b_sel",   dut.b_sel.value.integer,   exp_b_sel),
        ("alu_sel", dut.alu_sel.value.integer, exp_alu_sel),
        ("mem_rw",  dut.mem_rw.value.integer,  exp_mem_rw),
        ("wb_sel",  dut.wb_sel.value.integer,  exp_wb_sel),
        ("trap",    dut.trap.value.integer,    exp_trap),
    ]
    for name, got, exp in checks:
        assert got == exp, f"{label}: {name} = {got}, expected {exp}"


@cocotb.test()
async def test_r_type_ops(dut):
    """R-type instructions: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND."""
    r_cases = [
        # (funct3, funct7, expected_alu_sel, label)
        (0b000, 0, 0b0000, "ADD"),
        (0b000, 1, 0b1000, "SUB"),
        (0b001, 0, 0b0001, "SLL"),
        (0b010, 0, 0b0010, "SLT"),
        (0b011, 0, 0b0011, "SLTU"),
        (0b100, 0, 0b0100, "XOR"),
        (0b101, 0, 0b0101, "SRL"),
        (0b101, 1, 0b1101, "SRA"),
        (0b110, 0, 0b0110, "OR"),
        (0b111, 0, 0b0111, "AND"),
    ]
    for funct3, funct7, alu_sel, label in r_cases:
        await ctrl_check(dut, OP, funct3, funct7, 0, 0,
                         exp_pc_sel=0, exp_imm_sel=0, exp_reg_wen=1, exp_br_un=0,
                         exp_a_sel=0, exp_b_sel=1, exp_alu_sel=alu_sel, exp_mem_rw=0,
                         exp_wb_sel=1, exp_trap=0, label=label)


@cocotb.test()
async def test_i_type_ops(dut):
    """I-type ALU instructions: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI."""
    i_cases = [
        (0b000, 0, 0b0000, "ADDI"),
        (0b010, 0, 0b0010, "SLTI"),
        (0b011, 0, 0b0011, "SLTIU"),
        (0b100, 0, 0b0100, "XORI"),
        (0b110, 0, 0b0110, "ORI"),
        (0b111, 0, 0b0111, "ANDI"),
        (0b001, 0, 0b0001, "SLLI"),
        (0b101, 0, 0b0101, "SRLI"),
        (0b101, 1, 0b1101, "SRAI"),
    ]
    for funct3, funct7, alu_sel, label in i_cases:
        await ctrl_check(dut, OP_IMM, funct3, funct7, 0, 0,
                         exp_pc_sel=0, exp_imm_sel=0, exp_reg_wen=1, exp_br_un=0,
                         exp_a_sel=0, exp_b_sel=0, exp_alu_sel=alu_sel, exp_mem_rw=0,
                         exp_wb_sel=1, exp_trap=0, label=label)


@cocotb.test()
async def test_load_store(dut):
    """Load and store instructions."""
    # LB
    await ctrl_check(dut, LOAD, 0b000, 0, 0, 0,
                     exp_pc_sel=0, exp_imm_sel=0, exp_reg_wen=1, exp_br_un=0,
                     exp_a_sel=0, exp_b_sel=0, exp_alu_sel=0, exp_mem_rw=0,
                     exp_wb_sel=0, exp_trap=0, label="LB")
    # SW
    await ctrl_check(dut, STORE, 0b010, 0, 0, 0,
                     exp_pc_sel=0, exp_imm_sel=1, exp_reg_wen=0, exp_br_un=0,
                     exp_a_sel=0, exp_b_sel=0, exp_alu_sel=0, exp_mem_rw=1,
                     exp_wb_sel=1, exp_trap=0, label="SW")


@cocotb.test()
async def test_branches(dut):
    """Branch instructions with various conditions."""
    # BEQ taken (br_eq=1)
    await ctrl_check(dut, BRANCH, BEQ, 0, 1, 0,
                     exp_pc_sel=1, exp_imm_sel=2, exp_reg_wen=0, exp_br_un=0,
                     exp_a_sel=1, exp_b_sel=0, exp_alu_sel=0, exp_mem_rw=0,
                     exp_wb_sel=1, exp_trap=0, label="BEQ taken")
    # BEQ not taken (br_eq=0)
    await ctrl_check(dut, BRANCH, BEQ, 0, 0, 0,
                     exp_pc_sel=0, exp_imm_sel=2, exp_reg_wen=0, exp_br_un=0,
                     exp_a_sel=1, exp_b_sel=0, exp_alu_sel=0, exp_mem_rw=0,
                     exp_wb_sel=1, exp_trap=0, label="BEQ not taken")
    # BNE taken (br_eq=0)
    await ctrl_check(dut, BRANCH, BNE, 0, 0, 0,
                     exp_pc_sel=1, exp_imm_sel=2, exp_reg_wen=0, exp_br_un=0,
                     exp_a_sel=1, exp_b_sel=0, exp_alu_sel=0, exp_mem_rw=0,
                     exp_wb_sel=1, exp_trap=0, label="BNE taken")
    # BLT taken (br_lt=1)
    await ctrl_check(dut, BRANCH, BLT, 0, 0, 1,
                     exp_pc_sel=1, exp_imm_sel=2, exp_reg_wen=0, exp_br_un=0,
                     exp_a_sel=1, exp_b_sel=0, exp_alu_sel=0, exp_mem_rw=0,
                     exp_wb_sel=1, exp_trap=0, label="BLT taken")
    # BLTU (unsigned)
    await ctrl_check(dut, BRANCH, BLTU, 0, 0, 1,
                     exp_pc_sel=1, exp_imm_sel=2, exp_reg_wen=0, exp_br_un=1,
                     exp_a_sel=1, exp_b_sel=0, exp_alu_sel=0, exp_mem_rw=0,
                     exp_wb_sel=1, exp_trap=0, label="BLTU taken")
    # BGEU (unsigned)
    await ctrl_check(dut, BRANCH, BGEU, 0, 0, 0,
                     exp_pc_sel=1, exp_imm_sel=2, exp_reg_wen=0, exp_br_un=1,
                     exp_a_sel=1, exp_b_sel=0, exp_alu_sel=0, exp_mem_rw=0,
                     exp_wb_sel=1, exp_trap=0, label="BGEU taken")


@cocotb.test()
async def test_lui_auipc(dut):
    """LUI and AUIPC."""
    await ctrl_check(dut, LUI, 0, 0, 0, 0,
                     exp_pc_sel=0, exp_imm_sel=3, exp_reg_wen=1, exp_br_un=0,
                     exp_a_sel=2, exp_b_sel=0, exp_alu_sel=0, exp_mem_rw=0,
                     exp_wb_sel=1, exp_trap=0, label="LUI")
    await ctrl_check(dut, AUIPC, 0, 0, 0, 0,
                     exp_pc_sel=0, exp_imm_sel=3, exp_reg_wen=1, exp_br_un=0,
                     exp_a_sel=1, exp_b_sel=0, exp_alu_sel=0, exp_mem_rw=0,
                     exp_wb_sel=1, exp_trap=0, label="AUIPC")


@cocotb.test()
async def test_jal_jalr(dut):
    """JAL and JALR."""
    await ctrl_check(dut, JAL, 0, 0, 0, 0,
                     exp_pc_sel=1, exp_imm_sel=5, exp_reg_wen=1, exp_br_un=0,
                     exp_a_sel=1, exp_b_sel=0, exp_alu_sel=0, exp_mem_rw=0,
                     exp_wb_sel=2, exp_trap=0, label="JAL")
    await ctrl_check(dut, JALR, 0, 0, 0, 0,
                     exp_pc_sel=1, exp_imm_sel=0, exp_reg_wen=1, exp_br_un=0,
                     exp_a_sel=0, exp_b_sel=0, exp_alu_sel=0, exp_mem_rw=0,
                     exp_wb_sel=2, exp_trap=0, label="JALR")


@cocotb.test()
async def test_system(dut):
    """SYSTEM instruction with funct3=000 should trap (ECALL/EBREAK)."""
    await ctrl_check(dut, SYSTEM, 0b000, 0, 0, 0,
                     exp_pc_sel=0, exp_imm_sel=0, exp_reg_wen=0, exp_br_un=0,
                     exp_a_sel=0, exp_b_sel=0, exp_alu_sel=0, exp_mem_rw=0,
                     exp_wb_sel=1, exp_trap=1, label="ECALL/EBREAK")


@cocotb.test()
async def test_csr_no_trap(dut):
    """SYSTEM instruction with funct3!=000 (CSR) should NOT trap and should enable reg_wen."""
    await ctrl_check(dut, SYSTEM, 0b001, 0, 0, 0,
                     exp_pc_sel=0, exp_imm_sel=0, exp_reg_wen=1, exp_br_un=0,
                     exp_a_sel=0, exp_b_sel=0, exp_alu_sel=0, exp_mem_rw=0,
                     exp_wb_sel=1, exp_trap=0, label="CSRRW")


@cocotb.test()
async def test_fence_nop(dut):
    """FENCE (MISC_MEM) should not trap, not write registers, not write memory."""
    await ctrl_check(dut, MISC_MEM, 0b000, 0, 0, 0,
                     exp_pc_sel=0, exp_imm_sel=0, exp_reg_wen=0, exp_br_un=0,
                     exp_a_sel=0, exp_b_sel=0, exp_alu_sel=0, exp_mem_rw=0,
                     exp_wb_sel=1, exp_trap=0, label="FENCE")
