.text


.global _start   
_start:
    lw      x1, 0(x0)
    lw      x2, 4(x0)
s1:    
    add     x3, x1, x2
    addi    x3, x3, 0x11
    sw      x3, 8(x0)
    j       s1

