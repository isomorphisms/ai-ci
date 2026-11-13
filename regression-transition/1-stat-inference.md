# First checked attempt

Purpose: compare immutable case names against complete baseline/candidate
Vitest assertion results. Inputs are bounded reports and a three-column case
matrix; output is a digest-bound textual comparison. The verifier performs no
source execution, provider access, publication or trusted-admission promotion.

The canonical AICI validator interface is checked Ithon `.pi`; this extends
that interface rather than creating another execution language or runner.
Values are case IDs, scope names, assertion names and passed/failed states.
Central operation: `(matrix, baseline, candidate, scope) → decision`, with
filesystem reads and one fresh decision write. Missing, duplicate, skipped,
loader-failed and inconsistent evidence are rejecting states.

At Ithon d6e83969f82512e920fb17b44326cb54f31d015c, the first source check rejected
`selected.stat().st_size > LIMIT`: the foreign stat attribute lacked a static
numeric type. The current source explicitly reads and converts that attribute
to `int` before comparison. No fallback interpreter was used. The failed source
is retained as `1-stat-inference.pi`.

The next check also rejected an untyped empty-list default in the foreign
report access. The verifier now requires the external runner's explicit
`failureMessages` list rather than silently supplying one.
