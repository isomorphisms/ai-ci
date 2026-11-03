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

Parsing/execution: PENDING. Live Google, actual ART and physical execution:
NOT_RUN. A positive classifier exit does not establish any of those stages.
