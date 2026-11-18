# Independent retained history observations

The maintained IB history must preserve source identity and immutable Arena
generation across Back and Forward. A new arrival after Back replaces forward
references; it does not delete retained source bytes. The independent observer
contains literal expected journals and refusal messages, rather than invoking
producer helpers to construct its expectations. Compiled producer mutations
retain forward references, admit an invalid cursor, and admit an overflowing
generation. Each must terminate at its own exact failed assertion.

`observe-art.grease` requires `history-v2` for the new integrated reader. Its
original six-argument profile remains explicit frozen-consumer-v1 for the
513d72cb checkpoint, whose artifact predates history. Its receipt marks history
NOT_RUN. The presence or absence of an artifact never selects the profile.
All positive candidates still require normal exit zero. Controlled assertion
termination is described in `assertion-termination.md`.

The installed reader oracle expects the complete seven-line IBLAST2 head for
the one-document example.com test, including its IBH1 cursor and occurrence.
It independently hashes the whole prefix. A changed cursor must fail digest
verification; a checksum-correct forged cursor must fail the literal selected
occurrence expectation. This bounded oracle is not a second general history
implementation or a source-admission owner.

All five independent observer classes and their shared failure helper assembled
with Smali 3.0.10 on the host. Producer DEX compilation, determinism and decode
passed separately. New ART, installed history events and device acceptance are
still required. The TAB_P10 has no accessible authenticated endpoint in this
campaign; emulator and host results do not provide physical acceptance.
