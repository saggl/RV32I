.section .text
.global _start
_start:
    /* set stack pointer */
    lui sp, %hi(_stack)
    addi sp, sp, %lo(_stack)

    /* call test functions */
    jal ra, _test_entry

    /* halt */
    ebreak
    j .

.global _test_entry
_test_entry:
    ret
