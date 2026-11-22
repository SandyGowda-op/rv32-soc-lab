# F1: JAL and JALR
    addi x1, x0, 0
    jal  x5, func        # x5 = return address (0x8)
    addi x2, x0, 7       # runs after the return
    addi x31, x0, 0x7FC
    sw   x0, 0(x31)
func:
    addi x3, x0, 3
    jalr x0, 0(x5)
