# Native first-party Google continuation diagnostic

The original fb9 Google responses independently verify on both APIs in
run41330407387. libxml2 observes a zero-delay meta refresh and actual href to
/httpservice/retry/enablejs, another /search retry link and Google support.
The native body contains the Please click here redirect placeholder. No
public search result exists in the observed extracted view. API29 original
SHA256 c7d46a8e318bc325aa308997932a0503269ce1eea5f33b202e00bc5a3af6b36c;
API34 original SHA25629f1488fde6badf5795ebf8b8082bf88580b024ff45ae6cd3cf34cfbef7a8996.

The new independent SDK phase recognizes that exact native placeholder,
chooses only its actual HTTPS first-party enablejs link from the checked
projection, and injects genuine down/up events. It never executes scripts,
changes the Google URL constructor, invokes a candidate navigation method,
opens another browser or substitutes network transport. A normal response
without that placeholder keeps the original stronger public-result path.

After a continuation touch, Grease independently proves href membership in
the committed original, captures the real response, and uses an explicit new
raw-response profile in the existing byte verifier. That profile supports
only this first-party URL, HTTP200, zero observed redirects, unchanged final
URL, supported declared charset, independently valid UTF8, exact framing,
private committed bounds and digest. Ordinary UTF8 raw admissionYES is kept
distinct from legacy raw admissionNO. Original legacy/literal profiles retain
their exact assertions. A changed committed byte must fail its SHA assertion.
Unsupported observations refuse rather than being manufactured.

This continuation is diagnostic: its receipt says results/click NOT_RUN and
the enclosing stronger search test remains FAIL until a real public result
is independently qualified. If Google returns static results, that new
source and its public href/history must be integrated into the strong proof.
If it requires JavaScript, this is an explicit service limitation. A passing
caller, href or original-byte check is never search success.

Types: original source/metadata, actual touched URI, new acquisition identity
and displayed text stay separate. Status at authoring: continuation outcome
NOT_RUN. Physical TAB_P10 remains BLOCKED. No release or merge.
