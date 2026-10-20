# NHTSA VIN independent CLI oracle

`nhtsa/vin-cli-acceptance.sh` checks the **installed Idriç executable**,
not merely a source parser or README. Call it from Flexible Pipes after
Kitchen's source-pinned build and installation with the absolute installed
program path, CLI checkout root and expected exact Git commit.

The oracle authors synthetic vPIC JSON independently of the implementation
fixtures. It asserts correct VIN identity, optional field states (present
empty vs absent), model year, NHTSA warning code, exact request URL and
fixture provenance. Its wrong-VIN, wrong-type, duplicate-result,
missing-error, invalid-character and input-path mutants must all fail with
no data rows. A fake success exit or silent null coercion is a failure.

This is **not** evidence of a live NHTSA response, correct TLS transport,
physical Android execution or a correctly calculated VIN check digit.
Those are distinct receipts. The accepted CLI source identity must match
the test invocation; an ancestor's green result does not count.
