.section .text
.global _start

/* Declare all *_ret symbols global so test objects can reference them */
.global simple_ret, add_ret, addi_ret, and_ret, andi_ret, auipc_ret
.global beq_ret, bge_ret, bgeu_ret, blt_ret, bltu_ret, bne_ret
.global j_ret, jal_ret, jalr_ret
.global lb_ret, lbu_ret, lh_ret, lhu_ret, lui_ret, lw_ret
.global or_ret, ori_ret
.global sb_ret, sh_ret
.global sll_ret, slli_ret, slt_ret, slti_ret, srli_ret, sub_ret, sw_ret
.global xor_ret, xori_ret

_start:
    /* set stack pointer */
    lui sp, %hi(_stack)
    addi sp, sp, %lo(_stack)

    /* copy .data from flash (LMA) to RAM (VMA) */
    lui a0, %hi(_data_lma)
    addi a0, a0, %lo(_data_lma)
    lui a1, %hi(_data_start)
    addi a1, a1, %lo(_data_start)
    lui a2, %hi(_data_end)
    addi a2, a2, %lo(_data_end)
.copy_data:
    bge a1, a2, .copy_data_done
    lw a3, 0(a0)
    sw a3, 0(a1)
    addi a0, a0, 4
    addi a1, a1, 4
    j .copy_data
.copy_data_done:

    /* zero .bss */
    lui a0, %hi(_bss_start)
    addi a0, a0, %lo(_bss_start)
    lui a1, %hi(_bss_end)
    addi a1, a1, %lo(_bss_end)
.zero_bss:
    bge a0, a1, .zero_bss_done
    sw zero, 0(a0)
    addi a0, a0, 4
    j .zero_bss
.zero_bss_done:

    /* call test functions — each test jumps to *_ret on pass */
    jal ra, simple
simple_ret:
    jal ra, add
add_ret:
    jal ra, addi
addi_ret:
    jal ra, and
and_ret:
    jal ra, andi
andi_ret:
    jal ra, auipc
auipc_ret:
    jal ra, beq
beq_ret:
    jal ra, bge
bge_ret:
    jal ra, bgeu
bgeu_ret:
    jal ra, blt
blt_ret:
    jal ra, bltu
bltu_ret:
    jal ra, bne
bne_ret:
    jal ra, j
j_ret:
    jal ra, jal
jal_ret:
    jal ra, jalr
jalr_ret:
    jal ra, lb
lb_ret:
    jal ra, lbu
lbu_ret:
    jal ra, lh
lh_ret:
    jal ra, lhu
lhu_ret:
    jal ra, lui
lui_ret:
    jal ra, lw
lw_ret:
    jal ra, or
or_ret:
    jal ra, ori
ori_ret:
    jal ra, sb
sb_ret:
    jal ra, sh
sh_ret:
    jal ra, sll
sll_ret:
    jal ra, slli
slli_ret:
    jal ra, slt
slt_ret:
    jal ra, slti
slti_ret:
    jal ra, srli
srli_ret:
    jal ra, sub
sub_ret:
    jal ra, sw
sw_ret:
    jal ra, xor
xor_ret:
    jal ra, xori
xori_ret:

    /* halt — all tests passed */
    ebreak
    j .
