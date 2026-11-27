# Ike shadow build

This directory is AICI's first consumer slice for Ike.

AICI still compiles and self-tests its core verifier directly. In parallel, the
self-test workflow bootstraps one exact Ike revision directly from `ike.c`,
uses this literal `Ikefile` to build and self-test the same AICI core through
Ike, compares the resulting binary with the direct build, and independently
checks Ike's `ike-build-v1` receipt. The push and pull-request self-test also
matches the observed result of each case to `tests/cases.tsv`, including the
expected diagnostic. It tests the checker with damaged copies of the current
run and retains its stdout alongside the receipt.

The receipt verifier does not trust Ike's PASS result. It requires the selected
target, caller-anchored Ikefile identity, POSIX recipe-runner identity, exact
rule/recipe order, zero recipe statuses, and final PASS result. Targeted
known-bad fixtures mutate each of those fields.

The job repeats the invocation with an up-to-date binary and a future-dated
self-test target. Ike legitimately skips both recipes and exits successfully.
The fresh-build verifier must reject that receipt for missing recipe execution.
