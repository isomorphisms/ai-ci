#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -ne 2 ]]; then
    echo "usage: $0 PRODUCER VERIFIER" >&2
    exit 2
fi

producer="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
verifier="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"
work="$(mktemp -d "${TMPDIR:-/tmp}/aici-fdroid-producer.XXXXXX")"
trap 'rm -rf "$work"' EXIT

pass() { printf 'PASS producer-self-test %s\n' "$1"; }
fail() { printf 'FAIL producer-self-test %s\n' "$1" >&2; exit 1; }
expect_fail() {
    local label="$1"; shift
    if "$@" >"$work/$label.stdout" 2>"$work/$label.stderr"; then
        fail "$label unexpectedly passed"
    fi
    pass "$label"
}

make_repo() {
    local path="$1" content="$2"
    mkdir -p "$path"
    git -C "$path" init -q
    git -C "$path" config user.email producer-test@example.invalid
    git -C "$path" config user.name producer-test
    printf '%s\n' "$content" > "$path/content.txt"
    git -C "$path" add content.txt
    git -C "$path" commit -qm initial
}

make_apk() {
    local output="$1" extra="${2:-}"
    local tree="$work/apk-tree"
    rm -rf "$tree"
    mkdir -p "$tree/lib/armeabi-v7a" "$tree/lib/arm64-v8a"
    printf 'manifest\n' > "$tree/AndroidManifest.xml"
    printf 'armv7\n' > "$tree/lib/armeabi-v7a/libgame.so"
    printf 'arm64\n' > "$tree/lib/arm64-v8a/libgame.so"
    test -z "$extra" || printf '%s\n' "$extra" > "$tree/$extra"
    (cd "$tree" && zip -q -r "$output" AndroidManifest.xml lib ${extra:+"$extra"})
}

make_bad_abi_apk() {
    local output="$1" tree="$work/bad-apk-tree"
    rm -rf "$tree"
    mkdir -p "$tree/lib/x86_64"
    printf 'manifest\n' > "$tree/AndroidManifest.xml"
    printf 'x86\n' > "$tree/lib/x86_64/libgame.so"
    (cd "$tree" && zip -q -r "$output" AndroidManifest.xml lib)
}

make_repo "$work/source" source
make_repo "$work/fdroiddata" fdroiddata
make_repo "$work/fdroidserver" fdroidserver
source_revision="$(git -C "$work/source" rev-parse HEAD)"
fdroiddata_revision="$(git -C "$work/fdroiddata" rev-parse HEAD)"
fdroidserver_revision="$(git -C "$work/fdroidserver" rev-parse HEAD)"

git init -q --bare "$work/public.git"
git -C "$work/source" remote add origin "$work/public.git"
git -C "$work/source" push -q origin HEAD:refs/heads/main

image_digest="registry.example.invalid/fdroid/buildserver@sha256:$(printf 'a%.0s' {1..64})"
cat > "$work/contract.tsv" <<CONTRACT
receipt	TEST-RECEIPT
release	TEST-RELEASE	org.example.game	1.0.0	100	$source_revision
toolchain	TEST-TOOLCHAIN	$fdroiddata_revision	$fdroidserver_revision	$image_digest
profile	candidate-v1
signing	fdroid
native	yes
artifact	TEST-ARTIFACT-ONE	rebuild-one	rebuild	org.example.game	1.0.0	100	armeabi-v7a,arm64-v8a
artifact	TEST-ARTIFACT-TWO	rebuild-two	rebuild	org.example.game	1.0.0	100	armeabi-v7a,arm64-v8a
same_artifact	TEST-REPRODUCIBLE	rebuild-one	rebuild-two
CONTRACT

mkdir -p "$work/bin"
cat > "$work/bin/docker" <<DOCKER
#!/bin/sh
printf '%s\\n' '$image_digest'
DOCKER
chmod +x "$work/bin/docker"
cat > "$work/bin/aapt2" <<'AAPT'
#!/bin/sh
printf "package: name='org.example.game' versionCode='100' versionName='1.0.0'\n"
AAPT
chmod +x "$work/bin/aapt2"
cat > "$work/bin/aapt2-bad" <<'AAPT'
#!/bin/sh
printf "package: name='org.example.other' versionCode='100' versionName='1.0.0'\n"
AAPT
chmod +x "$work/bin/aapt2-bad"
export PATH="$work/bin:$PATH"

play="$work/play"
mkdir -p "$play/listings/en-US/graphics/icon" \
    "$play/listings/en-US/graphics/phone-screenshots" \
    "$play/release-notes/en-US"
for name in title.txt short-description.txt full-description.txt; do printf 'metadata\n' > "$play/listings/en-US/$name"; done
printf 'icon\n' > "$play/listings/en-US/graphics/icon/icon.png"
printf 'screen\n' > "$play/listings/en-US/graphics/phone-screenshots/1.png"
printf 'release\n' > "$play/release-notes/en-US/default.txt"

