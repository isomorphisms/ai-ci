# Cat Food bare-cloud acceptance

This gate treats Cat Food's README as an executable clean-machine contract.
The job starts in the pinned official Ubuntu 24.04 container and its first
`run` step is the README's first command block, beginning with
`apt-get update` and ending with `./provision.sh`.

The provisioner must return success and leave runnable artifacts for:

- Grease;
- Idriç;
- Ithon;
- Fieldmouse;
- IR;
- ICU; and
- IB.

`run-fixtures.sh` first requires the Cat Food-owned build outputs. It does not
silently build a missing ICU or IB artifact and then credit that work to Cat
Food. It subsequently runs the small programs under `fixtures/` and compares
their complete standard output byte-for-byte with the checked-in `.expected`
files.

The ICU fixture uses a loopback-only C HTTP server. It makes no external
request. The IB fixture imports the provisioned browser core and checks a small
ordered-history operation. The Grease fixture uses YSH `var` and `write`
syntax, so ordinary POSIX shell cannot satisfy it while pretending to be
Grease.

The scheduled run catches drift in Cat Food or any moving repository it feeds.
Pull-request runs prove changes to this acceptance gate against the exact
ai-ci commit under review.
