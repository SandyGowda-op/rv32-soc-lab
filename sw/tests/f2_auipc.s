# F2: AUIPC
    nop
    auipc x1, 0          # at 0x4
    auipc x2, 1          # at 0x8
    addi x31, x0, 0x7FC
    sw   x0, 0(x31)
