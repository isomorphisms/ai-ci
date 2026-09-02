# Equality assignment observation

This is the first AICI integration for `the-equality-sign-means-equality`.
It does **not** decide whether an assignment is correct and it does not yet
contain a vector index. It gives AICI a stable place to consume discrepancy
signals, preserve warnings, and measure the overhead of doing that on every
assignment.

## Deliberately dishonest test oracles

The provider currently exposes two mocks:

- `rubber_stamp`: always emits discrepancy `0.0` even when that conclusion is
  unjustified. The name means approval without checking.
- `cry_wolf`: always emits positive infinite discrepancy whether anything is
  wrong or not.

Both mocks emit a warning beginning `THIS INFORMATION IS NOT TRUE`. AICI's
self-test requires that warning to survive the integration. The mocks are
there so downstream repositories can force both ends of the discrepancy range
without mistaking either result for evidence.

## Provisional UTF-8 handles

The provider output is intentionally plain, ragged UTF-8. For now AICI grips
only these records:

```text
𝕋 discrepancy
0.0
𝕎 warning
THIS INFORMATION IS NOT TRUE: ...
```

`𝕋` and `𝕎` are provisional handles, not a final protocol. Unrecognized lines
and unrecognized `𝕋`/`𝕎` records are ignored. A discrepancy record or warning
may therefore coexist with future type information, provenance, timing,
backend details, or other fields without forcing every consumer to understand
them immediately.

A signal without both a discrepancy and a warning is malformed. A large or
infinite discrepancy is **not** itself a build failure in this first slice.
The consumer decides later what threshold or policy, if any, should block.

## Run locally

```text
cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 \
  -o /tmp/aici-equality src/aici_equality.c -lm

python3 /path/to/the-equality-sign-means-equality/equality_mocks.py rubber-stamp \
  > /tmp/rubber-stamp.signal
python3 /path/to/the-equality-sign-means-equality/equality_mocks.py cry-wolf \
  > /tmp/cry-wolf.signal

/tmp/aici-equality self-test /tmp/rubber-stamp.signal /tmp/cry-wolf.signal
/tmp/aici-equality assignment /tmp/rubber-stamp.signal 'x' 'f(y)'
/tmp/aici-equality bench /tmp/rubber-stamp.signal 100000
```

The benchmark measures only the in-process AICI parsing/observation path. It
explicitly does not claim to measure a future vector index, embedding model,
IPC boundary, or process-start cost.

## Assignment wrapper direction

The intended language-level shape is deliberately left commented out in
`src/aici_equality.c`:

```text
assignment(lhs, rhs):
    value = evaluate(rhs)
    equality_observe(lhs, value)   # warning only; preserve discrepancy
    lhs <- value
```

A compiler or language can eventually insert that wrapper around every
assignment. AICI is starting with the acceptance boundary and the benchmark so
we can measure the cost before pretending that arbitrary source languages have
already been instrumented.
