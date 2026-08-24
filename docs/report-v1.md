# Evidence and gate report version 1

Version 1 uses one project-owned contract, one JSON evidence report per executed check, and one aggregate gate report.

## Evidence report

A `PASS` or `FAIL` report must contain:

- `schema_version`: `1`;
- `check`: the contract's exact check name;
- `status`: `PASS` or `FAIL`;
- `commit`: a full 40-character Git SHA;
- `command`: the exact nonempty argv array that ran;
- `environment`: a concrete description of where it ran;
- `observed_at`: an RFC 3339 timestamp;
- `reason`: a short observed result.

When the contract requires an artifact, `PASS` also needs a repository-relative path and SHA-256. The gate recalculates that digest. A report cannot confer `PASS` on bytes that have since changed.

An evidence producer may write `NOT VERIFIED` with a reason when it cannot start or observe the intended check. Runner conclusions such as `skipped`, `blocked`, and `cancelled` are deliberately normalized to `NOT VERIFIED` by the gate.

## Aggregate precedence

The aggregate is:

1. `FAIL` if at least one current required check actually ran and failed;
2. otherwise `NOT VERIFIED` if at least one requirement lacks valid current evidence;
3. otherwise `PASS`.

This precedence preserves a concrete failure without pretending that other missing checks were verified.

## Trust boundary

The gate establishes consistency among the expected commit, evidence reports, and current local artifact bytes. It does not infer that a named command tested the right semantic property. Each check implementation must establish its own invariant. That is why the escaped-defect ledger distinguishes the implemented gate from planned Android, language-ownership, provenance, and scene-semantic checks.
