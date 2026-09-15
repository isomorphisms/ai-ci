#!/bin/sh
set -eu

root=${TMPDIR:-/tmp}/aici-github-policy-$$
trap 'rm -rf "$root"' EXIT HUP INT TERM
mkdir -p "$root"

cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 \
  -o "$root/aici-github" src/aici_github.c

make_case() {
  name=$1
  mkdir -p "$root/$name/.github/workflows"
}

expect_fail() {
  name=$1
  expected=$2
  exceptions=${3:--}
  visibility=${4:-public}
  if "$root/aici-github" verify "$root/$name" "$exceptions" "$visibility" \
      >"$root/$name.out" 2>"$root/$name.err"; then
    echo "$name unexpectedly passed" >&2
    exit 1
  fi
  first=$(cut -f1 "$root/$name.err" | sed -n '1p')
  if [ "$first" != "$expected" ]; then
    echo "$name failed with $first, expected $expected" >&2
    cat "$root/$name.err" >&2
    exit 1
  fi
}

make_case good-latest
cat > "$root/good-latest/.github/workflows/ci.yml" <<'YAML'
on:
  push:
  pull_request:
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - run: true
YAML
"$root/aici-github" verify "$root/good-latest" - public >/dev/null

make_case good-pinned
cat > "$root/good-pinned/.github/workflows/ci.yml" <<'YAML'
on:
  push:
jobs:
  test:
    runs-on: ubuntu-24.04
    steps:
      - run: true
YAML
"$root/aici-github" verify "$root/good-pinned" - public >/dev/null

make_case good-debian
cat > "$root/good-debian/.github/workflows/ci.yml" <<'YAML'
on:
  pull_request:
jobs:
  workload-specific-debian:
    if: github.event_name != 'pull_request' || github.event.pull_request.head.repo.full_name == github.repository
    runs-on: [self-hosted, linux, debian]
    steps:
      - run: true
YAML
"$root/aici-github" verify "$root/good-debian" - public >/dev/null

make_case good-block-list
cat > "$root/good-block-list/.github/workflows/ci.yaml" <<'YAML'
on:
  push:
jobs:
  workload-specific-debian:
    runs-on:
      - debian
      - self-hosted
      - linux
    steps:
      - run: true
YAML
"$root/aici-github" verify "$root/good-block-list" - public >/dev/null

make_case hosted-non-ubuntu
cat > "$root/hosted-non-ubuntu/.github/workflows/ci.yml" <<'YAML'
on:
  push:
jobs:
  test:
    runs-on: macos-15-intel
    steps:
      - run: true
YAML
expect_fail hosted-non-ubuntu GITHUB-RUNNER-FORBIDDEN

make_case labels
cat > "$root/labels/.github/workflows/ci.yml" <<'YAML'
on:
  push:
jobs:
  test:
    runs-on: [self-hosted, linux]
    steps:
      - run: true
YAML
expect_fail labels GITHUB-RUNNER-SELF-HOSTED-LABELS

make_case fork
cat > "$root/fork/.github/workflows/ci.yml" <<'YAML'
on:
  pull_request:
jobs:
  test:
    runs-on: [self-hosted, linux, debian]
    steps:
      - run: true
YAML
expect_fail fork GITHUB-FORK-GUARD

make_case step-guard
cat > "$root/step-guard/.github/workflows/ci.yml" <<'YAML'
on:
  pull_request:
jobs:
  test:
    runs-on: [self-hosted, linux, debian]
    steps:
      - if: github.event_name != 'pull_request' || github.event.pull_request.head.repo.full_name == github.repository
        run: true
YAML
expect_fail step-guard GITHUB-FORK-GUARD

make_case dynamic
cat > "$root/dynamic/.github/workflows/ci.yml" <<'YAML'
on:
  push:
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-24.04]
    steps:
      - run: true
YAML
expect_fail dynamic GITHUB-RUNNER-DYNAMIC

make_case exception
cat > "$root/exception/.github/workflows/ci.yml" <<'YAML'
on:
  push:
jobs:
  historical-macos:
    runs-on: macos-15-intel
    steps:
      - run: true
YAML
cat > "$root/exception/exceptions.tsv" <<'TSV'
workflow	job	runs_on	reason
.github/workflows/ci.yml	historical-macos	macos-15-intel	native Mach-O reconstruction
TSV
"$root/aici-github" verify "$root/exception" exceptions.tsv public >/dev/null

make_case ubuntu-exception
cat > "$root/ubuntu-exception/.github/workflows/ci.yml" <<'YAML'
on:
  push:
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - run: true
YAML
cat > "$root/ubuntu-exception/exceptions.tsv" <<'TSV'
workflow	job	runs_on	reason
.github/workflows/ci.yml	test	ubuntu-latest	obsolete hosted-Ubuntu exception
TSV
expect_fail ubuntu-exception GITHUB-EXCEPTION-MALFORMED exceptions.tsv

make_case stale
cat > "$root/stale/.github/workflows/ci.yml" <<'YAML'
on:
  push:
jobs:
  test:
    runs-on: ubuntu-24.04
    steps:
      - run: true
YAML
cat > "$root/stale/exceptions.tsv" <<'TSV'
workflow	job	runs_on	reason
.github/workflows/ci.yml	old-macos	macos-15-intel	obsolete exception
TSV
expect_fail stale GITHUB-EXCEPTION-STALE exceptions.tsv

make_case private
cat > "$root/private/.github/workflows/ci.yml" <<'YAML'
on:
  pull_request:
jobs:
  workload-specific-debian:
    runs-on: [self-hosted, linux, debian]
    steps:
      - run: true
YAML
"$root/aici-github" verify "$root/private" - private >/dev/null

printf '%s\n' 'GitHub runner policy fixtures passed'
