# Ike shadow build

This directory is AICI's first consumer slice for Ike.

AICI still compiles and self-tests its core verifier directly. In parallel, the
self-test workflow bootstraps one exact Ike revision directly from `ike.c`,
uses this literal `Ikefile` to build and self-test the same AICI core through
Ike, compares the resulting binary with the direct build, and independently
checks Ike's `ike-build-v1` receipt.

The receipt verifier does not trust Ike's PASS result. It requires the selected
target, caller-anchored Ikefile identity, POSIX recipe-runner identity, exact
rule/recipe order, zero recipe statuses, and final PASS result. Targeted
known-bad fixtures mutate each of those fields.

This is a shadow path. It does not yet claim that Ike is AICI's sole or required
build orchestrator. Promotion should happen only after the pinned producer
revision and this consumer path are green together.
