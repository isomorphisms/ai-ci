# Shared Grease material source verification

The unchanged shared material self-test executed successfully twice on a fresh
Debian 13.6 x86_64 container, using the partial native D runtime from
[Oils run 43520333267](https://github.com/dilapidated-shed/oils/actions/runs/43520333267).
Its artifact is `14083485063`, source
`df3ecfcb58031e82f5ae98d1301c7ee67fbb21a7`. Both the downloaded ZIP and extracted
runtime were SHA-256 checked against the retained observation. No C++ or Python
runtime was substituted for the native D execution.

Each invocation ran `package-closure/self-test.grease` unchanged, including the
literal `libgdiagnostics++.h` positive and all twelve named targeted refusals.
The runtime arguments after the script were the absolute package-closure
directory, absolute native executable, and a fresh work directory. The tests
returned zero only after reporting their final complete self-test PASS. The
three shared source hashes are retained in the adjacent TSV; they are unchanged
from `cee2f091ee9a9d854260171baef3dfe70336101d`.

This is scoped evidence that the shared source and its corpus execute under
the partial native implementation. It does not qualify that implementation as
a complete Grease runtime or admit it for managed installation. The later
[Oils source receipt](https://github.com/dilapidated-shed/oils/blob/c2cf5898c5dbf83abc509fd3e5bc7fad2490efe7/ysh/d/qualification/il0-times-2026-11-14/receipt.tsv)
still records 223 inherited failures, unfinished independent static/transitive
C++ exclusion and no managed package admission. Those obligations remain
separate from this material-source check.

The unchanged `verify.grease` also passed against the actual acquired 870-file
ICK compiler package. Its separately supplied required-payload contract named
the driver and frontend with mode 755, and `stddef.h` and `stdatomic.h` with mode
644. The complete byte/mode/path inventory before verification, the independent
inventory generated during verification, and the complete inventory afterward
all had SHA-256
`62661fb117fc5b36dd2ffc280f44e9eae3d1b6c88863de6aac547b6fd9b34459`.
The stored `material.tsv` was unchanged. All observed output files were outside
the package. This gives byte/mode/path read-only evidence for this execution;
it does not claim absence of file-access-time changes.

Archive acquisition, shared material verification, semantic compiler execution,
authenticated witnesses and managed runtime eligibility retain distinct outcomes.