make_apk "$work/good.apk"
make_apk "$work/different.apk" extra.txt
make_bad_abi_apk "$work/bad-abi.apk"

good="$work/good"
"$producer" init "$work/contract.tsv" "$good"
"$producer" source "$work/contract.tsv" "$good" "$work/source" "$work/public.git"
"$producer" toolchain-revision "$work/contract.tsv" "$good" fdroiddata "$work/fdroiddata"
"$producer" toolchain-revision "$work/contract.tsv" "$good" fdroidserver "$work/fdroidserver"
"$producer" buildserver-image "$work/contract.tsv" "$good" "$image_digest"

for check in \
    tag-binding version-history metadata-read metadata-schema metadata-rewrite \
    metadata-lint update-check git-redirect metadata-tools fdroid-build gradle-audit \
    build-input-pinning source-scan apk-scan signing-policy install-launch; do
    "$producer" check "$work/contract.tsv" "$good" "$check" -- sh -c 'printf "executed check\n"'
done

"$producer" fastlane "$work/contract.tsv" "$good" "$play" "$work/legacy-fastlane" -- \
    sh -c 'printf "[{\"severity\":\"minor\",\"description\":\"checked\"}]\n"'

for check in license-review dependency-review; do
    printf 'manual-policy-v1\t%s\t%s\tpass\treviewer\t2026-09-23T00:00:00Z\treviewed exact source\n' \
        "$check" "$source_revision" > "$work/$check.tsv"
    "$producer" manual-policy "$work/contract.tsv" "$good" "$check" "$work/$check.tsv"
done

"$producer" artifact "$work/contract.tsv" "$good" rebuild-one "$work/good.apk"
"$producer" artifact "$work/contract.tsv" "$good" rebuild-two "$work/good.apk"
"$producer" apk-identity "$work/contract.tsv" "$good" rebuild-one "$work/bin/aapt2" "$good/artifacts/rebuild-one.apk"
"$producer" finish "$work/contract.tsv" "$good" "$good/receipt.tsv" >/dev/null
"$verifier" verify "$work/contract.tsv" "$good/receipt.tsv" "$good" >/dev/null
pass good-candidate

# A source checkout that drifted after the contract was bound cannot become pass.
printf 'drift\n' >> "$work/source/content.txt"
git -C "$work/source" add content.txt
git -C "$work/source" commit -qm drift
stale_source="$work/stale-source"
"$producer" init "$work/contract.tsv" "$stale_source"
expect_fail stale-source "$producer" source "$work/contract.tsv" "$stale_source" "$work/source" "$work/public.git"
"$producer" finish "$work/contract.tsv" "$stale_source" "$stale_source/receipt.tsv" >/dev/null
awk -F '\t' '$1 == "release" && $2 == "identity" && $3 == "fail" { found=1 } END { exit !found }' "$stale_source/receipt.tsv" || fail stale-source-status
pass stale-source-status

# fdroiddata and fdroidserver are observed independently.
for component in fdroiddata fdroidserver; do
    printf 'drift\n' >> "$work/$component/content.txt"
    git -C "$work/$component" add content.txt
    git -C "$work/$component" commit -qm drift
    root="$work/stale-$component"
    "$producer" init "$work/contract.tsv" "$root"
    expect_fail "stale-$component" "$producer" toolchain-revision "$work/contract.tsv" "$root" "$component" "$work/$component"
    "$producer" finish "$work/contract.tsv" "$root" "$root/receipt.tsv" >/dev/null
    awk -F '\t' '$1 == "toolchain" && $2 == "buildserver" && $3 == "fail" { found=1 } END { exit !found }' "$root/receipt.tsv" || fail "stale-$component-status"
    pass "stale-$component-status"
done

# A mutable contract image is rejected before any receipt is produced.
sed "s|$image_digest|registry.example.invalid/fdroid/buildserver:latest|" "$work/contract.tsv" > "$work/mutable-image.contract.tsv"
expect_fail mutable-image-contract "$producer" init "$work/mutable-image.contract.tsv" "$work/mutable-image"

# An immutable contract is not enough: the image observed by docker must match it.
cat > "$work/bin/docker" <<'DOCKER'
#!/bin/sh
printf '%s\n' 'registry.example.invalid/fdroid/buildserver@sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
DOCKER
chmod +x "$work/bin/docker"
wrong_image="$work/wrong-image"
"$producer" init "$work/contract.tsv" "$wrong_image"
expect_fail wrong-image-observation "$producer" buildserver-image "$work/contract.tsv" "$wrong_image" "$image_digest"

