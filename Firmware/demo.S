.text

.global _start
_start:
    ADDI    x1, x0, 0x51
    ADDI    x2, x0, 0x52
    ADD     x3, x1, x2
    SW      x3, 8(x0)

    ADDI    x4, x0, 0xA0
L1:
    ADDI    x4, x4, 1
    BNE     x3, x4, L1

    LW      x1, 0(x0)
    LW      x2, 4(x0)
    ADD     x3, x1, x2

L2:    
    J       L2
