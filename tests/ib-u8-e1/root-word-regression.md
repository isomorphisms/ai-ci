# Root-word guard regression

The original manifest test added `android:sharedUserId`, so its expected
rejection exercised that attribute guard while leaving the independent
case-insensitive word guard untested. Its raw regular expression used doubled
backslashes and therefore searched for literal backslashes rather than word
boundaries.

The added `root-word-boundary` control preserves the required manifest fields,
changes its test-only declared byte digest, and exercises the lexical rule
without `sharedUserId`. It failed against the original verifier with
`AssertionError: root-word-boundary: expected ROOT_CREEP`. Correcting the
regular expression makes the control pass. This is a lexical policy check,
not proof of Android privileges, package acceptance or physical execution.
