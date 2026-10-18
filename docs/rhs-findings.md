# RHS evidence admission

RHS emits immutable source, claim, observation, scope and hash records, with separate exact and model finding types. The `rhs-finding-v1` scalar TSV schema is closed. An RHS success flag is not an accepted field.

`validators/rhs_findings.pi` admits a record only against independently supplied capture identities and an independently computed judgment. It rejects missing/extra fields, source or hash mismatches, invalid/expired validity intervals, unsupported evidence tags and promotion of model estimates. A digest establishes byte integrity; it does not authenticate an author's claim of execution. The caller must provide independent capture, not a copy of the producer's fields.

`validators/accept_rhs_native.pi` is the executable native boundary. It reads committed RHS source, verifies the ICK owner revision, recompiles at O0/O2, recaptures every positive and deliberate bad case, compares raw streams and invocation evidence, independently computes the relations, admits valid records and rejects forged verdicts with unchanged hashes. It retains both claimed and independently compiled binary hashes; equality of the observed executions is the required semantic witness, not a claim of universal source correctness or physical-device execution.

The independent checker uses rational arithmetic and Gaussian elimination for transformation judgments. RHS uses integer cross multiplication and cofactor determinant expansion. Count, call, carrier and serialization laws are independently specified. A 2×3 array has rank two and six stored coordinates; explicit flat encoding gives one point in ℝ⁶, while explicit row encoding gives two points in ℝ³. A variable name cannot choose that meaning.

The same independent checker supports the original sixteen declared relations. `test_rhs_baseline.pi` recomputes all 104 retained findings without reading grading labels. Unsupported claims remain UNKNOWN. A model receipt can establish recorded inference provenance; it cannot establish mathematical or behavioral correctness.

Unit receipt fixtures are explicitly fixture-scoped. Actual native positive/negative integration comes from the RHS hosted source-bound pipeline. Source-check success alone does not establish that integration.
