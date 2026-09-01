# Idriç moving-head dependency audit

This audit separates active dependency selection from exact evidence. Active
Idriç ecosystem lanes select declared branches and record the SHA resolved for
the run. Exact historical tuples remain exact.

## Active dependency pins converted

| Location | Previous selector | Classification | Moving selector |
| --- | --- | --- | --- |
| `idric-x86-aggressive-backend` checked ELF64 workflow, revision file, and integration guard | Idric `dd313277fedb2b678ff0df6769ed1330a2e80523` | `ACTIVE_DEPENDENCY_PIN` | Idric `Idriç` |
| `idric-arm-thumb` DEX workflow and `IDRIC_REVISION` guard | Idric `081b9cde0591154839fb5d80d76e5570e0436300` | `ACTIVE_DEPENDENCY_PIN` | Idric `Idriç` |
| `Idric-Net` ordinary CI | Idric `47557b43053c829d4f8aa1581007002b57f9c59f` | `ACTIVE_DEPENDENCY_PIN` | Idric `Idriç` |
| Algebraic Variety Explorer shader dogfood | shader backend `66214e3da0443fe4887062549e9ef5810c586dd7` | `ACTIVE_DEPENDENCY_PIN` | `soap-f16-mode` |

The x86 and DEX exact tuples remain in their historical documentation. The
moving lanes do not fall back to them.

The SMS workflow already selected `sms-server-foundation` and
`sms-server-filesystem-foundation`. Its selection was correct but its evidence
was incomplete, so the runner now records Idriç, Idric-Net, Grease, and AICI
requested refs, resolved SHAs, clean/dirty state, ordered stages, and the first
failure. Later stages are `SKIP` after a failed prerequisite.

## Exact revisions deliberately preserved

| Exact use | Classification | Reason |
| --- | --- | --- |
| x86 first-green compiler/backend tuple in baseline documentation | `HISTORICAL_EVIDENCE` | Records what first completed the direct compiler→ELF64 path. |
| DEX first-green compiler/backend/artifact tuple in DEX audit and PR evidence | `HISTORICAL_EVIDENCE` | Records the software that produced and executed the first `classes.dex`. |
| `idric/matrix-v1.tsv` exact project/compiler/backend rows | `HISTORICAL_EVIDENCE` | Survey observations and workflow receipts, not checkout selectors. |
| AICI bounded R128 contract receipt | `REPRODUCTION_FIXTURE` | Intentionally frozen semantic regression; it does not define active x86 selection. |
| ARM/Thumb and shader follower checkpoint files | `HISTORICAL_EVIDENCE` | Reviewed adoption points compared with moving branch heads. |
| Idriç higher-mathematics reconciliation commit references | `HISTORICAL_EVIDENCE` | Provenance only. |
| GitHub action SHAs, Chez archive digest, Idris 2 release tag, XED/mbuild revisions, smali/baksmali jars | `EXTERNAL_TOOLCHAIN_PIN` | Supply-chain or independent-validator reproducibility. |
| Grease Oils source submodule revision | `EXTERNAL_TOOLCHAIN_PIN` | Grease implementation source snapshot, not an Idriç/compiler compatibility selector. |
| `Idric-Net`'s exact AICI action revision | `EXTERNAL_TOOLCHAIN_PIN` | Pins the verifier implementation; the compiler checkout now moves independently. |

No inspected exact revision remained `UNKNOWN` after tracing its use.

## Current declared refs

`idric/current-heads-v1.tsv` is the small explicit branch manifest. The resolver
proves that each declared branch exists and writes its current SHA. That receipt
is selection evidence only: compatibility is owned by the x86, DEX, Idric-Net,
SMS, and shader-consumer executable lanes named in the manifest.

`isomorphisms/idris-shader-backend` itself has no active Idriç compiler
selector: its present compiler API lane is upstream Idris 2. The active moving
shader seam audited here is the algebraic-surface consumer of
`soap-f16-mode`.
