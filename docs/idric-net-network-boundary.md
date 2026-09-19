# Idric-Net cross-repository network boundary

`isomorphisms/Idric-Net` is the reusable networking-semantics owner for Idriç and Odriç. `dilapidated-shed/icu` is the first dogfood client. `isomorphisms/Idric` owns the language/compiler mechanisms needed to make the declared network domains compiler-visible.

This registration exists because the same failure can otherwise recur in three different forms: generic protocol values collapse back to primitive strings/integers in ICU; Idric-Net becomes only a naming wrapper with no compiler-visible constraints; or a backend widens a finite/constrained domain into an unconstrained machine word and loses the fact that justified the type.

## Required ownership split

### Idriç / Odriç compiler

The compiler owns general mechanisms, not HTTP-specific constants:

- bounded scalar domains;
- finite-choice cardinality;
- equality to semantic constants;
- dependent relationships such as `index < length` and body-byte-length equality;
- erased compile-time constraint evidence;
- arithmetic range propagation;
- preservation of range/cardinality into ANF, IR, and machine backends.

The compiler must not contain a special built-in rule that `404` means `not_found`.

### Idric-Net

The networking library declares protocol semantics:

- `DestinationPort` has admissible wire values 1..65535;
- `HTTPStatusCode` has admissible wire values 100..599;
- `not_found` is the semantic HTTP status whose wire number is 404;
- status class is derived from the status domain, including unregistered extension codes;
- HTTP methods carry their semantic properties;
- header names, values, framing fields, and credential fields remain distinguishable;
- `transport_result` is an eight-alternative semantic choice rather than an integer;
- URL, origin, request body, byte length, redirect, TLS, and socket semantics belong here as they are extracted.

### ICU

ICU is an executable client and integration target. It may temporarily provide the live native C/OpenSSL socket implementation, but generic URL/HTTP/status/header/transport semantics must not fork into a second authoritative copy.

## Acceptance invariants

A change touching this boundary should be blocked when any of the following is true:

1. ICU introduces a second independent definition of a protocol semantic type already owned by Idric-Net.
2. A semantic value is reduced to a generic `String` or `Int` before the ABI/OS boundary without a stated reason.
3. `not_found` no longer has exact HTTP wire number 404 or no longer classifies as `client_error`.
4. arbitrary status values outside 100..599 can inhabit the status domain.
5. arbitrary destination ports outside 1..65535 can enter through the checked runtime boundary.
6. the eight-case transport result becomes a generic numeric domain internally.
7. ANF/IR/backend lowering loses the finite-cardinality or bounded-range fact merely because the target uses a full machine register.
8. body length and similar derived values are maintained as unrelated mutable facts after the language can express the relation directly.
9. a native C/OpenSSL implementation is relabeled as pure Idriç/Odriç without executable evidence that ownership actually moved.

## Evidence expected

The cross-repository receipt should identify exact revisions for Idric-Net, Idriç, and ICU and include:

- Idric-Net semantic tests;
- compiler tests for constrained literals and derived ranges once syntax lands;
- IR/backend evidence that finite/range information survives lowering;
- ICU build/tests consuming the pinned Idric-Net package;
- native ownership statement and process trace where the live socket/TLS provider remains native;
- a deliberately broken fixture for each deterministic contract that is promoted into ai-ci.

## Current bootstrap state

The initial Idric-Net branch uses current Idriç features to make the semantic split executable while `CONSTRAINTS.md` records the stronger language target. That checked-wrapper phase is acceptable only as a bootstrap. It must not be mistaken for completion of compiler-visible constrained values.
