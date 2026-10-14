# Division glyph: fleet audit (2026-10-08)

This directory is the historical first pass. The completed repository census,
current compiler evidence, and subsequent consumer migration are recorded in
[the 2026-10-09 continuation](../2026-10-09/README.md). Statements below describe
what was known when this first pass was collected; they are not current status.

## Purpose and non-negotiable distinction

In **maintained first-party** Icky C, Icky Lua and Idriç mathematical source,
express ordinary division with `÷` (U+00F7) when the actual selected compiler
supports that syntax. Do not change what division *means*. Do not silently
substitute stock C/Lua/Idris in the acceptance run and do not claim compiler
support from typographic documentation. Original foreign C, Lua, D/Idris
compatibility code, upstream forks and build substrate can legitimately use
`/`. Filesystem paths, URLs, regexes, string literals and comments are not
arithmetic; Lua `//` is a **different floor division operator**.

A whole-repository search-and-replace would both introduce syntax errors and
falsify the acceptance evidence. This work must therefore have separate gates:

1. **Repository census:** enumerate accessible repositories and each default
   branch's tracked C, Lua, `.idric`, `.idr`, D and C header files. Retain
   tree SHAs, mark empty/inaccessible/truncated trees, and separately audit
   active PR heads and submodules. Path counts are not source compliance.
2. **Semantic source pass:** scan owned C/Lua/`.idric` files (including active
   branches and templates), classify literal ASCII arithmetic slash, slash
   assignment, literal `÷`, Lua `//` and foreign boundaries. Review candidate
   operator sites with source context before edits.
3. **Compiler identity and syntax:** run literal `÷` acceptance plus ordinary
   `/` control using the compiler *actually called by the build*. Record exact
   source/toolchain revision and binary digest. Icky C, Icky Lua, Idriç,
   maintained Icky D and backend branches need independent qualifications.
4. **Consumer execution:** recompile changed source and run relevant native,
   emulator and device suites. Report cross-compile, link, host runtime and
   device execution separately. Keep downstream pin updates explicit.

## Compiler evidence

| Language | Compiler change | Evidence and boundary |
| --- | --- | --- |
| Icky C | [ICK #80](https://github.com/dilapidated-shed/ick/pull/80) (`×`), [ICK #84](https://github.com/dilapidated-shed/ick/pull/84) (`÷`), both merged | Source lexer plus passing PR language and Android ABI foundation workflows; not a blanket runtime claim |
| Icky Lua | [lua #1](https://github.com/isomorphisms/lua/pull/1), merged | Lexer maps U+00F7 to `/`; maintained `testes/symbolic-assignment.lua` contains `84 ÷ 2 = 42`. Consumers still need to pin/requalify |
| Idriç | [Idric #131](https://github.com/isomorphisms/Idric/pull/131), OPEN when recorded | Adds `×`/`÷` in `.idric` only; run `edric011` and the existing suite before merger and downstream pins |
| Icky D/GDC | [ICK #13](https://github.com/dilapidated-shed/ick/pull/13), historical | Source-only GDC Unicode import is not conservative DMD / current IDK runtime qualification |

## First inspected consumers and immediate blockers

- [Fourier-sound](https://github.com/isomorphismes/Fourier-sound):
  `fourier/fft.c` computes angle, half-length and scale with ASCII `/`.
  The ordinary `Makefile` uses `CC ?= cc`, and Android recipes use NDK
  Clang; the special ICK lane only compiles an isolated polynomial leaf.
  Do **not** rewrite general rendering code to `÷` until its real producer
  is changed and tested; its pinned ICK checkout predates the glyph PR.
- [Pauli](https://github.com/isomorphismes/pauli):
  `android/native/pauli_orbital.c` uses division, including radius-based
  calculations and an array-element count. Android CI uses the NDK.
  Needs toolchain/ownership qualification before Unicode migration.
- [Le Petit Prince](https://github.com/functorial-games/le-petit-prince):
  `core/tiny_planet.c` and test contain arithmetic ASCII slash.
  The current producer must be located and qualified, not guessed.
- [FastChat](https://github.com/isomorphisms/fastchat):
  default `main` includes Idriç core. Its CI pins Idriç
  `ff4d852862a3942592f8ade9afde8d409d9803be`, before division support.
  Its active C/Lua PR heads need separate enumeration and exact compiler pins.
- [IB](https://github.com/isomorphisms/ib):
  default `main` contains `.idric` files; not qualified merely by a
  successful backend compiler change.
- [Defold](https://github.com/functorial-games/defold) and
  [raylib](https://github.com/functorial-games/raylib) include many upstream
  C/Lua files. They are **not** a mandate to rewrite imported engines.

## Historical audit machinery and scope

This first pass used `scripts/audit_division_glyph.py`, exercised by
`tests/division_glyph/test_audit.py`. Those unmerged Python files were later
removed to comply with the repository's first-party language rule; their
lexical controls now run in the actual Idriç scanner described in
[the continuation](../2026-10-09/README.md). The earlier directory/JSON CLI is
retired. Its automatic vendor-directory exclusions did not establish source
ownership. Scanner counts, even with no candidates, are not complete semantic
proof and do not establish that the actual compiler accepts `÷`.

Partial default-branch path-census files are preserved beside this README,
with `INVENTORIED`, `TREE_FAILED` or `TRUNCATED` per repository. These
are works in progress, not a completed whole-fleet audit. In particular,
GitHub code-search results can miss known source files: the Icky Lua source
test is a demonstrated example, so absence from search cannot mean PASS.

## Completion criteria

No fleet-wide PASS until every available repository and active PR head is
accounted for (including no-source/foreign/empty/unavailable categories),
every declared source profile has a source audit, every actual compiler has
literal-glyph acceptance, and changed consumers have matching build and
runtime receipts. New compiler merges do not retroactively qualify old APKs.
