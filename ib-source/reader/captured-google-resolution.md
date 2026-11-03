# Resolve retained browser result links through ICU

The API29 WebView74 observation in IB run41576410427 retains29 read-only
DOM snapshots. Its last snapshot contains nine titled anchors. The first
entries have Google `/url` hrefs whose `q` values are opaque tokens, not public
URLs. The original-body classifier refuses them as public destinations. Its
fallback JAVASCRIPT_REQUIRED marker also occurs in this rendered document;
that marker alone does not prove the browser failed to execute the frontend.

Artifact13205098103,6376358 bytes, has independently verified ZIP SHA256
8d1622bb15c56d488aefb3997dc2d6b48a07f0f0ba37e8f6f8629ca1721c8473.
No original browser HTTP body, status or original byte offsets are inferred
from its DOM serialization. API34's separate27217045-byte artifact13205360182
has SHA256391921c78895ab594842b4957cf403f57fcb3d5e8b32007dce8b65477186b0d6;
that lane failed its required terminal receipt rather than qualifying a
completed observation. Both exact artifacts remain diagnostic inputs.

`resolve-captured-google-link.grease` independently reads the frozen original
DOM with xmllint, retains each selected title/href and follows three actual
Google result hrefs through the maintained checked ICU4f365 command. It does
not decode opaque tokens or invent their targets. Each request/response,
original body digest, observed redirect chain, resolved URL, length and MIME
remain private bounded evidence. A public HTTPS200 HTML destination counts
only after the observed final URL passes independent public-origin checks.
Characterization cannot qualify native UI, actual touch or a complete IB
transaction. Browser assistance remains explicit even if ICU resolves the
captured result redirects.

The type boundary is `retained DOM → exact titled href → ICU observations`.
Parser and OS coordination use Grease; the same checked ICU client and C TLS
provider acquire responses. No new HTTP implementation, challenge answer,
cookie extraction, unsupported API or alternate provider is introduced.
