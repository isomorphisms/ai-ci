# Idriç source-style gate

This directory contains reusable mechanical enforcement for Idriç-family repositories.
It is **not** the authority on what good Idriç source means. The canonical policy lives
in `isomorphisms/Idric` at root `STYLE.md`, with repository-specific agent instructions
in root `AGENTS.md`.

The current gate checks only newly added `.idric` lines:

- `Nat` is an error. Use `Number` for an ordinary number/count, or an explicit
  semantic restricted type when bounds, sign, units, or another restriction matter.
- `Vect` is an error. Use `List` when length is not part of the meaning, or a
  semantic collection/restriction when length or shape matters.
- lowerCamelCase is a warning and style canary.
- ASCII `->` and `<-` are warnings and style canaries.

Warnings are deliberately not automatic rewrites. They tell the author or agent to
re-read the canonical Idriç style guidance and reconsider the declaration as a whole.

The filename is the compiler's language boundary. `.idr` files implement the
inherited Idris/bootstrap compatibility stratum and retain its real types,
identifiers and arrows. Forcing the `.idric` vocabulary onto that stratum can
require undefined aliases such as `Number`; it is not an Idriç style repair.
The gate does not exempt a directory or repository: `.idric` files remain
checked wherever they occur, including alongside `.idr` implementation files.

## GitHub Actions

Check out the repository with full history, then use the `idric-style` action at the
exact reviewed `ai-ci` commit SHA:

```yaml
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
  with:
    ref: ${{ github.event.pull_request.head.sha || github.sha }}
    fetch-depth: 0
- uses: isomorphisms/ai-ci/idric-style@0123456789abcdef0123456789abcdef01234567
```

Do not copy the placeholder SHA. Pin the exact reviewed revision.

A pull request checks the changes since the common ancestor of the event's base
and submitted head. The selected `head` must match the event's submitted PR head.
The event base and its history must be available locally. An explicit `base`
on a pull request must resolve to the same base commit as the event. A missing
endpoint or common ancestor fails the action.

Pushes use their `before` commit unless a caller supplies `base`. On other events,
an explicit `base` can select the range. Outside pull requests an absent or
unavailable comparison base falls back to the selected `head`'s parent.

## Command line

```sh
sh path/to/ai-ci/idric-style/check_added_source BASE [HEAD]
```

The checker scans only added source lines so an Idriç-family repository can adopt it
without first rewriting inherited Idris code.
