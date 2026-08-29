# Co-evolution compatibility receipts

Idriç, Grease, compiler backends, bridges, and their consumers are deliberately
allowed to change together. This gate does not assume semantic-version ranges
or a single globally compatible "latest" stack. It records and verifies sparse,
observed compatibility tuples.

Each contract names one consumer revision, every language/runtime/backend
revision used to build it, the target, and the acceptance probes that define
success. Every revision is immutable. A receipt must repeat the exact tuple and
bind every `PASS` row to a nonempty witness by SHA-256.

The statuses are `PASS`, `FAIL`, and `NOT_VERIFIED`. Only a receipt in which all
required rows are `PASS` satisfies the gate. `NOT_VERIFIED` is intentionally
different from incompatibility: it means that exact tuple has not been proved.

This is a sparse observation ledger, not a Cartesian version matrix. A passing
row says nothing about a neighboring Idriç commit, another Grease revision, a
different backend, or another target. Consumers may advance several components
in one change, but the resulting receipt must preserve the complete tested
combination.

Name separately relevant pieces that share a repository revision—for example
`idric-core`, `idric-chez-backend`, and `idric-racket-backend`—when a consumer
does not exercise the whole tree. Backend coverage is never inferred from
compiler-revision coverage. Chez is currently the primary Idriç path; Racket is
an alternate path and must earn its own receipt. RefC/native C, Chicken, Android,
and other paths remain `NOT_VERIFIED` for a tuple until their own acceptance
probe runs.

## Contract format

The header is exact:

```text
kind	name	role	repository	revision	target	code
```

`component` rows use an HTTPS repository URL, a full lowercase 40- or 64-digit
revision, and one of these roles: `consumer`, `language`, `command-language`,
`backend`, `runtime`, `toolchain`, `bridge`, or `library`. Exactly one consumer,
at least one language, at least one backend, and at least one `probe` row are
required. Probe rows use role `acceptance` and `-` for repository and revision.
Names, targets, and diagnostic codes must be unique where the schema requires
them.

The example is intentionally structural. Its repeated hexadecimal revisions
are placeholders, not claims about a real tested stack.

## Receipt format

The header is exact:

```text
kind	name	status	role	repository	revision	target	code	witness	sha256
```

The receipt must contain exactly one row matching each contract row and no
extras. A `PASS` row requires a safe relative witness path below the supplied
root and its current SHA-256. `FAIL` also requires a hashed witness so an
observed incompatibility keeps its evidence. `NOT_VERIFIED` uses `-` for witness
and digest because no run occurred. Both emit their diagnostic code and make the
acceptance verifier exit nonzero.

## Use

```text
cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 -o /tmp/aici-compat src/aici_compat.c
/tmp/aici-compat verify ci/idric-stack.contract.tsv out/compat/receipt.tsv out/compat
```

Or pin this action by full ai-ci commit SHA:

```yaml
- uses: isomorphisms/ai-ci/compat@0123456789abcdef0123456789abcdef01234567
  with:
    contract: ci/idric-stack.contract.tsv
    receipt: out/compat/receipt.tsv
    root: out/compat
```

The receipt producer remains trusted executable policy. It must acquire each
declared revision, build through the declared backend, run the acceptance path
on the declared target, and write witnesses from those actual operations. This
verifier detects drift, missing evidence, replayed tuple members, and undeclared
rows; it cannot make a self-authored log independent evidence.

Literal `..` and final-component symlinks are rejected. As elsewhere in ai-ci,
contracts and receipt roots are trusted policy; this is not complete filesystem
confinement through a root containing intermediate symlinks.
