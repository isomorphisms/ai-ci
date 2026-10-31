# BC-A02 source coverage — 2026-10-13

## Scope and counts
- Authoritative packet and full campaign REQUEST read at docs/build-campaign-01-20261012, coordinator-confirmed commit `c28ae588ec9699a374ecd59c5392691623b78a51`.
- Four issue bodies read: [AICI 171](https://github.com/isomorphisms/ai-ci/issues/171), [AICI 183](https://github.com/isomorphisms/ai-ci/issues/183), [AICI 169](https://github.com/isomorphisms/ai-ci/issues/169), [FP 69](https://github.com/isomorphisms/flexible-pipes/issues/69). All four issue-171 comments read; issue-169 comments empty. This is bounded domain review, not account-wide issue discovery.
- Seven PR records refreshed: AICI 247, 254, 240, 231, 256; Holomorphic 65; FP 31. Source inspection covered AICI 247/254/240 and retained FP31 material; other PR bodies/refs are reuse or exclusion evidence, not independent acceptance. Full PR titles and relevant links below.
- Complete bounded PR searches returned 6 ingestion matches and 26 oracle matches, 29 unique results, both incomplete_results=false. Searches are leads, not 29 reviewed implementations. Changed-file lists for AICI 247 and 254 were complete; AICI 240 was refetched with per_page=100 before collision inspection.
- Four source trees inspected: AICI main and oracle candidate, FP main and retained branch, plus refreshed relevant files. Tree presence is source discovery, not code execution.
- 37 textual source snapshots retained below. The 25 evaluation manifest rows and M01–M26 audit corpus are distinct populations.
- Four SUN jobs authored, each has all twelve fields and END marker. Counts: S01 481 words, S02 481, S03 508, S04 512. No domain remote writes or product executions occurred.

## Exact identities
| Source | Observed ref | Review |
|---|---|---|
| AICI main | 3d174000649f9f828c29e6be981cfd0e60646014 | Main tree and ingestion verifier |
| AICI oracle candidate | 53b705630d1816f2f43659d0a9cd4241bc734734 | Required docs, manifests, actual runner/oracle/checker/mutations/workflow |
| AICI migrated verifier | c400e73ff6ec4d61177a51c8d704eedf718521e8 | Complete relevant changed paths and ingestion code; same unresolved verifier mechanisms |
| AICI Sublixel candidate | f3cc0b094f90d4fb817384426e09139e570bbd62 | README, accept.sh and exact receipt checker; BC-T01 ownership |
| AICI qualified producers | f6d825d15cd3c0c34ae1b43240a463ff5d343090 | PR body/ref reuse lead; producer artifacts not independently qualified here |
| AICI Fulton candidate | dfb14ccd651fc31545e0dc9d47463de6141a77f5 | PR body/ref exclusion; separate bounded geometry owner |
| Holomorphic main / witness | ce9d15e1c5cb2363201a61bbaa8eb10750ea1268 / 7041b262c553e295b9769ebb84b7cb626e2ce50e | Live ref/body; preserved independent witness source in AICI |
| FP main | def2a66fe61a2b23440f98031f1defa738a0d1ee | Pipeline docs, legacy runner and RHS consumer |
| FP retained FP2 branch | 442a33bfd36a23df3d757d17a31b8084cab21a38 | Registry, checked controller/worker and qualification requirements |

## PR identity index
- [isomorphisms/ai-ci PR #247, “SUN T1: independently reject Holomorphic polynomial mutants with AICI reference”](https://github.com/isomorphisms/ai-ci/pull/247).
- [isomorphismes/holomorphic PR #65, “SUN T1: prove CPU polynomial mutants survive worker smoke but fail semantic oracle”](https://github.com/isomorphismes/holomorphic/pull/65).
- [isomorphisms/flexible-pipes PR #31, “Implement registered Kitchen script execution and preserve FP2 qualification attempts”](https://github.com/isomorphisms/flexible-pipes/pull/31).
- [isomorphisms/ai-ci PR #254, “Independent 3×3/5×5 Sublixel ICK/Ike numerical and receipt acceptance”](https://github.com/isomorphisms/ai-ci/pull/254).
- [isomorphisms/ai-ci PR #240, “Complete the ÷ census and migrate audit verifiers through ICK”](https://github.com/isomorphisms/ai-ci/pull/240).
- [isomorphisms/ai-ci PR #231, “Guard owned C and qualify pinned ICK native and Android producers”](https://github.com/isomorphisms/ai-ci/pull/231).
- [isomorphisms/ai-ci PR #256, “Independently check bounded Fulton CNC geometry and false records”](https://github.com/isomorphisms/ai-ci/pull/256).

## Evidence limits and recovery notes
Shared AGENTS plus README, failure ledger, research failure-mode and harness notes were read. No FP-local AGENTS appears in inspected trees. A guessed ingestion/verify.sh path was unavailable; canonical ingestion/src/aici_ingestion.c was recovered and inspected instead. Scratch checkout directories were empty/non-Git and were not trusted as source.

AICI run 38085581838 job/step metadata and artifact 11682506343 availability/digest were refreshed; all 21 returned exact-head push/PR workflow records were enumerated. The text-only connector did not supply binary archive bytes. Reported historical counts are supported by source and successful named step metadata, not an independent rerun or downloaded-log analysis. This review recovered no original private conversations beyond the coordinator-supplied campaign packet; issue/doctrine records remain records, not verbatim transcripts.

Existing repaired or separately owned work is retained: Holomorphic initial oracle, Sublixel oracle/receipt path, current ICK source migrations, and retained FP client/controller repairs. No generic generator cause is declared proven. No runtime/device/GPU/deployment or broader fleet correctness is inferred.

## Cached text sources
- `sources/agents.md`
- `sources/aici/.github/workflows/self-test.yml`
- `sources/aici/README.md`
- `sources/aici/contracts/evaluation-case-v0.contract.tsv`
- `sources/aici/docs/evaluation-protocol.md`
- `sources/aici/docs/failure-ledger.md`
- `sources/aici/docs/harness-engineering.md`
- `sources/aici/docs/irk-rhs-validator.md`
- `sources/aici/evals/README.md`
- `sources/aici/evals/cases.tsv`
- `sources/aici/incidents/2026-10-holomorphic-generated-test-proxy/README.md`
- `sources/aici/ingestion/README.md`
- `sources/aici/ingestion/src/aici_ingestion-migrated.c`
- `sources/aici/ingestion/src/aici_ingestion.c`
- `sources/aici/research/llm-failure-modes.md`
- `sources/aici/tests/cases.tsv`
- `sources/aici/tests/semantic-oracles/holomorphic-t1/cases.tsv`
- `sources/aici/tests/semantic-oracles/holomorphic-t1/independent_reference.c`
- `sources/aici/tests/semantic-oracles/holomorphic-t1/receipt_meta_tests.sh`
- `sources/aici/tests/semantic-oracles/holomorphic-t1/run.sh`
- `sources/aici/validators/verify_semantic_mutants.sh`
- `sources/fp/README.md`
- `sources/fp/docs/pipeline-contract.md`
- `sources/fp/docs/registered-execution-v1.md`
- `sources/fp/docs/rhs-behavior-evaluation.md`
- `sources/fp/pipelines/rhs-behavior-evaluation.json`
- `sources/fp/scripts/rhs-behavior-evaluation.ysh`
- `sources/fp/scripts/run-pipeline`
- `sources/packet.md`
- `sources/request.md`
- `sources/retained/registry/kitchen-transfer-script.contract.json`
- `sources/retained/scripts/registered-execution.pi`
- `sources/retained/scripts/registered-worker.pi`
- `sources/retained/tests/registered-execution/requirements.md`
- `sources/sublixel/README.md`
- `sources/sublixel/accept.sh`
- `sources/sublixel/receipt_check.c`

## Final record
Four jobs are fully authored; visible delivery, filing and dispatch counts are left to the coordinator's actual results. S01 source implementation can begin; final execution waits for qualified material. S02–S04 are exact-prerequisite conditional. Controller order is BC-T01-S01 → BC-P02-S05 → BC-A06-S04 → BC-A02-S04. No domain-level implementation was performed.

