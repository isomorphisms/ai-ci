# Division source audit in Idriç

## Purpose and type sketch

The account migration needs source locations for C division tokens, including
headers and C logical lines. A file extension, textual slash count, or successful
compiler test does not establish which source tokens still need migration.

`SourceCharacter` contains one decoded character and its original character
offset, physical line, and physical column. `Finding` contains that position
and a token classification. These are source locations, not byte offsets.

The pure operations are:

- `mark_characters : Number → Number → Number → List Char → List SourceCharacter`
- `scan_c : SourceRegion → Bool → Bool → List SourceCharacter → List Finding`
- `audit_c_text : Text → List Finding`

C line splicing happens before token recognition. Locations still refer to the
original file. Comments and string/character literals are preserved as opaque
regions. Literal division, existing division glyphs, compound assignments, and
preprocessor slash boundaries have distinct findings. An unterminated quoted
region or block comment is an explicit finding. Trigraphs require manual review.

The only effects are reading named files and printing tab-separated locations.
This scanner does not edit source or select a compiler. Callers must separately
review ownership, frozen references, generated source, actual compiler pins,
and build/runtime evidence before changing bytes.

## Implementation and acceptance

The implementation uses the documented current Idriç `Text`, `Number`, Unicode
arrows, and decidable equality surface. It uses `System.File` for the explicit
host filesystem boundary. The IO entrypoint is `covering` because inherited
file operations have that contract; the lexer remains total.

Built and executed on 2026-10-09 with current Idriç
`94dfd99bd3e376507fedc8611053b7173b2519f0`, version `0.8.0-94dfd99bd`.
The compiler payload SHA-256 was
`4864ed84e76332e6bc295d158524fa113e8b6e078aa6b9f586bdd9e7e06210ab`.
From this directory, the compiler invocation was
`idris2 --no-banner --no-color -o division-glyph-scan AuditC.idric`, using the
actual built Idriç entrypoint and its declared Chez runtime. Compilation passed.
`build/exec/division-glyph-scan --self-test` passed the literal, comment,
splice, compound, preprocessor, malformed-source, and trigraph controls.
An explicit run over 190 Git-verified C/header blobs in 28 source profiles
completed successfully; profile coverage is separate from fleet compliance.

The first attempted `--exec main ... -- --self-test` command was rejected
because that compiler option does not forward program arguments. Building the
executable and supplying arguments to it resolved the invocation issue; it
was not a language or compiler failure. No Python, Node, stock Idris, or RefC
implementation was substituted.

## Boundaries

This is a C/header scanner. Lua and Idriç have different token grammars and are
audited separately. Preprocessor expressions retain their separate compiler
boundary: the current ICK glyph mapping happens after preprocessing. Macro
stringification and token pasting need semantic review. Generated C embedded
in other languages must be checked at its generator and output boundaries.

## Language work exposed

No Idriç capability blocked this program. The next useful extension is a typed
preprocessor-token category that distinguishes header names, macro replacement
lists, and `#if` expressions. Its acceptance case must preserve source positions
across splices while identifying arithmetic in each category. The present
program deliberately reports all directive slashes for semantic review.
