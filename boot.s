.global start
.extern main
.extern gdtdesc

.equ SEG_KCODE, (1 << 3)
.equ SEG_KDATA, (2 << 3)

.section .bss
.balign 4096
stack:
    .skip 4096

.section .text
.code32
start:
    lgdt gdtdesc
    ljmp $SEG_KCODE, $reload_cs
reload_cs:
    movw $SEG_KDATA, %ax
    movw %ax, %ss
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    movl $stack+4096, %esp
    call main
    hlt