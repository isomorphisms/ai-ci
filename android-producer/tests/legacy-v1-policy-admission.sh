#!/usr/bin/env bash
# Frozen admission prefix from main@8bf8be153f792c4def251287ed85543d1fe24f07.
# Foreign historical fixture only. It always refuses and cannot approve an APK.
set -Eeuo pipefail

fail() {
    printf 'AICI Android producer gate failed: %s\n' "$*" >&2
    exit 1
}

require_file() {
    [[ -f "$1" ]] || fail "missing file: $1"
}

tsv_value() {
    local file=$1 key=$2
    awk -F '\t' -v key="$key" '
        $1 == key {
            count++
            value=$2
        }
        END {
            if (count != 1) exit 2
            print value
        }
    ' "$file" || fail "$file must contain exactly one $key field"
}

verify_merged_commit() {
    local repository=$1 commit=$2 label=$3
    [[ "$commit" =~ ^[0-9a-f]{40}$ ]] ||
        fail "$label must be pinned by full commit SHA: $commit"

    local work
    work=$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/aici-authority.XXXXXX")
    git -C "$work" init -q
    git -C "$work" remote add origin "https://github.com/$repository.git"
    git -C "$work" fetch -q --filter=blob:none --no-tags origin         main:refs/remotes/origin/main
    git -C "$work" fetch -q --filter=blob:none --no-tags origin         "$commit":refs/aici/candidate
    if ! git -C "$work" merge-base --is-ancestor         refs/aici/candidate refs/remotes/origin/main
    then
        rm -rf "$work"
        fail "$label commit is not merged into $repository main: $commit"
    fi
    rm -rf "$work"
}

: "${AICI_APK:?AICI_APK is required}"
: "${AICI_ROOT:?AICI_ROOT is required}"
: "${AICI_PACKAGER_RECEIPT:?AICI_PACKAGER_RECEIPT is required}"
: "${AICI_PACKAGER_ROOT:?AICI_PACKAGER_ROOT is required}"
: "${AICI_EXPECTED_ABI:?AICI_EXPECTED_ABI is required}"
: "${AICI_SIGNING_LANE:=test}"
: "${AICI_REQUIRE_NO_DEX:=true}"
: "${AICI_RECEIPT_OUTPUT:=aici-android-producer.receipt.tsv}"
: "${AICI_POLICY_REF:?AICI_POLICY_REF is required}"

action_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
require_file "$AICI_APK"
require_file "$AICI_PACKAGER_RECEIPT"
require_file "$AICI_ROOT/ci/build-toolchain.tsv"
require_file "$AICI_PACKAGER_ROOT/apk/build-nativeactivity-apk.sh"

verify_merged_commit "isomorphisms/ai-ci" "$AICI_POLICY_REF" "AICI policy"

packager_schema=$(tsv_value "$AICI_PACKAGER_RECEIPT" schema)
[[ "$packager_schema" == android-ndk-nativeactivity-apk-v1 ]] ||
    fail "unsupported packager receipt schema: $packager_schema"
fail "test-only policy admission probe; producer approval is disabled"
