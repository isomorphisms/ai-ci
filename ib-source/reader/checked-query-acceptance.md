# Native checked query validation acceptance

The reader-v5 profile invokes the actual maintained Activity's exported
checked_search_query, shared with its receiver after caller authorization.
It returns a URL/refusal only and cannot grant acquisition. Literal SDK/ART
inputs cover null, empty, whitespace, controls, malformed UTF-16, supplementary
Unicode, plus/percent input, unchanged unreserved bytes, the 1024-unit boundary
and complete encoded URL length. The source compiler creates two independent
mutants: a raised query limit and a removed Unicode validity guard. They must
fail their designated assertions with status137, not a verifier crash.

This is a real SDK query-boundary check on ART. It does not authenticate an
external Activity caller, observe ChordReader dispatch, or qualify Google
acquisition, consent/challenge handling, results or clicked navigation. Those
remain separate installed acceptance. Smali builds only the observer. Candidate
and mutants remain checked Idriç compiled by the maintained DEX backend.
