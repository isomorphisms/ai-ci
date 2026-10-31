# Independent checked-reader ART expectations

These observers call IB's actual compiled source exports. They do not generate
the candidate DEX, parse HTML for the candidate, or simulate a Binder/ICU
transaction. `fixture.html` is deliberately synthetic source; its observation
fields identify the same exact bytes. No network authenticity is claimed.

The source projection observer checks Unicode titles, semantic content order,
relative-link resolution, exact Prepaint wire and source-code-point ranges.
The selected paragraph separates the two declared reflow algorithms at width
10 code points: greedy chooses `[0,11), [11,15)`, while squared-raggedness
chooses `[0,8), [8,15)`. These are a named host metric, not physical pixels.

The same observer must reject a compiled candidate that ignores the algorithm
selector and another that bypasses the maintained admission gate. Explicit
negative inputs cover unequal digests/counts, unsupported charset, failed HTTP
status, incomplete acquisition and invalid UTF-8 observations. Successful
fixture execution does not qualify Android UI, durable storage, actual network
acquisition, Binder/Shizuku, SEARCH dispatch or physical TAB_P10.

The separate title and Intent observers originate in merged android-NDK's
managed-export qualification at 6ab4818219efa7ea5eda137ca6b76976eb2a4d42.
Their move here preserves their role as independent observers; no application
implementation is copied.
