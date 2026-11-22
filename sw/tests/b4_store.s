# B4: the stale store
    addi x1, x0, 256
    addi x2, x0, 7
    sw   x2, 0(x1)        # x2 produced 1 instruction earlier
    lw   x3, 0(x1)
    addi x4, x0, 9
    nop
    sw   x4, 4(x1)        # x4 produced 2 instructions earlier
    lw   x5, 4(x1)
    addi x31, x0, 0x7FC
    sw   x0, 0(x31)
