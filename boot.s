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
    # Print "Hello, world!" to VGA screen
    movw $0x0248, 0xb8000
    movw $0x0265, 0xb8002
    movw $0x026c, 0xb8004
    movw $0x026c, 0xb8006
    movw $0x026f, 0xb8008
    movw $0x022c, 0xb800a
    movw $0x0220, 0xb800c
    movw $0x0277, 0xb800e
    movw $0x026f, 0xb8010
    movw $0x0272, 0xb8012
    movw $0x026c, 0xb8014
    movw $0x0264, 0xb8016
    movw $0x0221, 0xb8018
    call main
    hlt