.global start
.extern main

.equ SEG_KCODE, (1 << 3)
.equ SEG_KDATA, (2 << 3)

.section .bss
.balign 4096
stack:
    .skip 4096

.section .text
.code32
start:
    movl $stack+4096, %esp
    call main
    hlt