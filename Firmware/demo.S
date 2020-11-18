.text


.global _start   
_start:
    addi    x1, x0, 0x55
    addi    x2, x0, 0x55

    add     x0, x0, x0
    add     x0, x0, x0
    add     x0, x0, x0
    
    add     x3, x1, x2    

    add     x0, x0, x0
    add     x0, x0, x0
    add     x0, x0, x0

s1:
    sw      x3, 8(x0)
    j       s1

