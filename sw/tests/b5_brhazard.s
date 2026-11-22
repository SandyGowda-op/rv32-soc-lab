# B5: the branch that looks into the past
    addi x1, x0, 5
    nop
    nop
    nop
    addi x1, x0, 0
    beq  x1, x0, L       # x1 is 0, so this must be taken
    addi x2, x0, 99      # must be skipped
L:
    addi x3, x0, 1
    addi x31, x0, 0x7FC
    sw   x0, 0(x31)
