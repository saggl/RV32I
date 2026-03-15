# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Single-cycle RV32I (RISC-V 32-bit Integer) processor implemented in Verilog. The design follows a classic datapath architecture with separate instruction and data memory interfaces (Harvard architecture).

## Build & Simulation Commands

**Prerequisites:** Icarus Verilog (`iverilog`) for simulation, `riscv64-unknown-elf-gcc` toolchain for assembling RISC-V test programs.

### Run all unit testbenches (individual modules + full processor)
```bash
bash test.sh
```
This compiles and runs testbenches for: ALU, branch comparator, control unit, register file, immediate generator, load/store unit, and the full rv32i processor. Outputs are placed in `build/`.

### Run only the full processor testbench with hex firmware
```bash
bash full.sh
```
Compiles and runs the processor with `testbench.v` which loads firmware from `firmware/firmware.hex`.

### Build firmware from RISC-V assembly test programs
```bash
make
```
Uses the `riscv64-unknown-elf-gcc` toolchain (prefix: `riscv64-unknown-elf-`) to compile `.S` files in `tests/` and link them into `firmware/firmware.hex` via `firmware/sections.lds` linker script.

### Assemble a single test file
```bash
riscv64-unknown-elf-gcc -c -march=rv32i -mabi=ilp32 -o build/test.o tests/add.S
riscv64-unknown-elf-objdump -D build/test.o
```

### Clean build artifacts
```bash
make clean
```

## Architecture

The processor (`rv32i.v`) is the top-level module that wires together these submodules:

- **`alu.v`** - ALU supporting add/sub, shifts (SLL/SRL/SRA), comparisons (SLT/SLTU), and logic ops (XOR/OR/AND). Operation selected by 4-bit `alu_sel` (encoding: `{funct7[5], funct3}`).
- **`controlunit.v`** - Decodes `opcode[6:2]`, `funct3`, `funct7[5]`, and branch comparison results into all datapath control signals (pc_sel, imm_sel, reg_wen, a_sel, b_sel, alu_sel, mem_rw, wb_sel). Opcodes defined as localparams (LOAD, OP_IMM, AUIPC, STORE, OP, LUI, BRANCH, JALR, JAL, SYSTEM). `reg_wen` uses a whitelist of write-producing opcodes.
- **`regfile.v`** - 32x32-bit register file with two read ports and one write port. Register x0 is hardwired to zero (both read and write protected).
- **`immgen.v`** - Immediate generator for all RV32I immediate formats: I, S, B, U, J (selected by 3-bit `imm_sel`).
- **`branchcomp.v`** - Branch comparator producing `br_eq` and `br_lt` signals, supporting both signed and unsigned comparison (via `br_un`).
- **`loadstoreunit.v`** - Handles byte/halfword/word loads and stores with sign/zero extension. Manages address alignment and byte-lane write enables (`data_we`).
- **`csr.v`** - CSR (Control and Status Register) unit implementing machine-mode registers (mstatus, mtvec, mepc, mcause, mie/mip, counters). Compiles cleanly but **not yet wired into `rv32i.v`**. Contains TODO markers for incomplete exception detection and trap cause logic.

### Top-level I/O (`rv32i.v`)
- `inst_rdata`/`inst_addr` - Instruction memory interface
- `data_rdata`/`data_addr`/`data_wdata`/`data_we` - Data memory interface
- `trap` - Raised on SYSTEM instructions (ECALL/EBREAK)

## File Organization

```
*.v                  - RTL source modules (root level)
testbench.v          - Full system testbench (root level)
testbench/           - Unit testbenches (*_tb.v) and test vectors (*_testvec.txt)
tests/               - RISC-V ISA compliance test assembly (.S) and headers
firmware/            - Firmware build support (start.S, sections.lds, makehex.py)
build/               - Build artifacts (gitignored)
```

## Testing

### Unit testbenches
Each module has a `*_tb.v` testbench in `testbench/` that reads test vectors from a corresponding `*_testvec.txt` file. Testbenches use `$readmemb`/`$readmemh` to load vectors and compare outputs against expected values, reporting error counts.

### RISC-V ISA compliance tests
Assembly files in `tests/` (add.S, addi.S, and.S, beq.S, etc.) are RISC-V ISA compliance tests derived from riscv-tests. They use macros from `tests/riscv_test.h` and `tests/test_macros.h`.

Test pass/fail is reported by writing "OK" or "ERROR" to the output address `0x10000000`.

### Full system testbench (`testbench.v`)
Simulates the processor with a 128KB memory array loaded from `firmware/firmware.hex`. Monitors stores to address `0x10000000` as character output. Runs for 5000 cycles or until trap.
