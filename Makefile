# RV32I Processor Build System
# Usage:
#   make              - Build firmware hex
#   make test-unit    - Run all iverilog unit testbenches
#   make test-system  - Run full system testbench with firmware
#   make test         - Run all tests (unit + system)
#   make lint         - Verilator lint on all RTL
#   make clean        - Remove all build artifacts

SHELL := /bin/bash

# Toolchain: auto-detect prefix (Homebrew uses riscv64-elf-, others use riscv64-unknown-elf-)
TOOLCHAIN_PREFIX ?= $(shell which riscv64-unknown-elf-gcc >/dev/null 2>&1 && echo riscv64-unknown-elf- || echo riscv64-elf-)
PYTHON = python3

# RTL sources
RTL_SRCS = $(wildcard rtl/*.v)
RTL_NAMES = rv32i alu branchcomp controlunit regfile immgen loadstoreunit csr

# Firmware
TEST_OBJS = $(patsubst tests/%.S,build/tests/%.o,$(wildcard tests/*.S))
FIRMWARE_OBJS = build/firmware/start.o

# Build directory
BUILD = build

# Default target
all: firmware/firmware.hex

#############################################################################
# Firmware build
#############################################################################

firmware/firmware.hex: firmware/firmware.bin firmware/makehex.py
	$(PYTHON) firmware/makehex.py $< 32768 > $@

firmware/firmware.bin: firmware/firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@
	chmod -x $@

firmware/firmware.elf: $(FIRMWARE_OBJS) $(TEST_OBJS) firmware/sections.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -march=rv32i -mabi=ilp32 -ffreestanding -nostdlib -o $@ \
		-Wl,-Bstatic,-T,firmware/sections.lds,-Map,firmware/firmware.map,--strip-debug \
		$(FIRMWARE_OBJS) $(TEST_OBJS) -lgcc
	chmod -x $@

build/firmware/start.o: firmware/start.S | $(BUILD)/firmware
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32i -mabi=ilp32 -o $@ $<

build/tests/%.o: tests/%.S tests/riscv_test.h tests/test_macros.h | $(BUILD)/tests
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32i -mabi=ilp32 -o $@ -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $<

#############################################################################
# Unit testbenches (iverilog)
#############################################################################

UNIT_TBS = alu branchcomp controlunit regfile immgen loadstoreunit rv32i

# Build rules for unit testbench executables
$(BUILD)/alu: tb/alu_tb.v rtl/alu.v | $(BUILD)
	iverilog -o $@ $^

$(BUILD)/branchcomp: tb/branchcomp_tb.v rtl/branchcomp.v | $(BUILD)
	iverilog -o $@ $^

$(BUILD)/controlunit: tb/controlunit_tb.v rtl/controlunit.v | $(BUILD)
	iverilog -o $@ $^

$(BUILD)/regfile: tb/regfile_tb.v rtl/regfile.v | $(BUILD)
	iverilog -o $@ $^

$(BUILD)/immgen: tb/immgen_tb.v rtl/immgen.v | $(BUILD)
	iverilog -o $@ $^

$(BUILD)/loadstoreunit: tb/loadstoreunit_tb.v rtl/loadstoreunit.v | $(BUILD)
	iverilog -o $@ $^

$(BUILD)/rv32i: tb/rv32i_tb.v $(RTL_SRCS) | $(BUILD)
	iverilog -o $@ $^

test-unit: $(addprefix $(BUILD)/,$(UNIT_TBS))
	@pass=0; fail=0; \
	for tb in $(UNIT_TBS); do \
		echo "--- Running $$tb testbench ---"; \
		output=$$($(BUILD)/$$tb 2>&1); \
		echo "$$output"; \
		if echo "$$output" | grep -q "0 errors"; then \
			pass=$$((pass + 1)); \
		else \
			fail=$$((fail + 1)); \
		fi; \
	done; \
	echo ""; \
	echo "=============================="; \
	echo "Unit tests: $$pass passed, $$fail failed"; \
	echo "=============================="; \
	if [ $$fail -ne 0 ]; then exit 1; fi

#############################################################################
# Full system testbench
#############################################################################

$(BUILD)/rv32i_hex: tb/testbench.v $(RTL_SRCS) | $(BUILD)
	iverilog -o $@ $^

test-system: $(BUILD)/rv32i_hex firmware/firmware.hex
	@echo "--- Running full system testbench ---"
	$(BUILD)/rv32i_hex

#############################################################################
# Verilator + cocotb
#############################################################################

test-verilator:
	$(MAKE) -C tb/cocotb

#############################################################################
# Lint
#############################################################################

lint:
	verilator --lint-only -Wall --top-module rv32i $(RTL_SRCS)

#############################################################################
# Combined test target
#############################################################################

test: test-unit test-system

#############################################################################
# Clean
#############################################################################

clean:
	rm -rf $(BUILD)
	rm -f firmware/*.bin firmware/*.elf firmware/*.hex firmware/*.map

#############################################################################
# Directory creation
#############################################################################

$(BUILD):
	mkdir -p $@

$(BUILD)/firmware:
	mkdir -p $@

$(BUILD)/tests:
	mkdir -p $@

.PHONY: all test test-unit test-system test-verilator lint clean
