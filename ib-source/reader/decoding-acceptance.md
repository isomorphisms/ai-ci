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

The initial v4 run at IB fabac08af063a923e50448b696c900b4a0f89caf
(run 41279724988) failed both positive decoder observations with exit 137
and no marker. Independent retained logcat identifies an external-observer
VerifyError at code offset 0x46: its digest-case expect call supplied four
registers but named a three-String descriptor. That call now names the same
four-String helper as its definition and all nine other calls. No candidate
source, DEX, ABI or semantic expectation changes. The exact archived candidate
and all compiled source controls are replayed on API 29 and 34. The failed run
remains FAIL; neither an observer verifier failure nor an unexplained kill is
accepted as a mutant rejection.

The corrected observer at ai-ci e3c1da56ce36acae2374cf1410e889d3f384d65c
replayed those unchanged IB fabac08a bytes in run 41283288967. API 29 job
124779416579 and API 34 job 124779416354 both PASS: the positive returned zero
with its exact decoder marker, and all four compiled mutations returned 137
with their designated semantic diagnostics. Earlier v3 component and mutation
controls also ran. This qualifies checked committed-source decoding on ART;
it does not qualify the installed SDK octet carrier, HTTP input, or physical
TAB_P10.
