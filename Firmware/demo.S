    
    .align 2
    .set nomicromips
    .set noreorder
    .set noat
    
    .text
    
    .ent start
start:
    lw      $1, 0($0)
    lw      $2, 4($0)
    add     $3, $1, $2
    sw      $3, 8($0)
    j       start

    .end start
    