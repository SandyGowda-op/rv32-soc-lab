# B3: every branch is BEQ
    addi x1, x0, 3
    addi x2, x0, 0
loop:
    addi x1, x1, -1
    add  x2, x2, x1
    bne  x1, x0, loop
    addi x3, x0, -1
    addi x4, x0, 1
    nop
    blt  x3, x4, L1
    addi x5, x0, 99      # must be skipped
L1:
    bltu x3, x4, L2
    addi x6, x0, 42      # must execute
L2:
    addi x31, x0, 0x7FC
    sw   x0, 0(x31)
