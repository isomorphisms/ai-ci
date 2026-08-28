# Historical RefC observation — 2026-08-27

This is a closed evidence record, not an active Idriç backend route, CI lane,
acceptance criterion, or recommendation to reproduce the result with RefC.
New benchmark work must target a direct backend. See
[`ai-ci#24`](https://github.com/isomorphisms/ai-ci/issues/24).

The observation came from pull request #19, commit
`6b507c749ca66e336849b17f27503474afad3811`, in successful GitHub Actions
[run 33110776962](https://github.com/isomorphisms/ai-ci/actions/runs/33110776962).
The uploaded artifact was named `iridium-2014-idric-refc`, had artifact ID
`9662829885`, and had ZIP digest
`sha256:7c9db2f23dac4239520c9620caef2f8d3c1120461fa56c73526ae2dcf5c1d6c4`.

## Semantic result

The pinned Idriç compiler compiled `IdricBench.idric`, and two executions both
matched the versioned oracle exactly:

```text
40
17280
```

The result file SHA-256 was
`409599faca6b6ed574931db63b6208af8aa1f6e5d54bedd8554d272f03ee17ff`.
This establishes that this particular historical route executed the same
display-free StackSet/layout fixture. It does not qualify RefC as a current
backend, and it makes no speed comparison.

## Pinned route

- Idriç source commit: `081b9cde0591154839fb5d80d76e5570e0436300`
- compiler version: `Idris 2, version 0.8.0-081b9cde0`
- compiler executable SHA-256: `55bd2f65fde3fd6093048e75369002d14f12db8f12258778d197376e5f37c0bf`
- RefC `CC.idr` SHA-256: `0a86856387d501922193ec4e259434c30f20023f4995d674cd1e53c17f6c2749`
- RefC `RefC.idr` SHA-256: `29f2f0315b75b4e0083650a35d24f472450f5f6ba173f54c1fb6bf46289fe4cd`
- host: Ubuntu 24.04.4 LTS, x86-64
- C compiler: GCC 13.3.0
- C flags: `-O2 -fwrapv -fno-strict-overflow`
- compile time: 1.339 seconds

The compile route was `idris2 --source-dir benchmarks/iridium-2014 --cg refc
-o iridium-idric-refc benchmarks/iridium-2014/IdricBench.idric`, with the
pinned install prefix and C flags above.

## Retained measurements

- unstripped ELF: 93,152 bytes; SHA-256 `d79b52f9207aa542b372616c68a7ce246fac32b54502af310f364557ac5e5cff`
- stripped ELF: 71,896 bytes; SHA-256 `9419e3e4468003d4d4fb89e4bd39a6b5c530dda207bcd37a7fecb2dd01eaf975`
- ELF sections: 59,985 text bytes, 1,368 data bytes, 2,440 BSS bytes
- resolved external runtime files: 2,896,840 bytes total (`libc`, `libgmp`, and the dynamic loader)
- three separate executions: 2.400 seconds wall, 2.177 user, 0.223 system

The timing includes process startup and is evidence only. Optimization policy
was not normalized against the historical Idris build, so no performance ratio
may be inferred from it. The executable and its external runtime surface are
recorded separately for the same reason.

`IdricBench.idric` and `expected-output.txt` remain backend-neutral inputs for
future direct-backend rows. No checked-in workflow or script invokes RefC.
