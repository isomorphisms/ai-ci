# Independent shared-core oracle

# Shared Linux/Android core slice

Owner: SUN IB-X64-00, https://github.com/isomorphisms/ib/issues/138.
Execution opened by FP first-wave envelope 2bafcec71e7a73ff3d6d341690c294340a2a7493 before edits.

## Type sketch before implementation

Browser persistence policy is already owned by IB.LongViewTask. Both ordinary_tab
and protected_authenticated_transaction must choose durable_browser_task.
Protection controls renderer/session treatment; it must not decide whether history
exists after the renderer exits.

IB.FragmentStore owns RevisionedSource and checked FragmentGraph. SourceCoordinate
is the existing Unicode code-point count. Keep it distinct from UTF-8 byte counts
and UTF-16 code-unit counts even though the inherited representation is Number.
Proposed boundary:
- utf16_code_unit_offset : SourceCoordinate → RevisionedSource → Maybe Number
- fragment_source_text : RevisionedSource → Text → FragmentGraph → Maybe Text

The copy operation accepts an already admitted source revision plus an existing
fragment identity. It refuses changed source/representation/decoded digest/decoder
and changed decoded text, then slices exact source characters using the existing
checked half-open range. It does not parse rendered text, normalize whitespace,
authenticate a caller's claimed digest, or create an information/selection store.

The existing LongViewLifecycle from the selected Idriç Android work is reused
byte-for-byte. Host/renderer observations must preserve durable identities and
refuse callbacks from a detached or earlier generation.

Effects are confined to the separate command/checking layer. These core operations
are pure and must typecheck against the declared Idriç compiler. AICI supplies an
independent input/golden corpus and mutations of actual production source.

## Required services and evidence boundaries

The initial checker is Cat Food's pinned Linux x86-64 Idriç bundle, source
94dfd99bd3e376507fedc8611053b7173b2519f0, tar SHA-256
0be57deab9410e8d4c09c7198bf7e8ee0ec3e24121f76640147efa4a53d120da.
Typechecking/evaluator acceptance is not generated executable, disk recovery,
GUI or Android execution. ICK native qualification and Android followers remain
separate. No fallback source is planned.

## Acceptance intended before edits

Golden decoded text: A東京🙂éB.
Code-point boundaries 0..7 map to UTF-8 byte counts
0,1,4,7,11,12,14,15 and UTF-16 unit counts 0,1,2,3,5,6,7,8.
Unknown fragment, changed revision, equal bytes from another origin, changed
decoded content, wrong source ranges and stale host/renderer observations refuse.
Tabs/newlines/leading spaces must survive exact copy.

Mutants must restore disposable ordinary tabs, count the non-BMP scalar as one
UTF-16 unit, and skip source-revision binding. Each must fail its intended case.

## Result

Linux checker/evaluator PASS: all 38 independent cases, three actual IB source
mutants rejected for the intended named cases, and clean recovery True. FP run
ib-linux-shared-core-20261014T112612.222464Z retains exits and recipe identity.
The exported oracle was subsequently rechecked successfully. Native execution,
exact published-source replays and Android followers remain separate receipts.

The oracle imports actual IB owners and fixes expected values independently. It does not import an IB producer result or a producer-owned assertion list.
