# Idriç compatibility registry

This directory records which Idriç compiler pieces and code generators each
active project actually uses. It distinguishes an immutable passing tuple from
a moving branch, a local-only result, a planned integration, and a repository
with no current Idriç dependency.

That distinction matters here: the active repository fleet does **not** all
currently depend on Idriç.

## Current boundary

| Project group | Current compiler boundary |
| --- | --- |
| IB, ICU, Fieldmouse, Hopf Fibration | Idriç `61970be77769f607cca8650bf424c0f0b22ddee7`, `.idric` source, built-in Chez code generator. Fieldmouse also runs moving `main`, but the resolved SHA is not retained as durable evidence. |
| Programmer's Unicode Picker | Idriç `d93b5cf538836325812813e81c2dfdac159397b0`, built-in Chez, generated C layout snapshot. |
| Theta | Moving Idriç `main`, built-in `javascript` code generator, no durable resolved-compiler receipt. |
| Conway and L | Moving Idriç `main` plus GLSL ES backend `7876b79058d6f59711151a21697369c1cf72df2f`; the backend pin is exact, the compiler pin is not. |
| Ortho | Idriç-authored generated C geometry, but current CI only builds the checked artifact and does not regenerate it. |
| Catfood | Clones and builds moving Idriç `main`; it also clones both external backend repositories by branch without testing their compiler compatibility. |
| Grease | Oils/YSH implementation with no current Idriç dependency or declared Idriç seam. |
| Wegert and analytic continuation | No direct Idriç build. Their mathematics exist in the external GLSL backend, but the apps do not consume that path. |
| `idris-koans` and Programmer's Keyboard | Upstream Idris 2 consumers, not current Idriç consumers. |
| `idris2-ilex` TOML library | The exact `d6062e8f...` revision fails against Float PR #6 because it declares a constructor named `Float`. This is a source-language collision, not a backend failure. |

The matrix also records recently active repositories for which the review found
no direct dependency. `not-applicable` means “no dependency observed at this
surveyed revision,” not “this project can never use Idriç.” `decision-open`
keeps the same no-dependency claim while linking an unresolved boundary decision
to the gap ledger; it does not imply that an integration is planned.

## Backends

The built-in backends move with the compiler revision: Chez, separate Chez,
Racket, Gambit, Node, browser JavaScript, and RefC. The two external backends
have independent compiler-API contracts:

| Backend | Backend revision | Compiler contract | Current evidence |
| --- | --- | --- | --- |
| GLSL ES | `7876b79058d6f59711151a21697369c1cf72df2f` | Its own CI uses upstream Idris 2 `v0.8.0` and the `idris2api` package. | Upstream lane passes; its own Idriç lane is absent. |
| Android ARMv7 | `663fe5fbdd22249e2ccfecf0ba5e4a43b24a6f85` | Upstream Idris 2 `f66d2a1802d9e04a57441160f411d46be63d785f`, compiler API, `network`, and the distinct `Float32` primitive. | Repository records local verification; it has no GitHub Actions lane and no proved Idriç tuple. |

The ARM requirement is commit-sensitive, not merely “Idris 2 0.8.0.” Its
Idriç lane must be checked against the Float32 compiler work rather than assumed
from the shared version number.

### Distinct Float candidate

Idriç PR #6 at `5d0c454b1c3ad3d12a5d18452c2ba169109ebd76`
has exact passing evidence for the Chez semantic regression and the RefC
single-precision regression. Racket contains an implementation but lacks an
equivalent focused backend receipt. Node and browser JavaScript reject the
required Float cast, Gambit emits `blodwen-float32` without defining it, and VM
execution does not reduce the new primitive operations.

The Nix job's RefC coverage does not mean that Idriç bootstraps through RefC.
Nix bootstraps through Chez and then runs the inherited complete test suite,
which includes RefC. No surveyed downstream selects RefC; it remains an
inherited optional backend until a separate retirement decision changes the
public compiler and test surface coherently.

## Files and invariants

- `scope-v1.tsv` freezes the reviewed repository set, default branch, and exact
  surveyed head.
- `backends-v1.tsv` inventories built-in and external generators, including the
  compiler API and library pieces each needs.
- `matrix-v1.tsv` records exact project/compiler/backend tuples and their result.
- `gaps-v1.tsv` gives every moving, untested, local-only, upstream-only,
  planned, or boundary-decision tuple an open acceptance condition linked to
  the AICI tracker.

The native verifier rejects missing scope entries, abbreviated project or
backend pins, unknown backends, mismatched external-backend revisions,
unresolved rows without an open gap, duplicate tuples, and `pass` claims that
are not bound to a full compiler revision and a specific workflow run.

This fleet registry complements AICI's [`compat/`](../compat/README.md) gate.
The registry says which projects and compiler/backend combinations need
attention; a downstream build uses the generic compatibility contract and
hashed receipt to prove one exact tuple. A recorded `fail` is kept open through
the gap ledger, while an immutable `pass` still needs its specific workflow
evidence.

`pass-unbound` is deliberately weaker than `pass`: it says a job using a moving
compiler reference was green, while admitting that the exact compiler commit
was not preserved. A green downstream job cannot silently upgrade itself to an
immutable compatibility claim.

## Use

```text
cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 \
  -o /tmp/aici-idric src/aici_idric.c

/tmp/aici-idric verify \
  idric/scope-v1.tsv \
  idric/backends-v1.tsv \
  idric/matrix-v1.tsv \
  idric/gaps-v1.tsv
```

The scheduled AICI workflow also compares every surveyed default-branch head
with `scope-v1.tsv`. Drift fails the probe and requires a fresh compatibility
review; it does not pretend that a changed repository is incompatible.

## Deliberate limit

This first slice validates the registry and makes stale or unsupported claims
visible. It does not build every Cartesian product. The open gap ledger is the
authoritative list of missing current-compiler lanes and receipt binding.
Downstream product CI and `compat/` receipts remain the source of actual
build/runtime evidence.
