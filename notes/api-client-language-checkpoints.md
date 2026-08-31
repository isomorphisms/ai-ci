# API clients as language/compiler checkpoints

The small API clients in `isomorphisms/az` are development watchpoints for the
language family, not merely convenience scripts.

## Repository and branch rule

Keep the API corpus in `isomorphisms/az`, one service per branch. Current
examples include:

- `reddit-api`
- `nyt-api`
- `guardian-api`
- `economist-api`
- `ft-api`
- `reuters-api`
- `ap-api`
- `wayback-api`

Do not collapse unrelated services into one large API branch. A service branch
should be independently useful as a checkpoint against an older or newer
compiler/runtime.

## Language lanes

For each service, keep the same small behavior contract in:

- Idriç
- Ithon
- Fieldmouse

Use ICU as the shared small HTTP client/transport target wherever the language
can invoke it. This deliberately dogfoods the language stack instead of hiding
network behavior behind curl, requests, Node fetch, or another mature client.

A language lane may be incomplete. That is useful evidence. Leave an explicit
watchpoint or named hole at a missing boundary instead of silently replacing it
with another language or HTTP library.

## What these programs should exercise

The exact API varies, but the checkpoint ladder should expose ordinary program
surface such as:

1. source parses/checks;
2. command-line arguments arrive correctly;
3. strings and percent encoding are byte-correct;
4. environment/config values can be read without printing secrets;
5. files and synthetic JSON fixtures can be read;
6. JSON arrays/objects/records can be decoded without an untyped escape hatch;
7. deterministic TSV/text output matches a committed fixture;
8. the language can invoke ICU and consume its stdout/status;
9. ICU can represent the HTTP method, body, and request headers required by the
   service;
10. a live request produces the same output contract as the fixture path.

Use only `PASS`, `FAIL`, and `SKIP` receipts. A regression should name the
boundary that moved.

## ICU is itself part of the matrix

Current ICU represents GET and POST but does not expose arbitrary caller-supplied
request headers. That makes public query-key APIs such as NYT and Guardian good
near-term executable checkpoints. Wayback CDX is even simpler: no API key or
custom request header is needed, so a current language lane that can launch ICU
can exercise a real historical-coverage GET immediately.

Header-authenticated APIs such as AP, FT, Economist, Reuters, and authenticated
Reddit deliberately pressure the next ICU request-model feature.

Do not add a transparent fallback merely to turn those lanes green.

## Why keep this in ai-ci

When changing a parser, type checker, lowering pass, FFI/process surface, JSON
surface, or runtime, run these API checkpoints as mundane application pressure.
Arithmetic/compiler-unit examples can remain green while ordinary API programs
lose argv handling, strings, records, process execution, environment access, or
foreign boundaries. The API corpus exists to make that drift visible.
