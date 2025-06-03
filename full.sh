#rv32ihex
iverilog -o build/rv32i_hex testbench.v rv32i.v alu.v branchcomp.v controlunit.v regfile.v immgen.v loadstoreunit.v
build/rv32i_hex