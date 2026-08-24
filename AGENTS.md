# Completion contract

Do not infer completion from a green workflow, a successful build step, or the existence of an artifact.

Before claiming that work is complete, identify:

1. the exact commit tested;
2. the exact command argv that ran;
3. the execution environment;
4. the acceptance invariant established;
5. the final artifact path and SHA-256, when the claim concerns an artifact.

Use exactly `PASS`, `FAIL`, or `NOT VERIFIED`.

- Missing, skipped, blocked, cancelled, stale, malformed, and ambiguous evidence is `NOT VERIFIED`.
- A check that ran against the expected commit and observed a violated invariant is `FAIL`.
- `PASS` is permitted only when every required report is current and every required artifact still has the tested digest.

Never convert `NOT VERIFIED` into `PASS` because another job succeeded. Never weaken a required check merely to make a workflow green.

When a defect escapes green CI, update `failures/escaped-defects.json` with the failure, the missing invariant, a regression fixture, and whether the enforcement belongs here or in the project. Add the executable regression before closing the defect when practical.
