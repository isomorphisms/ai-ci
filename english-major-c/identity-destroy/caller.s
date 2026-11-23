.syntax unified
.arch armv7-a
.arm
.text
.global _start
.type _start, %function
_start:
    ldr r4, =cases
next_request:
    ldr r5, =current_case
    str r4, [r5]
    mov r0, #0
    ldr r6, =release_count
    str r0, [r6]
    ldr r0, =head
    ldr r1, [r4]                 @ wanted ID
    blx english_identity_destroy

    ldr r0, [r6]
    ldr r1, [r4, #4]             @ expected released base, null for a miss
    cmp r1, #0
    movne r1, #1
    cmp r0, r1
    bne wrong_count
    ldr r0, [r4, #8]
    bl check_ring
    add r4, r4, #12
    ldr r0, =cases_end
    cmp r4, r0
    bne next_request
    mov r0, #0
    b leave

@ R0 addresses a sequence of embedded link addresses followed by zero.
@ Compare every edge in both directions, including the two sentinel edges.
.type check_ring, %function
check_ring:
    ldr r1, =head
next_edge:
    ldr r2, [r0], #4
    cmp r2, #0
    ldreq r2, =head
    ldr r3, [r1]
    cmp r2, r3
    bne wrong_next
    ldr r3, [r2, #4]
    cmp r3, r1
    bne wrong_previous
    ldr r3, =head
    cmp r2, r3
    bxeq lr
    mov r1, r2
    b next_edge

.global identity_release
.type identity_release, %function
identity_release:
    tst sp, #7
    bne wrong_stack
    push {r4, r5, r7, lr}
    mov r4, r0
    ldr r0, =current_case
    ldr r5, [r0]
    ldr r0, [r5, #4]
    cmp r0, #0
    beq wrong_object
    cmp r0, r4
    bne wrong_object
    ldr r1, =release_count
    ldr r0, [r1]
    cmp r0, #0
    bne wrong_count
    mov r0, #1
    str r0, [r1]
    ldr r0, [r5, #8]
    bl check_ring                @ the splice must precede deallocation
    ldr r0, [r4, #28]
    cmp r0, #0x100
    bne wrong_marker
    ldr r0, [r4, #32]
    movw r1, #0x122
    cmp r0, r1
    bne wrong_marker
    mov r0, r4                   @ each allocation starts on its own page
    mov r1, #4096
    mov r2, #0                   @ PROT_NONE
    mov r7, #125                 @ Linux ARM EABI mprotect
    svc #0
    cmp r0, #0
    bne protection_failed
    pop {r4, r5, r7, pc}

wrong_object:      mov r0, #32
                   b leave
wrong_next:        mov r0, #33
                   b leave
wrong_previous:    mov r0, #34
                   b leave
wrong_count:       mov r0, #35
                   b leave
wrong_marker:      mov r0, #36
                   b leave
wrong_stack:       mov r0, #37
                   b leave
protection_failed: mov r0, #38
leave:             mov r7, #1
                   svc #0

.section .rodata
.balign 4
cases:
    @ ID, expected object released, expected traversal after the call.
    .word 16,  0,         all_nodes       @ miss before any deletion
    .word 0,   middle,    no_middle       @ remove interior node
    .word -7,  first,     no_first        @ first duplicate only
    .word 17,  last,      singleton
    .word 17,  0,         singleton       @ repeated deletion
    .word -7,  duplicate, empty
    .word -7,  0,         empty
cases_end:
all_nodes: .word first_link, middle_link, duplicate_link, last_link, 0
no_middle: .word first_link, duplicate_link, last_link, 0
no_first:  .word duplicate_link, last_link, 0
singleton: .word duplicate_link, 0
empty:     .word 0

.data
.balign 4
head:          .word first_link, last_link
current_case:  .word 0
release_count: .word 0
.macro node name, id, successor, predecessor
    .balign 4096
\name:
    .fill 20, 1, 0x62
    .word \id
    .byte 0, 0, 0, 0
\name\()_link:
    .word \successor, \predecessor
.endm
    node duplicate, -7, last_link,     middle_link
    node first,     -7, middle_link,   head
    node last,      17, head,          duplicate_link
    node middle,     0, duplicate_link,first_link
    .balign 4096
