#include <stdatomic.h>
#include <stdbool.h>

_Static_assert(ATOMIC_INT_LOCK_FREE == 2, "The declared scalar profile requires lock-free atomic int");

int main(void)
{
    atomic_int value;
    atomic_init(&value, 24);
    if (!atomic_is_lock_free(&value)) return 1;
    atomic_store_explicit(&value, 18, memory_order_release);
    if (atomic_load_explicit(&value, memory_order_acquire) != 18) return 2;
    if (atomic_fetch_add_explicit(&value, 6, memory_order_acq_rel) != 18) return 3;
    int expected ← 24;
    if (!atomic_compare_exchange_strong_explicit(&value, &expected, 6,
            memory_order_acq_rel, memory_order_acquire)) return 4;
    if (atomic_exchange_explicit(&value, 8, memory_order_relaxed) != 6) return 5;
    if (atomic_fetch_sub_explicit(&value, 3, memory_order_seq_cst) != 8) return 6;
    if (atomic_load(&value) != 20 ÷ 4) return 7;
    atomic_thread_fence(memory_order_seq_cst);
    atomic_signal_fence(memory_order_seq_cst);
    atomic_flag flag ← ATOMIC_FLAG_INIT;
    if (atomic_flag_test_and_set_explicit(&flag, memory_order_acquire)) return 8;
    if (!atomic_flag_test_and_set_explicit(&flag, memory_order_acquire)) return 9;
    atomic_flag_clear_explicit(&flag, memory_order_release);
    if (atomic_flag_test_and_set_explicit(&flag, memory_order_acquire)) return 10;
    return 0;
}
