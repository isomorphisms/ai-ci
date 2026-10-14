# Wave 2 scope and collection

Collection date: 2026-10-14 UTC. Parent campaign: https://github.com/isomorphisms/ai-ci/issues/239.

## Current core inventory

The supported GitHub all-state issue collection was paginated to the final short page for each public core repository. Pull requests were separated using the pull_request field; each repository/number is unique. The nine returned pages enumerate 588 records: 254 issues and 334 PRs.

| Repository | Page sizes | Issues | PRs | Open issues | Open PRs |
| --- | --- | ---: | ---: | ---: | ---: |
| isomorphisms/ai-ci | 100 + 100 + 67 | 113 | 154 | 102 | 23 |
| isomorphisms/catfood | 100 + 37 | 33 | 104 | 31 | 9 |
| isomorphisms/kitchen | 54 | 21 | 33 | 20 | 7 |
| isomorphisms/flexible-pipes | 100 + 30 | 87 | 43 | 86 | 16 |
| Total | 9 pages | 254 | 334 | 239 | 55 |

[Enumerated records](core-inventory.tsv) retain kind, number, state, title, URL and update time. Enumeration does not establish a defect or full source/discussion review. Domain coverage records identify inspected bodies, comments, branches, source and evidence limits. Concurrent activity can change state during collection; this is not an atomic snapshot. Closed PR state alone does not establish retained branch behavior or integration.

The original October 12 account-wide inventory (1,052 open issues and 213 open PRs across 13 searchable namespaces) remains a dated observation in ../SOURCES.md. This wave does not refresh that larger denominator or resolve the earlier ib-pensieve access gap. Private repository identities and private conversation dumps are excluded.

## Continuity

The original complete request and 33 STAR packets are preserved on the campaign branch. Its first wave records 26 complete SUN bodies and six requalified domains. This continuation investigates the other 27 domains against current owner work, preserves completed repairs and existing named jobs, and assigns only uncovered implementation/acceptance. Source observation, historical report, currently observed CI and independently executed evidence remain separate.

The new main revisions and candidate changes discovered during this continuation supersede stale assumptions only for the boundaries they actually establish. Each job refreshes mutable state before acting; historical receipts are retained without granting current admission.

The fresh existing Kitchen source-handoff suite ran on exact main 5a00f0c498c93a6bcacbfc41ccbd320e5a1d2b16, Ubuntu24.04.3 x86_64: 27/27 passed. This is an existing bounded source seam, not newly implemented SUN acceptance. Domain source-coverage records preserve exact inspected refs and complete supported discussion counts; overlapping domains must not be summed as distinct sources. Temporary raw caches are not included in this publication.
