# cocotb Makefile for RV32I testbenches
# Usage:
#   make                     # Run all tests (default: full processor)
#   make MODULE=test_alu TOPLEVEL=alu    # Run ALU tests only
#   make MODULE=test_regfile TOPLEVEL=regfile
#   make MODULE=test_branchcomp TOPLEVEL=branchcomp
#   make MODULE=test_controlunit TOPLEVEL=controlunit
#   make MODULE=test_immgen TOPLEVEL=immgen
#   make MODULE=test_loadstoreunit TOPLEVEL=loadstoreunit
#   make MODULE=test_rv32i TOPLEVEL=rv32i
#   make test-all            # Run all module tests sequentially

SIM ?= verilator
TOPLEVEL_LANG = verilog

RTL_DIR = $(shell pwd)/../../rtl
VERILOG_SOURCES = $(wildcard $(RTL_DIR)/*.v)

# Default: full processor test
TOPLEVEL ?= rv32i
MODULE ?= test_rv32i

# Verilator extra args
EXTRA_ARGS += --trace
EXTRA_ARGS += -Wno-fatal

include $(shell cocotb-config --makefiles)/Makefile.sim

# Run all individual module tests
test-all:
	$(MAKE) MODULE=test_alu TOPLEVEL=alu
	$(MAKE) MODULE=test_regfile TOPLEVEL=regfile
	$(MAKE) MODULE=test_branchcomp TOPLEVEL=branchcomp
	$(MAKE) MODULE=test_controlunit TOPLEVEL=controlunit
	$(MAKE) MODULE=test_immgen TOPLEVEL=immgen
	$(MAKE) MODULE=test_loadstoreunit TOPLEVEL=loadstoreunit
	$(MAKE) MODULE=test_rv32i TOPLEVEL=rv32i

.PHONY: test-all
