#!/usr/bin/env bash
# Independent byte-level Android companion gate. Successful verification is
# NOT build, install, runtime, F-Droid, or physical-device acceptance.
set -Eeuo pipefail
fail() { printf 'AICI Android companion: %s\n' "$*" >&2; exit 2; }
[[ $# -eq 5 ]] || fail 'usage: verify.sh CATFOOD_ROOT APP_ROOT APP_CONTRACT PLAN APK_MAP'
catfood=$1
app=$2
contract=$3
plan=$4
map=$5
aici=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
for f in "$contract" "$plan" "$map"; do [[ -f "$f" ]] || fail "missing input: $f"; done
for d in "$catfood" "$app"; do [[ -d "$d/.git" ]] || fail "not a Git checkout: $d"; done
: "${AICI_COMPANION_RECEIPT:?exact receipt output path required}"
[[ ! -e "$AICI_COMPANION_RECEIPT" ]] || fail 'refuse to overwrite an accepted receipt'
for command in git awk sha256sum unzip readelf cc; do command -v "$command" >/dev/null || fail "missing $command"; done
sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
[[ -n "$sdk" ]] || fail 'Android SDK path is required'
buildtools="${AICI_ANDROID_BUILD_TOOLS:-$sdk/build-tools/36.0.0}"
aapt2="$buildtools/aapt2"
apksigner="$buildtools/apksigner"
[[ -x "$aapt2" && -x "$apksigner" ]] || fail 'Android aapt2 and apksigner are required'

# Replay the exact Cat Food planner from the exact application source and
# reject source or material-plan tampering. A checkout's local branch name is
# never sufficient publication authority.
source_sha=$(git -C "$app" rev-parse HEAD)
catfood_sha=$(git -C "$catfood" rev-parse HEAD)
for digest in "$source_sha" "$catfood_sha"; do
    [[ "$digest" =~ ^[0-9a-f]{40}$ ]] || fail 'source/policy revision must be full SHA'
done
git -C "$app" ls-files --error-unmatch "$contract" >/dev/null 2>&1 ||
    fail 'application contract is not tracked in source checkout'
git -C "$app" diff --quiet HEAD -- "$contract" ||
    fail 'application contract has uncommitted changes'
get() {
    awk -F '\t' -v key="$1" '$1==key {print $2}' "$plan"
}
[[ "$(get source_sha)" == "$source_sha" ]] || fail 'source commit differs from plan'
[[ "$(get catfood_commit)" == "$catfood_sha" ]] || fail 'Cat Food revision differs from plan'
requested=$(get requested_target)
[[ "$requested" == phone || "$requested" == c67 ]] ||
    fail 'unknown target in plan'
tmp=$(mktemp -d "${RUNNER_TEMP:-/tmp}/aici-android-companion.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
sh "$catfood/catfood" plan-android-build "$contract" "$requested" "$source_sha" > "$tmp/replay.tsv"
cmp "$plan" "$tmp/replay.tsv" || fail 'Cat Food plan is not canonical for inputs'
# An unmerged Cat Food PR can be exercised as a candidate but cannot issue
# production-valid artifact receipts. Fetch main rather than trusting a local ref.
git -C "$catfood" fetch --quiet --no-tags origin main:refs/remotes/origin/main ||
    fail 'cannot validate Cat Food main authority'
git -C "$catfood" merge-base --is-ancestor "$catfood_sha" refs/remotes/origin/main ||
    fail 'Cat Food policy revision is not approved main history'

awk -F '\t' '
    NR==1 {if($0!="target\tapk") exit 2; next}
    NF!=2 || $2!~/^\// || ($1!="phone" && $1!="c67") || seen[$1]++ {exit 2}
    END {if(NR<2) exit 2}
' "$map" || fail 'invalid APK map; expected unique target and absolute APK path'
package=$(get package_id)
label=$(get launcher_label)
packaging=$(get packaging)
min_sdk=$(get min_sdk)
[[ -n "$package" && -n "$label" && "$min_sdk" =~ ^[0-9]+$ ]] ||
    fail 'missing immutable package, launcher label or SDK'
[[ "$packaging" == split || "$packaging" == shared ]] || fail 'unknown packaging shape'
cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 "$aici/src/aici_android_signing.c" \
    -o "$tmp/signing-verifier"
declare -a verified=()
for target in phone c67; do
    row=$(awk -F '\t' -v target="$target" '$1==target {print $0}' "$plan")
    apk=$(awk -F '\t' -v target="$target" '$1==target {print $2}' "$map")
    if [[ -z "$row" ]]; then [[ -z "$apk" ]] || fail "unexpected $target APK"; continue; fi
    IFS=$'\t' read -r row_target device abi obligation acceptance <<< "$row"
    [[ "$acceptance" == not_run ]] || fail 'plan cannot contain accepted runtime evidence'
    case "$obligation" in
        incompatible) [[ -z "$apk" ]] || fail "incompatible $target received APK"; continue ;;
        blocked) fail "$target unresolved compatibility blocks acceptance" ;;
        required) [[ -f "$apk" ]] || fail "required $target APK is missing" ;;
        *) fail "unrecognized $target obligation: $obligation" ;;
    esac
    badging=$("$aapt2" dump badging "$apk") || fail "bad APK: $target"
    observed_package=$(printf '%s\n' "$badging" |
      sed -n "s/^package: name='\([^']*\)'.*/\1/p" | head -1)
    version=$(printf '%s\n' "$badging" |
      sed -n "s/^package: .*versionCode='\([^']*\)'.*/\1/p" | head -1)
    observed_sdk=$(printf '%s\n' "$badging" |
      sed -n "s/^sdkVersion:'\([^']*\)'.*/\1/p" | head -1)
    observed_label=$(printf '%s\n' "$badging" |
      sed -n -e "s/^application-label:'\(.*\)'$/\1/p" \
             -e "s/^application: label='\([^']*\)'.*/\1/p" | head -1)
    observed_launcher=$(printf '%s\n' "$badging" |
      sed -n "s/^launchable-activity: name='\([^']*\)'.*/\1/p" | head -1)
    observed_launcher_label=$(printf '%s\n' "$badging" |
      sed -n "s/^launchable-activity:.* label='\([^']*\)'.*/\1/p" | head -1)
    [[ "$observed_package" == "$package" ]] || fail "$target package changed"
    [[ "$observed_label" == "$label" ]] ||
        fail "$target launcher label changed: expected $label got $observed_label"
    [[ -n "$observed_launcher" ]] || fail "$target launcher activity is missing"
    [[ "$observed_launcher_label" == "$label" ]] ||
        fail "$target launcher activity label changed: expected $label got ${observed_launcher_label:-missing}"
    [[ "$version" =~ ^[0-9]+$ ]] || fail "$target versionCode missing"
    [[ "$observed_sdk" == "$min_sdk" ]] || fail "$target minSdk changed"
    "$apksigner" verify --verbose --print-certs "$apk" > "$tmp/signer-$target.txt" ||
        fail "$target signature verification failed"
    signer=$(sed -n 's/^.*certificate SHA-256 digest:[[:space:]]*//p' "$tmp/signer-$target.txt" |
      tr '[:upper:]' '[:lower:]' | tr -d ':[:space:]' | sort -u)
    [[ "$signer" =~ ^[0-9a-f]{64}$ ]] || fail "$target signer missing or ambiguous"
    "$tmp/signing-verifier" verify "$aici/android-signing/identities.tsv" "$package" test "$signer" ||
        fail "$target did not match central test signer"
    entry=$(unzip -Z1 "$apk" | grep -E "^lib/$abi/[^/]+\\.so$" | head -1) ||
        fail "$target native ABI $abi missing"
    [[ -n "$entry" ]] || fail "$target native library is missing"
    unzip -p "$apk" "$entry" > "$tmp/$target.so"
    readelf -h "$tmp/$target.so" > "$tmp/$target.elf"
    if [[ "$abi" == armeabi-v7a ]]; then
        grep -q 'Class:.*ELF32' "$tmp/$target.elf" || fail 'wrong ELF class A1'
        grep -Eq 'Machine:.*ARM$' "$tmp/$target.elf" || fail 'wrong ELF machine A1'
    else
        grep -q 'Class:.*ELF64' "$tmp/$target.elf" || fail 'wrong ELF class C67'
        grep -q 'Machine:.*AArch64' "$tmp/$target.elf" || fail 'wrong ELF machine C67'
    fi
    verified+=("$target"$'\t'"$abi"$'\t'"$(sha256sum "$apk" | awk '{print $1}')")
