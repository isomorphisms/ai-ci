# Exact-head finite CMOV claim receipts

[dilapidated-shed/English-major-C PR #17, “Account for linked ARM ledgers and bound x86 semantic claims”](https://github.com/dilapidated-shed/English-major-C/pull/17).

Leaf: `1f6717213d1a2eaefe607b42556c6b5cdc83849e`.
Oracle source: `d0954543e1d95d8ad5c20f39bec98279acbd61c0`.
Intel source: `48741fad8f9cd646450c6f98ae945ff55acbd558`,
CMOVcc blob `72a27b29b4e5287f03ca83155964c8e501bb49eb`.

Local clean-head receipts bind all three independent checks. The new check
accounts for eight CMOV occurrences/four encodings, 256 flag assignments and
768 modeled transitions; eleven corruptions are rejected. The original 17
inventory corruptions and 21 ARM-ledger corruptions remain rejected, with the
separate unavailable-source case explicitly reported missing. The frozen 45
inventory files and six ARM-ledger files regenerate unchanged.

[Hosted run 39224724758](https://github.com/dilapidated-shed/English-major-C/actions/runs/39224724758)
passed all audit steps. Verbatim job 117968121916 logs are retained in hosted.log,
including checkout witnesses for the exact leaf, oracle and Intel commits.
The local model-cases.tsv is explicitly modeled primary-rule output, not a CPU
trace; its digest is bound by cmov.tsv. Local receipts are separate from runner
receipts, which are available in the hosted artifact.

[Hosted artifact 12173456512](https://github.com/dilapidated-shed/English-major-C/actions/runs/39224724758/artifacts/12173456512).
Name: `fortran-structural-acceptance-1f6717213d1a2eaefe607b42556c6b5cdc83849e`.
ZIP SHA-256: `cbf19489e1ae150fc16638e8126b912ff3cb0432ef9cc2374bb434726de44d00`.

Acceptance is finite claim consistency plus structural inventory accounting.
No original specimen or QR interpreter is invoked by these checks. Other
inherited workflows remain separate evidence. Complete effects for all 1,542
forms, the remaining 117 historical partial descriptions, library/process
closure and whole-Fortran coverage are unverified or unknown. No merge or
whole-state semantic promotion is implied.
