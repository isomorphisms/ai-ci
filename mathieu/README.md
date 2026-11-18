# Independent Mathieu oracle

`reference.g` uses GAP's permutation-group and finite-field implementations, reading the original ATLAS cycle expressions from the consumer. It independently computes orders, successive point stabilizers and five-transitivity, all design blocks, unique five-subset coverage, the 4096 codewords and their weight distribution, and actual generator preservation. It never enumerates M24.

`check.grease SOURCE HEAD ENGINE GAP GAP_ROOT EVIDENCE` compares 5,009 exact reference lines against the real ICK engine executable. Every generator image, ten word fixtures per group, every hexad/octet and every Golay word must agree. Deliberately corrupting a word, design or code export must fail comparison. Producer tests additionally reject an odd transposition, malformed maps and a duplicate block, and verify renderer/interaction semantics.

This gate qualifies its explicit mathematical boundary. It does not grant review approval to its own unmerged implementation, certify Android UI behavior, sign an APK, establish Cat Food delivery or replace physical-device acceptance.
