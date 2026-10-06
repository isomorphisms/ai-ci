#!/usr/bin/env bash
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
: "${AICI_EXPECTED_ABI:?AICI_EXPECTED_ABI is required}"
: "${AICI_SIGNING_LANE:=test}"
: "${AICI_REQUIRE_NO_DEX:=true}"
: "${AICI_RECEIPT_OUTPUT:=aici-android-producer.receipt.tsv}"
: "${AICI_POLICY_REF:?AICI_POLICY_REF is required}"

action_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
require_file "$AICI_APK"
require_file "$AICI_PACKAGER_RECEIPT"
require_file "$AICI_ROOT/ci/build-toolchain.tsv"

verify_merged_commit "isomorphisms/ai-ci" "$AICI_POLICY_REF" "AICI policy"

packager_schema=$(tsv_value "$AICI_PACKAGER_RECEIPT" schema)
[[ "$packager_schema" == android-ndk-nativeactivity-apk-v1 ]] ||
    fail "unsupported packager receipt schema: $packager_schema"
packager_commit=$(tsv_value "$AICI_PACKAGER_RECEIPT" packager_commit)
verify_merged_commit "isomorphisms/android-NDK" "$packager_commit" "android-NDK packager"

android_home=${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}
[[ -n "$android_home" ]] || fail "ANDROID_HOME/ANDROID_SDK_ROOT is required"
build_tools=$(
    find "$android_home/build-tools" -mindepth 1 -maxdepth 1 -type d |
        sort -V |
        tail -n 1
)
aapt2="$build_tools/aapt2"
apksigner="$build_tools/apksigner"
[[ -x "$aapt2" && -x "$apksigner" ]] ||
    fail "Android build-tools aapt2/apksigner are required"
command -v cc >/dev/null 2>&1 || fail "host C compiler is required for AICI verifier"
command -v sha256sum >/dev/null 2>&1 || fail "sha256sum is required"
command -v unzip >/dev/null 2>&1 || fail "unzip is required"

aici="${RUNNER_TEMP:-/tmp}/aici-android-producer-kernel"
cc -std=c17 -Wall -Wextra -Werror -O2     "$action_root/src/aici.c"     -o "$aici"
"$aici" verify "$action_root/contracts/build-toolchain-v0.contract.tsv" "$AICI_ROOT"

signing_verifier="${RUNNER_TEMP:-/tmp}/aici-android-signing"
cc -std=c17 -Wall -Wextra -Werror -pedantic -O2     "$action_root/src/aici_android_signing.c"     -o "$signing_verifier"

badging=$("$aapt2" dump badging "$AICI_APK")
package=$(
    printf '%s\n' "$badging" |
        sed -n "s/^package: name='\([^']*\)'.*/\1/p" |
        head -n 1
)
version_code=$(
    printf '%s\n' "$badging" |
        sed -n "s/^package: .*versionCode='\([^']*\)'.*/\1/p" |
        head -n 1
)
activity=$(
    printf '%s\n' "$badging" |
        sed -n "s/^launchable-activity: name='\([^']*\)'.*/\1/p" |
        head -n 1
)
[[ -n "$package" && -n "$version_code" ]] ||
    fail "could not extract package/versionCode from APK"
[[ "$activity" == android.app.NativeActivity ]] ||
    fail "APK launcher is not android.app.NativeActivity: ${activity:-missing}"

cert_report=$("$apksigner" verify --verbose --print-certs "$AICI_APK" 2>&1)
printf '%s\n' "$cert_report"
signer=$(
    printf '%s\n' "$cert_report" |
        sed -n 's/^.*certificate SHA-256 digest:[[:space:]]*//p' |
        tr '[:upper:]' '[:lower:]' |
        tr -d ':[:space:]' |
        sort -u
)
[[ -n "$signer" && "$signer" != *$'\n'* ]] ||
    fail "APK must contain exactly one signer certificate"
"$signing_verifier" verify     "$action_root/android-signing/identities.tsv"     "$package"     "$AICI_SIGNING_LANE"     "$signer"

apk_sha=$(sha256sum "$AICI_APK" | awk '{print $1}')
receipt_package=$(tsv_value "$AICI_PACKAGER_RECEIPT" package)
receipt_version=$(tsv_value "$AICI_PACKAGER_RECEIPT" version_code)
receipt_abi=$(tsv_value "$AICI_PACKAGER_RECEIPT" abi)
receipt_apk_sha=$(tsv_value "$AICI_PACKAGER_RECEIPT" apk_sha256)
receipt_signer=$(tsv_value "$AICI_PACKAGER_RECEIPT" signer_cert_sha256)

