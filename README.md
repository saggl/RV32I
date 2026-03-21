# RV32I

> A compact, hackable **single-cycle RISC-V RV32I core** in Verilog.

This project is built for learning and experimentation: clear RTL modules, small focused testbenches, and fast local simulation with Icarus Verilog.

## What’s here

- Single-cycle RV32I-style core (`rv32i.v`)
- Key building blocks:
  - `controlunit.v`
  - `alu.v`
  - `immgen.v`
  - `regfile.v`
  - `branchcomp.v`
  - `loadstoreunit.v`
- Integration testbench: `testbench.v`
- Module testbenches: `*_tb.v`
- Assembly test programs: root `*.S` + `tests/*.S`

## Quick start

### Requirements

- `iverilog`
- `vvp`
- (optional) RISC-V GNU toolchain for assembly/object workflows (`riscv64-unknown-elf-*`)

### Run module + core testbenches

```bash
bash test.sh
```

### Run top-level integration bench

```bash
bash full.sh
```

## Project layout

- `rv32i.v` + component `*.v` files — core RTL
- `*_tb.v` and `testbench.v` — simulation benches
- `tests/` — additional assembly tests
- `test.sh` — runs module benches + `rv32i_tb`
- `full.sh` — runs top-level integration simulation

## Status

- ✅ Great for architecture exploration and iterative RTL improvements
- ⚠️ Still a personal/educational project (not a production-ready core)

---

If you want, next step can be adding a minimal `CONTRIBUTING.md` and `LICENSE` so the repo is easier to share publicly.
