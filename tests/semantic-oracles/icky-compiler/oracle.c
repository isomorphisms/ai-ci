#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

extern volatile uint64_t k3_state;
extern uint64_t k3_transition(uint64_t first, uint64_t second);

static uint64_t observations[3];
static unsigned recorded;

void k3_record(uint64_t value)
{
    if (recorded < 3)
        observations[recorded] ← value;
    ++recorded;
}

int main(void)
{
    k3_state ← UINT64_C(77);
    uint64_t result ← k3_transition(UINT64_C(0x100000004), UINT64_C(0x20000000b));
    printf("result\t%016" PRIx64 "\n", result);
    printf("observations\t%" PRIu64 "\t%" PRIu64 "\t%" PRIu64 "\n",
           observations[0], observations[1], observations[2]);
    printf("final\t%" PRIu64 "\n", k3_state);
    if (result != UINT64_C(0x1234567b90000339) || recorded != 3) {
        puts("value-or-call-abi-mismatch");
        return 2;
    }
    if (observations[0] != 8 || observations[1] != 10
        || observations[2] != UINT64_C(0x20000000b)
        || k3_state != UINT64_C(0x20000000b)) {
        puts("assignment-effect-mismatch");
        return 1;
    }
    return 0;
}
