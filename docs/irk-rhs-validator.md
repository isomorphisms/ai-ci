# IRK should match the RHS validator

This is an intended equivalence, not a claim that the two implementations already agree.

Where IRK evaluates the semantics of a right-hand side, its verdict should match the authoritative RHS validator on the same normalized input. IRK should not quietly become a second, competing oracle with slightly different acceptance rules.

Practical consequence: feed the same cases through both paths and compare their normalized verdicts. Any disagreement should be treated as either an IRK bug, an RHS-validator bug, or an explicit specification gap that has to be resolved rather than averaged away.

Keep this separate from IRK's other checks. A matching RHS verdict does not by itself prove behavioral properties such as whether an argument actually influenced the result; nominal/structural signature checks and behavioral validation remain distinct.

For AICI evaluation, the useful invariant is therefore:

```text
normalized_IRK_RHS_verdict(case) == normalized_RHS_validator_verdict(case)
```

for every case inside the shared contract domain. Cases outside that shared domain should be reported explicitly rather than coerced into agreement.
