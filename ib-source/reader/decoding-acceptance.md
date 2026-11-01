# Committed non-UTF-8 reader input

The explicit reader-v4 ART profile requires the maintained committed-document
export, its four separately compiled source mutations, and all earlier v3
selection/history/admission controls. Older frozen/v2/v3 profiles keep their
declared inputs. Missing v4 files fail; file availability cannot skip a check.

The 35 original fixture bytes have SHA-256
`f75de31144f8a4bcd321f0d54f8298fc7d429c8a9213c45c86e1abfc29f01a54`.
The independent observer expects the original ISO-8859-1 label, invalid-UTF-8
observation, source generation and digest to remain unchanged. It separately
expects the maintained Windows-1252 decoder identity in the derived source
reference and the exact semantic selection `€ “texte”`.

It refuses wrong status, MIME, digests, independent counts, actual original
octet counts, incomplete acquisition, unsupported encoding, a scalar outside
the octet carrier and conflicting BOMs. Producer mutations bypass admission,
change the Euro mapping, bypass original length, or truncate non-octet scalars.
Each must exit 137 with its designated diagnostic, while the positive exits 0.
Neither DEX emission nor host execution is counted as ART acceptance. These
pure calls do not qualify the Android SDK carrier or actual HTTP acquisition.

The installed public Example fixture now retains bounded main-stack and status
diagnostics before instrumentation exits on failure. Those diagnostics neither
replace the visible-document assertion nor convert a timeout into a pass.
They are restricted to the verified fresh emulator's controlled public input.
Physical TAB_P10 acceptance remains NOT_RUN until real access exists.
