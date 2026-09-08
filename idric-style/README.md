# Idriç source-style gate

This directory contains reusable mechanical enforcement for Idriç-family repositories.
It is **not** the authority on what good Idriç source means. The canonical policy lives
in `isomorphisms/Idric` at root `STYLE.md`, with repository-specific agent instructions
in root `AGENTS.md`.

The current gate checks only newly added `.idr` and `.idric` lines:

- `Nat` is an error. Use `Number` for an ordinary number/count, or an explicit
  semantic restricted type when bounds, sign, units, or another restriction matter.
- `Vect` is an error. Use `List` when length is not part of the meaning, or a
  semantic collection/restriction when length or shape matters.
- lowerCamelCase is a warning and style canary.
- ASCII `->` and `<-` are warnings and style canaries.

Warnings are deliberately not automatic rewrites. They tell the author or agent to
re-read the canonical Idriç style guidance and reconsider the declaration as a whole.

## GitHub Actions

Check out the repository with full history, then use:

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0
- uses: isomorphisms/ai-ci/idric-style@main
```

The action infers the comparison base from pull-request or push metadata. `base` and
`head` inputs are available when a caller needs to specify the range explicitly.

## Command line

```sh
sh path/to/ai-ci/idric-style/check_added_source BASE [HEAD]
```

The checker scans only added source lines so an Idriç-family repository can adopt it
without first rewriting inherited Idris code.
