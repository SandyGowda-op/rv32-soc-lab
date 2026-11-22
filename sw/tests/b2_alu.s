# B2: the ALU that isn't there
    addi x1, x0, 12
    addi x2, x0, 5
    sub  x3, x1, x2
    and  x4, x1, x2
    or   x5, x1, x2
    xor  x6, x1, x2
    slt  x7, x2, x1
    sll  x8, x2, x2
    srai x9, x3, 1
    addi x10, x0, 1024
    srli x11, x10, 3
    addi x13, x0, -16
    srai x14, x13, 2
    srli x15, x13, 28
    sltu x16, x13, x1
    slt  x17, x13, x1
    sltiu x18, x1, 13
    andi x19, x13, 0xFF
    xori x20, x1, -1
    srl  x21, x13, x2
    sra  x22, x13, x2
    slti x23, x13, -15
    ori  x24, x1, 3
    slli x25, x2, 2
    addi x31, x0, 0x7FC
    sw   x0, 0(x31)