done
[[ "${#verified[@]}" -gt 0 ]] || fail 'no required APK qualified'
required_count=$(awk -F '\t' 'NF==5 && $4=="required" {n++} END {print n+0}' "$plan")
if [[ "${#verified[@]}" -ne "$required_count" ]]; then
    fail 'required companion rows were not all qualified'
fi
first_sha=$(printf '%s\n' "${verified[0]}" | cut -f3)
if [[ "${#verified[@]}" -eq 2 ]]; then
    second_sha=$(printf '%s\n' "${verified[1]}" | cut -f3)
    if [[ "$packaging" == shared ]]; then
        [[ "$first_sha" == "$second_sha" ]] || fail 'shared artifact group changed APK'
    else
        [[ "$first_sha" != "$second_sha" ]] || fail 'split APKs unexpectedly identical'
    fi
fi
mkdir -p "$(dirname -- "$AICI_COMPANION_RECEIPT")"
{
    printf 'schema\taici-android-companion-artifact-v1\n'
    printf 'status\tPASS\n'
    printf 'catfood_commit\t%s\n' "$catfood_sha"
    printf 'source_sha\t%s\n' "$source_sha"
    printf 'plan_sha256\t%s\n' "$(sha256sum "$plan" | awk '{print $1}')"
    printf 'package\t%s\n' "$package"
    printf 'label\t%s\n' "$label"
    printf 'signing_lane\ttest\n'
    printf '%s\n' "${verified[@]}"
    printf 'build\tNOT_VERIFIED\ninstall\tNOT_VERIFIED\nruntime\tNOT_VERIFIED\nphysical\tNOT_VERIFIED\n'
} > "$AICI_COMPANION_RECEIPT"
printf 'AICI_ANDROID_COMPANION_ARTIFACT\tPASS\n'
