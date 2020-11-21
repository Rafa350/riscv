.text


.global _start   
_start:
    addi    x1, x0, 0x51
    addi    x2, x0, 0x52
    add     x3, x1, x2
    sw      x3, 8(x0)
s1:    
    addi    x3, x3, 1
    j       s1

