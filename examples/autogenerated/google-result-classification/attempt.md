# Independent Google result classification

This is orchestration of the established independent libxml2 HTML parser, not
an IB parser or a network client. The input is a bounded retained original
Google body. The output distinguishes a titled destination candidate from
consent, verification, script-only content and arbitrary navigation anchors.
It emits a private TSV of title, actual destination and original href.

The original body hash and parser identity bind the observation. Google `/url`
wrappers may be decoded once; malformed escapes, controls, local/non-HTTP
destinations and Google service links are refused. No source byte offsets are
invented: XPath occurrences are independent semantic observations, not Arena
coordinates. Later end-to-end acceptance must still touch a candidate and
independently verify the destination acquisition.

The result budget is 64 titled anchors, 4 MiB input and 2048-byte URLs. Positive
and targeted negative fixtures exercise the observer without passing fixtures
off as live search results. Idriç application semantics stay in IB. No fallback
program or backend is introduced by this shell orchestration.

The first local execution exposed Grease's strict-errexit rule: pipelines in
command conditions are not permitted. The failing attempt was preserved in the
initial commit. The repair makes each condition read a bounded file and uses
`try` for an intentionally refusing procedure. Three positive cases and twelve
targeted semantic refusals now execute successfully with Grease source
5651cf97a1b5042f24f14112a7ade9a1518eb0bc, packaging
6d19932f7a63faf38444bd3693aa61304f061fda, original artifact13062637698
SHA256 fb500602a8ad878913e596f734c37769a5c7f3d2ac6941ee69ce22e31f479a19,
and Ubuntu libxml2 2.9.14. The retained original 93,166-byte Google response is
correctly refused as JAVASCRIPT_REQUIRED. This is historical capture analysis,
not a new network transaction. Live Google, actual ART and physical execution
remain NOT_RUN. A positive classifier exit does not establish those stages.

The independent checked IB observer uses a different public destination and a
supplementary-Unicode query. It checks title, once-decoded destination, source
generation/digest and stable recovered-anchor identity. Three source mutants
must compile and then fail the exact semantic assertion: accepting untitled
anchors, accepting first-party retry links, or changing the result generation.
These are host checked-Idriç controls, not ART or live-search claims. Their
execution is PENDING until the producer consumes this immutable observer pin.

After the producer introduces counted, scoped result headings, the old
heading_seen mutation correctly fails closed as an unchanged control at
IB1739bf91/source run41625651486. Its replacement disables both actual
barriers needed to admit an arbitrary anchor: heading eligibility and
heading-scoped character collection. It compiles and fails the unchanged
independent arbitrary-anchor semantic assertion. The public-host and source
generation controls remain unchanged. google-classifier-complete-heading-controls-1
passes eleven positives and rejects all three compiled controls at their
designated assertion. Host qualification is not live Google or ART.
