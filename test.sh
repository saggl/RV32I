mkdir -p build 
#alu
iverilog -o build/alu testbench/alu_tb.v alu.v
build/alu
#branchcomp
iverilog -o build/branchcomp testbench/branchcomp_tb.v branchcomp.v
build/branchcomp
#controlunit
iverilog -o build/controlunit testbench/controlunit_tb.v controlunit.v
build/controlunit
#regfile
iverilog -o build/regfile testbench/regfile_tb.v regfile.v
build/regfile
#immgen
iverilog -o build/immgen testbench/immgen_tb.v immgen.v
build/immgen
#loadstoreunit
iverilog -o build/loadstoreunit testbench/loadstoreunit_tb.v loadstoreunit.v
build/loadstoreunit
#rv32i
iverilog -o build/rv32i testbench/rv32i_tb.v rv32i.v alu.v branchcomp.v controlunit.v regfile.v immgen.v loadstoreunit.v
build/rv32i

#rv32ihex
#iverilog -o build/rv32i_hex testbench.v rv32i.v alu.v branchcomp.v controlunit.v regfile.v immgen.v loadstoreunit.v
#build/rv32i_hex