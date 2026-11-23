.syntax unified
.arch armv7-a
.arm
.text
.global _start
.type _start, %function
_start:
    @ The expected answer and the requested value come from this independent caller.
    @ The lists are read-only. The order of members in memory differs from link order.
.macro check index, head, key, result
    ldr r0, =\head
    ldr r1, =\key
    blx english_identity_find
    ldr r2, =\result
    cmp r0, r2
    movne r0, #\index
    bne leave
.endm
    check 1, empty, 0, 0
    check 2, head, 0x80000000, high
    check 3, head, 0, zero
    check 4, head, 0x7fffffff, last
    check 5, head, 0x80000001, 0
    check 6, singleton, 0xffffffff, only
    check 7, singleton, 0, 0
    mov r0, #0
leave:
    mov r7, #1
    svc #0
.size _start, .-_start

.section .rodata
.balign 4
empty:     .word empty, empty
head:      .word high_link, last_link
singleton: .word only_link, only_link

.macro identity name, key, successor, predecessor
.balign 4
\name:
    .fill 20, 1, 0x5a
    .word \key
    .byte 1, 0, 0, 0
\name\()_link:
    .word \successor, \predecessor
.endm
    identity last,      0x7fffffff, head,      duplicate_link
    identity duplicate, 0x80000000, last_link, zero_link
    identity zero,      0,          duplicate_link, high_link
    identity only,      0xffffffff, singleton, singleton
    identity high,      0x80000000, zero_link, head
