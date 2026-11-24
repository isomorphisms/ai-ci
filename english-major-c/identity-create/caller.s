.syntax unified
.arch armv7-a
.arm
.text
.global _start
.type _start,%function
_start:
    ldr r4, =cases
request:
    ldr r5, =current
    str r4, [r5]
    mov r0, #0
    str r0, [r5,#4]                @ allocation calls
    str r0, [r5,#8]                @ notification calls
    ldr r0, =head
    ldr r1, [r4]                   @ requested ID
    ldr r2, [r4,#4]                @ input name
    blx english_identity_create
    ldr r1, [r4,#8]                @ expected result
    cmp r0, r1
    bne bad_status
    cmp r1, #1
    moveq r2, #0
    movne r2, #1
    ldr r3, [r5,#4]
    cmp r3, r2
    bne bad_events
    cmp r1, #0
    moveq r2, #1
    movne r2, #0
    ldr r3, [r5,#8]
    cmp r3, r2
    bne bad_events
    ldr r0, [r4,#16]
    bl check_state
    add r4, r4, #20
    ldr r0, =end_cases
    cmp r4, r0
    bne request
    mov r0, #0
    b leave

.global identity_allocate_kernel
.type identity_allocate_kernel,%function
identity_allocate_kernel:
    tst sp, #7
    bne bad_stack
    cmp r0, #36
    bne bad_size
    ldr r1, =current
    ldr r2, [r1]
    ldr r3, [r2,#8]
    cmp r3, #1
    beq bad_events
    ldr r3, [r1,#4]
    cmp r3, #0
    bne bad_events
    mov r3, #1
    str r3, [r1,#4]
    ldr r0, [r2,#12]               @ dirty object or null
    mov r1, #255
    mov r2, #255
    bx lr

.global identity_created
.type identity_created,%function
identity_created:
    tst sp, #7
    bne bad_stack
    ldr r2, =current
    ldr r3, [r2,#4]
    cmp r3, #1
    bne bad_events
    ldr r3, [r2,#8]
    cmp r3, #0
    bne bad_events
    mov r3, #1
    str r3, [r2,#8]
    ldr r2, [r2]
    ldr r3, [r2,#8]
    cmp r3, #0
    bne bad_events
    ldr r3, [r2]
    cmp r3, r0
    bne bad_notification
    ldr r3, [r2,#4]
    cmp r3, r1
    bne bad_notification
    push {r4, lr}
    ldr r0, [r2,#16]
    bl check_state                 @ the published node must already be initialized
    mov r0, #255                  @ caller must set its own return value
    pop {r4, pc}

@ Each expected row is (object, ID, expected name). An object of zero ends the ring.
.type check_state,%function
check_state:
    push {r4-r8, lr}
    mov r4, r0
    ldr r5, =head
next_expected:
    ldr r6, [r4]
    cmp r6, #0
    beq sentinel
    add r7, r6, #28
    ldr r0, [r5]
    cmp r0, r7
    bne bad_links
    ldr r0, [r7,#4]
    cmp r0, r5
    bne bad_links
    ldr r0, [r6,#20]
    ldr r1, [r4,#4]
    cmp r0, r1
    bne bad_fields
    ldrb r0, [r6,#24]
    cmp r0, #0
    bne bad_fields
    ldr r0, [r4,#8]
    mov r8, #0
byte:
    ldrb r2, [r0,r8]
    ldrb r3, [r6,r8]
    cmp r2, r3
    bne bad_name
    add r8, r8, #1
    cmp r8, #20
    bne byte
    mov r5, r7
    add r4, r4, #12
    b next_expected
sentinel:
    ldr r0, =head
    ldr r1, [r5]
    cmp r0, r1
    bne bad_links
    ldr r1, [r0,#4]
    cmp r1, r5
    bne bad_links
    pop {r4-r8, pc}

bad_status:       mov r0,#40
                  b leave
bad_size:         mov r0,#41
                  b leave
bad_events:       mov r0,#42
                  b leave
bad_links:        mov r0,#44
                  b leave
bad_name:         mov r0,#45
                  b leave
bad_fields:       mov r0,#46
                  b leave
bad_stack:        mov r0,#47
                  b leave
bad_notification: mov r0,#48
leave:            mov r7,#1
                  svc #0

.section .rodata
.balign 4
cases:
    @ id, original string, expected status, allocator return, expected front-to-back rows
    .word 0x80000000, 0,            1, 0,         ring_seed
    .word 99,         0,            2, 0,         ring_seed
    .word 99,         oversized,    0, allocated_a, ring_a
    .word 99,         0,            1, 0,         ring_a
    .word 0,          short_name,   0, allocated_b, ring_b
    .word -1,         0,            2, 0,         ring_b
    .word -1,         empty_name,   0, allocated_c, ring_c
end_cases:
@ Overlapping tables reflect actual prepending. Every older identity stays reachable.
ring_c:    .word allocated_c, -1, empty_expected
ring_b:    .word allocated_b,  0, short_expected
ring_a:    .word allocated_a, 99, capped_expected
ring_seed: .word seed, 0x80000000, seed_expected
           .word 0
oversized:       .asciz "ABCDEFGHIJKLMNOPQRS_should_not_be_stored"
capped_expected: .asciz "ABCDEFGHIJKLMNOPQRS"
short_name:      .byte 0xff, 0x61, 0, 0xfe, 0
short_expected:  .byte 0xff, 0x61
                 .zero 18
empty_name:      .byte 0
empty_expected:  .zero 20
seed_expected:   .ascii "seed"
                 .zero 16

.data
.balign 4
current:     .word 0, 0, 0
head:        .word seed_link, seed_link
seed:        .ascii "seed"
             .zero 16
             .word 0x80000000
             .word 0
seed_link:   .word head, head
allocated_b: .fill 36,1,0xb5
allocated_c: .fill 36,1,0xc5
allocated_a: .fill 36,1,0xa5
