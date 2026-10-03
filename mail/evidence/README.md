# Host evidence

The [partial-read failure review](interruption-review/README.md) records the
later interruption-sweep changes and their separately hashed execution. The
results below describe the earlier sources listed in source-files.sha256.

These files describe acceptance-infrastructure execution, not a mail-stack pass.
The source SHA-256 list binds the C sources used to the build. Binary SHA-256
values bind measured executables. The host was Linux 6.18.44 x86_64 with Ubuntu
GCC 13.3.0. Builds used C17, optimization level 2, pedantic warnings and
warnings-as-errors, linked to host OpenSSL libcrypto.

- `mutations.tsv`: five good controls and 21 bad adapter modes, each rejected for
  its intended failure class.
- `exhaustive-matrix.tsv.gz`: actual results of 10,461 runs over 75 cases,
  including every two-chunk cut below 4096 bytes. This is fixture-replay and raw
  transport evidence. Zero mismatches does not erase 33 unresolved cases; exit 2.
- `differential.tsv`: all seven implementation registrations are NOT_RUN.
- `large-single.tsv`: 64 MiB single-message-shaped stream accepted by the bounded
  byte probe under a 32 MiB address-space cap.
- `large-buffer.tsv`: the same requested size/cap rejects whole-input retention.
  The producer stops early after allocation refusal (child exit 21, raw wait
  status 5376). Its digest covers a successfully produced prefix, not all
  requested bytes.
- `large-4g.tsv`: 4,294,967,423 bytes actually consumed under that cap.
- `large-offset32.tsv`: the same real stream with a truncated 32-bit count is
  rejected despite a matching payload digest.

Corpus regeneration matched byte-for-byte. Nine positive/negative metamorphic
relations passed audit. Seed 12648430 generated sixteen additional folded-header
cases; 728 normal partition runs produced zero mismatches and exit 2 for the
unchanged unresolved cases. Those cases are reproducible from the generator.

The existing AICI kernel self-test also passed all 58 cases.

An exploratory run omitted the replay-only corpus environment setting; all
adapters failed and the runner returned 1. Its corrected run is the recorded
exhaustive result. Replay environment variables must not be used to present a
real translation as accepted.

Physical acceptance, live local SSH, actual parser memory behavior and real
process-death ledger recovery were NOT_RUN. See OPEN_QUESTIONS.md.
