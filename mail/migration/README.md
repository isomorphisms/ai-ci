# Identity and destination effects

`identity-collisions` supplies six occurrences: same Message-ID/different headers,
identical bytes at different offsets, absent and malformed Message-ID, and a
replay of the same source locator. Content hashes cannot replace source identity.
Occurrence identity can distinguish repeated observations of the same locator.
Gmail message IDs and thread IDs are destination fields, not RFC Message-ID.

No deduplication rule is selected. Every source occurrence must be accounted for
in an eventual manifest even if a later reviewed policy deliberately maps several
occurrences to one destination. Matching bodies do not justify removing headers.
The current model checks preservation of occurrence records only; it cannot prove
an actual destination did not receive a duplicate.

The chosen Gmail method, options, internal-date policy, labels, message size
limits, rejected-message quarantine, destination reconciliation, and any import
transformations remain unresolved. Import, insert, send, and Drive upload are
different operations. The live API documents base64url raw messages and returned
Gmail Message objects; it does not supply this project's missing migration design.
Do not assume retry idempotency merely from an HTTP library's retry defaults.
