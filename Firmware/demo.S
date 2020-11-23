.text

.global _start
_start:
    ADDI    x1, x0, 0x51
    ADDI    x2, x0, 0x52
    ADD     x3, x1, x2
    SW      x3, 8(x0)

    ADDI    x4, x0, 0xA6
L1:
    ADDI    x3, x3, 1
    ADDI    x0, x0, 0
    ADDI    x0, x0, 0
    ADDI    x0, x0, 0
    ADDI    x0, x0, 0
    ADDI    x0, x0, 0
    BNE     x3, x4, L1

L2:
    J       L2
