# API checkpoint test suite

This suite turns the API-client checkpoint ladder in `notes/api-client-language-checkpoints.md` into executable receipts without merging the service branches together.

The corpus remains in `isomorphisms/az`, one provider per branch. `cases.tsv` names the branch and the exact Ithon, Idriç, and Fieldmouse source path for each provider. `check` reads those sources with `git show`, so a run never needs to switch the `az` worktree between branches.

## Default run

```sh
AZ_REPO=/opt/az ./api-checkpoints/check
```

The default run is deterministic and does not use the network.

For every provider it verifies that all three language-lane sources exist. If a language runtime/compiler is available, it also exercises that lane. Missing runtimes are `SKIP`, not `PASS`.

Ithon currently gets the deepest checks because it is the closest executable lane:

- whole-module checking is proved by `ITHON_CHECK_RECEIPT`;
- deterministic argv/string/percent-encoding or JSON construction is compared byte-for-byte;
- NYT, Guardian, and Wayback invoke a fake ICU executable and must pass the exact `get URL` argv boundary;
- Reddit, AP, FT, Economist, and Reuters must expose the known ICU custom-header limitation as an explicit exit-3 `SKIP`;
- imports of `urllib.request`, `http.client`, or `requests` are rejected as transparent HTTP fallbacks.

Fieldmouse gets deterministic application probes when `fieldmouse` is available. Idriç gets `idris2 --check` when its compiler is available. Current missing runtime/compiler surfaces should therefore appear as focused `FAIL` or `SKIP` receipts rather than being hidden by another language.

The only receipt words emitted by the runner are:

```text
PASS
FAIL
SKIP
```

Any `FAIL` makes the runner exit nonzero. `SKIP` does not.

## Optional live transport

```sh
AZ_REPO=/opt/az ICU=/opt/icu/build/exec/icu ./api-checkpoints/check --live
```

`--live` adds real Ithon→ICU transport checks for the providers that current ICU can represent:

- Wayback runs without credentials;
- Guardian runs when `GUARDIAN_API_KEY` is present;
- NYT runs when `NYT_API_KEY` is present.

The header-authenticated providers remain explicit `SKIP` until ICU grows caller-supplied request headers. No curl, requests, urllib HTTP, or Node-fetch fallback is permitted to make a live lane green.

To isolate one service:

```sh
./api-checkpoints/check --provider wayback
```

Environment overrides are `AZ_REPO`, `ITHON`, `FIELDMOUSE`, `IDRIC`, and `ICU`.
