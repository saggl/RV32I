# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Single-cycle RV32I (RISC-V 32-bit Integer) processor implemented in Verilog. The design follows a classic datapath architecture with separate instruction and data memory interfaces (Harvard architecture).

## Build & Simulation Commands

**Prerequisites:** Icarus Verilog (`iverilog`) for simulation, `riscv64-unknown-elf-gcc` toolchain for assembling RISC-V test programs. Optional: Verilator + cocotb + Python 3 for advanced testing.

### Build firmware from RISC-V assembly test programs
```bash
make
```
Uses the `riscv64-unknown-elf-gcc` toolchain (prefix: `riscv64-unknown-elf-`) to compile `.S` files in `tests/` and link them into `firmware/firmware.hex` via `firmware/sections.lds` linker script.

### Run all unit testbenches (individual modules + full processor)
```bash
make test-unit
```
Compiles and runs iverilog testbenches for: ALU, branch comparator, control unit, register file, immediate generator, load/store unit, and the full rv32i processor. Outputs are placed in `build/`. Reports aggregate pass/fail count and exits non-zero on any failure.

### Run the full processor testbench with hex firmware
```bash
make test-system
```
Compiles and runs the processor with `tb/testbench.v` which loads firmware from `firmware/firmware.hex`.

### Run all tests
```bash
make test
```
Runs both unit and system testbenches.

### Run Verilator + cocotb tests
```bash
make test-verilator
```
Runs cocotb Python testbenches via Verilator (requires cocotb and verilator installed).

### Lint RTL
```bash
make lint
```
Runs `verilator --lint-only -Wall` on all RTL sources.

### Assemble a single test file
```bash
riscv64-unknown-elf-gcc -c -march=rv32i -mabi=ilp32 -o build/tests/add.o tests/add.S
riscv64-unknown-elf-objdump -D build/tests/add.o
```

### Clean build artifacts
```bash
make clean
```

## Architecture

The processor (`rtl/rv32i.v`) is the top-level module that wires together these submodules:

- **`rtl/alu.v`** - ALU supporting add/sub, shifts (SLL/SRL/SRA), comparisons (SLT/SLTU), and logic ops (XOR/OR/AND). Operation selected by 4-bit `alu_sel` (encoding: `{funct7[5], funct3}`).
- **`rtl/controlunit.v`** - Decodes `opcode[6:2]`, `funct3`, `funct7[5]`, and branch comparison results into all datapath control signals (pc_sel, imm_sel, reg_wen, a_sel, b_sel, alu_sel, mem_rw, wb_sel). Opcodes defined as localparams (LOAD, MISC_MEM, OP_IMM, AUIPC, STORE, OP, LUI, BRANCH, JALR, JAL, SYSTEM). FENCE (MISC_MEM) is treated as NOP. `trap` only fires on ECALL/EBREAK (SYSTEM with funct3==000), not on CSR instructions. `reg_wen` is enabled for CSR reads (SYSTEM with funct3!=000).
- **`rtl/regfile.v`** - 32x32-bit register file with two read ports and one write port. Register x0 is hardwired to zero (both read and write protected).
- **`rtl/immgen.v`** - Immediate generator for all RV32I immediate formats: I, S, B, U, J (selected by 3-bit `imm_sel`).
- **`rtl/branchcomp.v`** - Branch comparator producing `br_eq` and `br_lt` signals, supporting both signed and unsigned comparison (via `br_un`).
- **`rtl/loadstoreunit.v`** - Handles byte/halfword/word loads and stores with sign/zero extension. Manages address alignment and byte-lane write enables (`data_we`).
- **`rtl/csr.v`** - CSR (Control and Status Register) unit implementing machine-mode registers (mstatus, mtvec, mepc, mcause, mie/mip, counters). Wired into `rv32i.v` — handles Zicsr instructions, interrupt/exception trap entry/return, and priority-encoded mcause.

### Top-level I/O (`rtl/rv32i.v`)
- `inst_rdata`/`inst_addr` - Instruction memory interface
- `data_rdata`/`data_addr`/`data_wdata`/`data_we` - Data memory interface
- `irq[2:0]` - External interrupt inputs (MEI, MTI, MSI)
- `trap` - Raised on ECALL/EBREAK

## File Organization

```
rtl/                 - RTL source modules
tb/                  - Testbenches and test vectors
  *_tb.v             - iverilog unit testbenches
  *_testvec.txt      - Test vector files
  testbench.v        - Full system testbench
  cocotb/            - cocotb Python testbenches
    test_*.py        - Per-module cocotb tests
    Makefile          - cocotb build system
tests/               - RISC-V ISA compliance test assembly (.S) and headers
firmware/            - Firmware build support (start.S, sections.lds, makehex.py)
build/               - Build artifacts (gitignored)
```

## Testing

### Unit testbenches (iverilog)
Each module has a `*_tb.v` testbench in `tb/` that reads test vectors from a corresponding `*_testvec.txt` file. Testbenches use `$readmemb`/`$readmemh` to load vectors and compare outputs against expected values, reporting error counts. Run with `make test-unit`.

### cocotb testbenches (Verilator)
Each module also has a `test_*.py` cocotb test in `tb/cocotb/`. These use Python assertions and cocotb's `Clock`, `RisingEdge`, and `Timer` utilities. Run with `make test-verilator` or `make -C tb/cocotb test-all`.

### RISC-V ISA compliance tests
Assembly files in `tests/` (add.S, addi.S, and.S, beq.S, etc.) are RISC-V ISA compliance tests derived from riscv-tests. They use macros from `tests/riscv_test.h` and `tests/test_macros.h`. Test pass/fail is reported by writing "OK" or "ERROR" to the output address `0x10000000`.

### Full system testbench (`tb/testbench.v`)
Simulates the processor with a 128KB memory array loaded from `firmware/firmware.hex`. Monitors stores to address `0x10000000` as character output. Runs for 5000 cycles or until trap. Run with `make test-system`.