[[ "$receipt_package" == "$package" ]] ||
    fail "packager receipt package mismatch: $receipt_package != $package"
[[ "$receipt_version" == "$version_code" ]] ||
    fail "packager receipt versionCode mismatch: $receipt_version != $version_code"
[[ "$receipt_abi" == "$AICI_EXPECTED_ABI" ]] ||
    fail "packager receipt ABI mismatch: $receipt_abi != $AICI_EXPECTED_ABI"
[[ "$receipt_apk_sha" == "$apk_sha" ]] ||
    fail "packager receipt APK digest mismatch"
[[ "$receipt_signer" == "$signer" ]] ||
    fail "packager receipt signer mismatch"

abis=$(
    unzip -Z1 "$AICI_APK" |
        sed -n 's#^lib/\([^/]*\)/.*#\1#p' |
        sort -u
)
[[ "$abis" == "$AICI_EXPECTED_ABI" ]] ||
    fail "APK native ABI set mismatch: expected $AICI_EXPECTED_ABI got ${abis:-none}"

case "$AICI_REQUIRE_NO_DEX" in
    true|1|yes)
        if unzip -Z1 "$AICI_APK" | grep -Eq '(^|/)classes[0-9]*\.dex$'; then
            fail "direct NativeActivity APK unexpectedly contains DEX"
        fi
        ;;
    false|0|no) ;;
    *) fail "invalid AICI_REQUIRE_NO_DEX value: $AICI_REQUIRE_NO_DEX" ;;
esac

update_status=NOT_VERIFIED
prior_sha=-
if [[ -n ${AICI_PRIOR_RECEIPT:-} ]]; then
    require_file "$AICI_PRIOR_RECEIPT"
    prior_package=$(tsv_value "$AICI_PRIOR_RECEIPT" package)
    prior_signer=$(tsv_value "$AICI_PRIOR_RECEIPT" signer_cert_sha256)
    prior_version=$(tsv_value "$AICI_PRIOR_RECEIPT" version_code)
    prior_sha=$(tsv_value "$AICI_PRIOR_RECEIPT" apk_sha256)

    [[ "$prior_package" == "$package" ]] ||
        fail "package identity changed from prior accepted receipt"
    [[ "$prior_signer" == "$signer" ]] ||
        fail "signer identity changed from prior accepted receipt"
    [[ "$prior_version" =~ ^[0-9]+$ && "$version_code" =~ ^[0-9]+$ ]] ||
        fail "versionCode must be numeric for update comparison"
    (( version_code >= prior_version )) ||
        fail "versionCode regressed: $version_code < $prior_version"
    update_status=PASS
fi

mkdir -p "$(dirname -- "$AICI_RECEIPT_OUTPUT")"
{
    printf 'schema\taici-android-producer-v1\n'
    printf 'result\tPASS\n'
    printf 'policy_commit\t%s\n' "$AICI_POLICY_REF"
    printf 'packager_commit\t%s\n' "$packager_commit"
    printf 'package\t%s\n' "$package"
    printf 'version_code\t%s\n' "$version_code"
    printf 'abi\t%s\n' "$AICI_EXPECTED_ABI"
    printf 'signing_lane\t%s\n' "$AICI_SIGNING_LANE"
    printf 'signer_cert_sha256\t%s\n' "$signer"
    printf 'apk_sha256\t%s\n' "$apk_sha"
    printf 'prior_apk_sha256\t%s\n' "$prior_sha"
    printf 'update_identity_result\t%s\n' "$update_status"
} > "$AICI_RECEIPT_OUTPUT"

printf 'AICI_ANDROID_PRODUCER\tPASS\n'
printf 'PACKAGE\t%s\n' "$package"
printf 'VERSION_CODE\t%s\n' "$version_code"
printf 'ABI\t%s\n' "$AICI_EXPECTED_ABI"
printf 'APK_SHA256\t%s\n' "$apk_sha"
printf 'SIGNER_SHA256\t%s\n' "$signer"
printf 'UPDATE_IDENTITY\t%s\n' "$update_status"
printf 'POLICY_COMMIT\t%s\n' "$AICI_POLICY_REF"
printf 'PACKAGER_COMMIT\t%s\n' "$packager_commit"
printf 'RECEIPT\t%s\n' "$AICI_RECEIPT_OUTPUT"
