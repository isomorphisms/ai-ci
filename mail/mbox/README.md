# Mbox boundary questions

Every mbox input is synthetic. The corpus includes empty/one/several/adjacent
records, final-newline variants, empty/newline-only bodies, quoted From levels,
malformed and incomplete separators, invalid headers, binary octets, Content-
Length conflicts, and separator-shaped text inside MIME. Large sources come
from ../large/stream.c.

`constructed-spans.tsv` has ordinal, envelope start, raw-message start,
exclusive raw-message end, length, digest, and exact raw-message file. These
describe how the fixture was built, **not an expected parser's answer**. In
particular, separator-looking payload can change framing in some conventions.
Offsets include bytes, not Unicode characters; all trailing bytes included in
the constructed message remain in its span. `source.tsv` independently covers
the whole input. No dequoting or line-ending normalization alters that archive.

To activate retained-format acceptance: identify the actual original parser and
upstream commit, examine its separator predicate, quoting/dequoting direction,
Content-Length treatment, LF/CRLF rules, EOF rules, and malformed-record handling.
Record source functions and deliberate feature removals. Resolve each existing
fixture with explicit expected spans and transformation records. Do not infer
mboxo/mboxrd/mboxcl/NetBSD behavior from the word “mbox” or from another parser.

`every-From-is-separator`, recursive dequoting and off-by-one inter-message span
mutations remain **blocked**, not killed: no retained convention exists against
which to make those claims. Raw byte-loss and 32-bit source-position mutations
already run independently of that choice.
