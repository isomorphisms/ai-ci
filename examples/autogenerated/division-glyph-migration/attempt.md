# Division source audit in Idriç

## Purpose and type sketch

The account migration needs source locations for division tokens in C/header,
Lua, and Idriç source. Each language needs its own lexical rules. An extension,
textual slash count, or compiler smoke test does not establish which arithmetic
tokens still need migration.

`SourceCharacter` contains one decoded character and its original character
offset, physical line, and physical column. `Finding` contains that position
and a token classification. These are source locations, not byte offsets.
`SourceLanguage` selects the lexer for an explicitly named file; `LuaRegion`
and `IdricRegion` preserve their distinct literal and comment rules.

The pure operations include:

- `mark_characters : Number → Number → Number → List Char → List SourceCharacter`
- `scan_c : SourceRegion → Bool → Bool → List SourceCharacter → List Finding`
- `scan_lua : LuaRegion → List SourceCharacter → List Finding`
- `scan_idric : IdricRegion → Bool → List SourceCharacter → List Finding`
- `audit_text : SourceLanguage → Text → List Finding`

C line splicing happens before token recognition. Lua and Idriç retain their
physical characters. Comments and quoted literals are opaque regions. C binary
division, compound assignment, and directive slashes are separate findings.
Lua floor division remains distinct. Idriç inequality, primed identifiers,
nested comments, and multiline strings are handled separately; interpolation
is explicitly reported for manual review. Malformed regions are findings,
and C trigraphs require review.

The effects are reading named files and printing tab-separated locations.
Missing filenames, unreadable files, and unsupported source extensions fail.
The scanner does not edit source, traverse directories, infer ownership from
directory names, or select a compiler. Callers review ownership, frozen
references, generated source, actual compiler pins, and build/runtime evidence.
Its TSV CLI intentionally replaces the initial Python tool's directory/JSON
interface. Source findings are report data, not a fleet-compliance exit code.

## Implementation and acceptance

The implementation uses current Idriç `Text`, `Number`, Unicode arrows, and
decidable equality. `System.File` is the explicit host filesystem boundary.
The IO entrypoint is `covering` because inherited file operations have that
contract; the pure lexers remain total. Natural-number delimiter depths use
`Data.Nat.pred` when consuming a previously established positive depth.

Built and executed on 2026-10-09 with Idriç
`94dfd99bd3e376507fedc8611053b7173b2519f0`, version `0.8.0-94dfd99bd`.
The compiler payload SHA-256 was
`4864ed84e76332e6bc295d158524fa113e8b6e078aa6b9f586bdd9e7e06210ab`.
The command was `idris2 --no-banner --no-color -o division-glyph-scan AuditC.idric`,
using that actual compiler entrypoint and its declared Chez runtime.
`build/exec/division-glyph-scan --self-test` passed C literals, comments,
splices, compound/directive tokens, malformed source, trigraphs; Lua quoted
and matching long-bracket regions and floor division; and Idriç nested
comments, ASCII/Greek primed identifiers, inequality, multiline strings,
and interpolation-review controls.

The earlier Python implementation was unmerged migration work and violated
the repository's existing first-party Python gate. Its lexical controls now
run in Idriç, and both Python files were removed. Its automatic vendor/output
directory exclusions were replaced by explicit owned-file selection, not
silently copied as an ownership rule. Re-running all 190 Git-verified C/header
blobs in 28 source profiles with the extended scanner produced exactly the
same findings as the qualified C-only version.

Two implementation attempts needed correction. `--exec main` does not forward
program arguments; compiling an executable resolved that invocation error.
Using subtraction for the natural-number delimiter depth was rejected because
`Number` has no `Neg` instance; `pred` expresses the required operation and the
program then compiled and passed. Neither problem required another language
or compiler. No Python, Node, stock Idris, or RefC implementation was substituted.

## Boundaries and further language work

C directive tokens still require semantic classification. In particular,
macro replacement lists expanded into ordinary C and expressions evaluated
by `#if` are different compiler boundaries. Stringification, token pasting,
generated C inside another language, Idriç interpolation, and custom operator
spellings require review of the actual source and producer.

No missing Idriç capability blocked this program. A useful extension would
distinguish C header names, macro replacement lists, and `#if` expressions
while preserving physical locations across line splices. The present program
deliberately reports directive slashes for semantic review.
