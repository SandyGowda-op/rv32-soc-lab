# B1: the three-instruction ghost
    addi x1, x0, 5
    nop
    nop
    addi x2, x1, 1        # x1 written 3 instructions earlier
    addi x31, x0, 0x7FC
    sw   x0, 0(x31)
