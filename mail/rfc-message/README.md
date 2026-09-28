# RFC messages

The constructed RFC 5322 profile includes Date and From where valid syntax needs
them. Optional fields may be absent. Repeated extension fields are ordered, and
singleton duplication is a separate unresolved recovery fixture. Long unfolded
headers use short legal physical lines. UTF-8 headers are explicitly an RFC 6532
profile, not automatically a requirement on an unidentified legacy parser.

`facts.tsv` preserves interpreted field bodies separately from `archive.bin`.
Source folding, capitalization, empty values, comments, punctuation, and body
boundaries remain inspectable. Valid encoded words have a separate display
expectation. Bad words, leading folds, missing colons, bare CR/LF, embedded NUL,
missing header/body separator and incomplete final headers keep raw assertions
but leave retained recovery outcomes unresolved. A rejected message must not be
quietly converted into a successful import.
