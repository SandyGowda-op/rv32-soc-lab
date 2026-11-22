# smoke: the harness works if this passes
    addi x5, x0, 42
    addi x31, x0, 0x7FC     # exit address
    sw   x0, 0(x31)         # testbench sees this store and stops