# Exit failure creates fail evidence, never a pass row.
failed_check="$work/failed-check"
"$producer" init "$work/contract.tsv" "$failed_check"
expect_fail failed-check "$producer" check "$work/contract.tsv" "$failed_check" metadata-lint -- sh -c 'printf bad; exit 7'
"$producer" finish "$work/contract.tsv" "$failed_check" "$failed_check/receipt.tsv" >/dev/null
awk -F '\t' '$1 == "check" && $2 == "metadata-lint" && $3 == "fail" { found=1 } END { exit !found }' "$failed_check/receipt.tsv" || fail failed-check-status
pass failed-check-status

# A missing or mutated witness cannot be re-hashed into pass by finish.
missing="$work/missing-witness"
"$producer" init "$work/contract.tsv" "$missing"
"$producer" check "$work/contract.tsv" "$missing" metadata-schema -- sh -c 'printf ok'
rm "$missing/witnesses/checks/metadata-schema.log"
"$producer" finish "$work/contract.tsv" "$missing" "$missing/receipt.tsv" >/dev/null
awk -F '\t' '$1 == "check" && $2 == "metadata-schema" && $3 == "not-verified" { found=1 } END { exit !found }' "$missing/receipt.tsv" || fail missing-witness-status
pass missing-witness-status

mutated="$work/mutated-witness"
"$producer" init "$work/contract.tsv" "$mutated"
"$producer" check "$work/contract.tsv" "$mutated" metadata-schema -- sh -c 'printf ok'
printf 'tampered\n' >> "$mutated/witnesses/checks/metadata-schema.log"
"$producer" finish "$work/contract.tsv" "$mutated" "$mutated/receipt.tsv" >/dev/null
awk -F '\t' '$1 == "check" && $2 == "metadata-schema" && $3 == "fail" { found=1 } END { exit !found }' "$mutated/receipt.tsv" || fail mutated-witness-status
pass mutated-witness-status

# Exit zero is insufficient for the legacy-named source-metadata checker.
fastlane_bad="$work/fastlane-bad"
"$producer" init "$work/contract.tsv" "$fastlane_bad"
expect_fail fastlane-major "$producer" fastlane "$work/contract.tsv" "$fastlane_bad" "$play" "$work/legacy-fastlane" -- \
    sh -c 'printf "[{\"severity\":\"major\",\"description\":\"bad\"}]\n"'

# Manual review must name the same exact source revision.
manual_bad="$work/manual-bad"
"$producer" init "$work/contract.tsv" "$manual_bad"
printf 'manual-policy-v1\tlicense-review\t%s\tpass\treviewer\t2026-09-23T00:00:00Z\tstale review\n' \
    "$(printf '0%.0s' {1..40})" > "$work/stale-review.tsv"
expect_fail stale-manual-review "$producer" manual-policy "$work/contract.tsv" "$manual_bad" license-review "$work/stale-review.tsv"

# Finished APK bytes must have the contract ABI inventory and identity.
bad_artifact="$work/bad-artifact"
"$producer" init "$work/contract.tsv" "$bad_artifact"
expect_fail bad-artifact-abi "$producer" artifact "$work/contract.tsv" "$bad_artifact" rebuild-one "$work/bad-abi.apk"

bad_identity="$work/bad-identity"
"$producer" init "$work/contract.tsv" "$bad_identity"
expect_fail bad-apk-identity "$producer" apk-identity "$work/contract.tsv" "$bad_identity" rebuild-one "$work/bin/aapt2-bad" "$work/good.apk"

# Reproducibility stays a comparison of two finished APK artifacts.
repro_bad="$work/repro-bad"
cp -a "$good" "$repro_bad"
"$producer" artifact "$work/contract.tsv" "$repro_bad" rebuild-two "$work/different.apk"
"$producer" finish "$work/contract.tsv" "$repro_bad" "$repro_bad/receipt.tsv" >/dev/null
if "$verifier" verify "$work/contract.tsv" "$repro_bad/receipt.tsv" "$repro_bad" >"$work/repro.stdout" 2>"$work/repro.stderr"; then
    fail reproducibility-mismatch
fi
grep -Fq '"code":"TEST-REPRODUCIBLE"' "$work/repro.stdout" || fail reproducibility-diagnostic
pass reproducibility-mismatch

# The producer cannot be used to manufacture later F-Droid profiles.
sed 's/^profile\tcandidate-v1$/profile\tsubmission-v1/' "$work/contract.tsv" > "$work/submission.contract.tsv"
expect_fail submission-profile "$producer" init "$work/submission.contract.tsv" "$work/submission"
sed 's/^profile\tcandidate-v1$/profile\tpublication-v1/' "$work/contract.tsv" > "$work/publication.contract.tsv"
expect_fail publication-profile "$producer" init "$work/publication.contract.tsv" "$work/publication"

printf 'PASS producer-self-test all\n'
