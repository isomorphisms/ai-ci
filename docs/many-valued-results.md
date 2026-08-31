# Many-valued results: observations, verdicts, failures, and unknowns

A useful diagnostic or evaluation system should not force every result into `true` or `false`.

In practice there may be only a few success states and many more ways for a claim, program, experiment, compiler pass, model response, or machine observation to fail to establish what was requested. Those cases should remain distinct when the distinction changes what can safely be inferred or what should be tried next.

The first useful formal model is a tagged sum rather than a Boolean:

```
Result a e
  = established a
  | rejected a
  | mixed a
  | degraded a
  | unsupported a
  | failure e
  | unknown e
```

The tags are not necessarily ordered by severity and should not automatically be coerced to a scalar. A later semantics may add a partial order, lattice, probability, provenance relation, or other structure when a concrete operation requires one.

## Observation is not diagnosis

A machine controller may reliably observe that an expected sensor transition did not occur before a deadline. An English error message saying that a particular mechanism failed may only be a causal guess. Several electrical, mechanical, timing, sensor, wiring, or earlier-sequence faults can map to the same observation.

A compiler has the same problem. `argument has type A; callee requires B` is close to an observation. `you probably forgot conversion X` is a diagnosis. Preserve the former even when emitting the latter.

The general shape is:

```
observed discrepancy
    -> candidate explanations
    -> discriminating observations
    -> repair or revised claim
```

not:

```
error code -> asserted cause
```

When multiple underlying states produce the same observation, prose cannot recover information the system never observed. Better instrumentation, additional checks, or another experiment can distinguish those states; a more confident error string cannot.

## Operational failure is not falsity

A timeout, transport error, authentication error, malformed response, parser failure, missing dependency, or crashed evaluator does not establish that the tested claim is false. It establishes that this run failed to answer the question.

Similarly, `unknown` means that the available evidence does not justify a classification. It is not an intermediate numeric truth value and should not silently become `false`.

## Unsupported direction is its own defect

An evaluator can move in the expected or desired direction while becoming less justified. For example, adding a skeptical source may make a model more pessimistic without giving it better evidence or reasoning. That result should not be counted as a substantive success merely because the sign changed in the desired direction.

This is why `evals/blackball/mocks.tsv` records effect, evidence status, and run status separately in addition to its headline result kind.

## Compiler-design consequence

Prefer a small number of reliable observations plus explicit competing diagnoses over a large catalogue of error strings that pretend to know causes the compiler cannot observe. When the compiler can distinguish more cases, preserve those distinctions as typed result variants instead of erasing them into a generic failure.

A system may therefore have many more error/unknown variants than success variants. That is not pathological; it is often a more faithful account of what the system actually knows.
