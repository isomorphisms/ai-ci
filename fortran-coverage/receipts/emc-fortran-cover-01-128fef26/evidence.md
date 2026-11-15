# Recheck after the separately authored main merge

Current tested leaf: 128fef263752f2c74dee87a7e8fb5475c6d8bbda.
Independent oracle source remains a58c37e913d6866f7fd5737a91e3f68649810a03.
This leaf is a separately authored merge of b41dd204 and current main.
The inventory tables, generator, attributes and one-off workflow are byte-identical
to b41dd204. The external merge was preserved, not overwritten.

Both exact clean local checkouts passed 45-file regeneration and independent
raw-source/readelf acceptance. All 17 targeted negatives were rejected again.
The acceptance receipt binds the new leaf, tested oracle and all 27 table digests.
Semantic acceptance is UNVERIFIED; whole-language and library closure are UNKNOWN.

[Hosted exact-head inventory run 39131084421](https://github.com/dilapidated-shed/English-major-C/actions/runs/39131084421)
also passed. Inventory job 117686216726 logs show this exact leaf and oracle
checkout, complete regeneration and all 17 rejected mutants.
[Receipt artifact 12137663911](https://github.com/dilapidated-shed/English-major-C/actions/runs/39131084421/artifacts/12137663911)
has ZIP SHA-256 967188644d08f30545947dac701692668c0d3e42f3426877bfbd9e2405e96f60.

The earlier missing-flat-path failures belong to b41dd204 and remain historical.
The external main merge restored those paths. Existing QR execution workflows
also ran on that merge; the inventory generator/oracle did not invoke them.

The current legacy callee job's actual execution comparison passed. Its
[run 39131084316](https://github.com/dilapidated-shed/English-major-C/actions/runs/39131084316)
failed later during artifact upload: the canonical source filename
What is the execution index? contains a question mark unsupported by the upload
action's loose-file packaging. This is a receipt-packaging failure, not evidence
that its separately completed callee execution failed. The source filename must
not be silently renamed. A bounded repair can archive the source before upload
while retaining exact member names and hashes; it need not extend the interpreter
or turn this inventory into another QR execution job.

No all-CI-green, semantic-completeness, merge-readiness or policy-promotion claim
is made. This evidence supersedes the previous exact-head receipt for current-head
claims without deleting the previous observations.
