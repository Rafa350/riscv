    .section .text
    .option norvc

test:
    .global test

    // Test SRL
    //
    lui  t0, 0xF0000
    srli t0,t0,4
    srli t0,t0,4
    srli t0,t0,4

    jalr zero,0(ra)
