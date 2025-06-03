riscv64-unknown-elf-gcc -c -march=rv32i  -mabi=ilp32 -o build/test.o test.S
riscv64-unknown-elf-objdump -D build/test.o