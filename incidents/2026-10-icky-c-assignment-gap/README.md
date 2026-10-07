# Hidden Icky C assignment gap — 2026-10-07

Discovery context: FastChat FC-D1/FC-S1; dated in America/Detroit.
Follow-up owner: [ai-ci issue #217, “Regression: preserve functorial ICKY C instead of falling back to generic C/game idioms”](https://github.com/isomorphisms/ai-ci/issues/217).
Compiler repair: [dilapidated-shed/ick PR #77, “Accept ← assignment in the Icky C frontend”](https://github.com/dilapidated-shed/ick/pull/77).
[Exact compiler receipt](https://github.com/dilapidated-shed/ick/blob/326366fffbbcaa8b23fa0abe4f58d1c2b3c07420/qualification/c-assignment-arrow/receipt.tsv).

The user reports that the expected assignment notation had gone unverified for
a long time and may have affected work across hundreds of repositories. The
specific concern includes existing C files written with ordinary `=` where
Icky `←` was intended. Record this as a systemic audit obligation, rather
than treating the discovery as an isolated FastChat spelling mistake.

The earliest bad revision, start date, affected-file count and downstream
consequences are **UNKNOWN**. No account-wide C-source audit has been executed.
The concern applies to every maintained C file as an audit candidate; it does
not establish that every file or program is defective.

## Demonstrated failure and repair

- ICK main snapshot `e3c2a40b4edafc4d9caca55d1f7c094e6aab9589` had no C assignment-arrow support.
  The source-built compiler at `7afb1820cd59c0c51d19a7e37902c14f4466f442`
  had the same owned compiler source layer and rejected the exact FastChat
  probe. The ordinary-assignment control passed.
- libcpp already preserved U+2190 as one UTF-8 token. The C frontend rejected
  it as an unknown character. This was a real frontend gap, rather than
  evidence that the user had chosen the wrong assignment spelling.
- Compiler source `2a27ad6ab4e4601c9a0e4a5fa7915712db707af0` maps the glyph after preprocessing.
  The unchanged probe compiles; the executable semantic fixture passes under
  Linux/AArch64 QEMU; invalid destinations remain rejected.
- The source fix does not prove that an installed compiler was updated, that
  existing C files follow the requested style, or that downstream artifacts
  were rebuilt. It supplies no physical MIRO A1 execution evidence.

## Possible downstream effects to investigate

| Case | Evidence now | Required review |
| --- | --- | --- |
| Intended `←` rejected by the selected compiler | Confirmed for the FastChat probe | Find other failing or blocked consumers and their exact compiler pins |
| Ordinary `=` silently substituted in first-party Icky C | User-identified risk; file-by-file audit not run | Compare assignments and initializers with the governing source/style intent |
| Stock compiler, NDK, alternate language or notation rewrite hid the gap | Not established by this incident | Recover the actual build path, declarations and artifact provenance |
| “Icky C accepted” claimed from generic C tests or source presence | Audit risk | Recheck the literal requested syntax through the actual selected executable |
| Other requested Icky symbols unsupported | UNKNOWN | Use separate symbol/semantics probes; do not infer coverage from `←` |

## Audit scope and closure

Inventory every maintained `.c` file across accessible current repositories and
active branches, together with C in headers, generators and templates that feed
those files. Record coverage limits, repository revision, path, source role,
declared profile, assignment spelling, actual compiler/frontend identity,
target, diagnostic and resulting artifact/receipt. Review historical claims
and blocked attempts where provenance links them to an affected revision.

Classify first-party Icky source, first-party ordinary-C boundaries, compiler
bootstrap/substrate, generated source and foreign/vendored C explicitly.
Ordinary `=` may have normal C semantics while violating the intended first-party
notation. It is an audit finding to assess against intent, not proof by itself
of runtime corruption.

Use syntax-aware inspection: distinguish assignment and initialization from
comparison, macro text, strings and comments. Preserve pointer/dereference
`*` and member `->` syntax. A global character replacement would damage code
and cannot serve as this audit.

Keep all unaudited files/consumers **NOT_VERIFIED** for assignment-profile
compliance. Repair confirmed findings in their owners, qualify the exact
consumer compiler and rerun material checks. Retain failures and explicit
approved boundaries. Do not close the cross-repository obligation merely
because the compiler repair passes.

## Ownership

- ICK owns glyph semantics, lexer/parser implementation and compiler fixtures.
- ai-ci owns source/profile enforcement, evidence rules and the defect-class
  audit in issue #217; this note records an obligation, not an implemented gate.
- Flexible Pipes owns repeatable execution and requested-symbol/toolchain
  preflight through [issue #9](https://github.com/isomorphisms/flexible-pipes/issues/9)
  and [issue #22](https://github.com/isomorphisms/flexible-pipes/issues/22).
- Cat Food owns exact compiler/artifact pins and target/deployment matrix
  reconciliation through [issue #89](https://github.com/isomorphisms/catfood/issues/89).
  Hardware facts stay in Cat Food.
