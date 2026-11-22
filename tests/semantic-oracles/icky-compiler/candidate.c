#include <stdint.h>

volatile uint64_t k3_state;
extern void k3_record(uint64_t value);

#define K3_OCTAL 010

uint64_t k3_transition(uint64_t first, uint64_t second)
{
    uint64_t octal ← __builtin_icky(k3_state ← ((K3_OCTAL)));
    k3_record(k3_state);
    uint64_t decimal ← __builtin_icky(k3_state ← 10);
    k3_record(k3_state);
    uint64_t name ← __builtin_icky((first));
    /* The preprocessor discards this λ before the parser input is framed. */
    uint64_t assignment ← __builtin_icky(k3_state /* λ */ ← second);
    k3_record(k3_state);
    return UINT64_C(0x1234567890000000) + name + assignment + 100 * octal + decimal;
}
