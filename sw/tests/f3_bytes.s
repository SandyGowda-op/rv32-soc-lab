# F3: byte and halfword loads and stores
    addi x1, x0, 0x200
    lui  x2, 0x12345
    addi x2, x2, 0x678
    sw   x2, 0(x1)
    addi x3, x0, -1
    sb   x3, 1(x1)
    lw   x4, 0(x1)
    lb   x5, 1(x1)
    lbu  x6, 1(x1)
    lh   x7, 2(x1)
    sh   x3, 2(x1)
    lhu  x8, 2(x1)
    lh   x9, 0(x1)
    addi x31, x0, 0x7FC
    sw   x0, 0(x31)
