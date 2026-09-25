#!/bin/sh
set -eu

self_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$self_dir/lib.sh"

tmp=$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/release-shelf-test.XXXXXX")
cleanup() {
    rm -rf "$tmp"
}
trap cleanup 0 1 2 15

make_apk() {
    name=$1
    shift
    root="$tmp/$name-root"
    rm -rf "$root"
    mkdir -p "$root"
    printf 'manifest\n' > "$root/AndroidManifest.xml"
    for abi in "$@"; do
        mkdir -p "$root/lib/$abi"
        printf 'native\n' > "$root/lib/$abi/libfixture.so"
    done
    (
        cd "$root"
        zip -qr "$tmp/$name.apk" .
    )
}

make_apk pure
make_apk phone armeabi-v7a
make_apk tablet arm64-v8a
make_apk both armeabi-v7a arm64-v8a

[ "$(release_shelf_apk_abis "$tmp/pure.apk")" = "-" ]
[ "$(release_shelf_apk_abis "$tmp/phone.apk")" = "armeabi-v7a" ]
[ "$(release_shelf_apk_abis "$tmp/tablet.apk")" = "arm64-v8a" ]
[ "$(release_shelf_apk_abis "$tmp/both.apk")" = "arm64-v8a,armeabi-v7a" ]

printf 'not a zip\n' > "$tmp/bad.apk"
if release_shelf_apk_abis "$tmp/bad.apk" >/dev/null 2>&1; then
    printf '%s\n' 'bad APK ZIP was accepted' >&2
    exit 1
fi

printf 'dex\n035\000fixture-body\n' > "$tmp/classes.dex"
release_shelf_is_dex "$tmp/classes.dex"

printf 'not-dex\n' > "$tmp/not.dex"
if release_shelf_is_dex "$tmp/not.dex"; then
    printf '%s\n' 'bad DEX magic was accepted' >&2
    exit 1
fi

mkdir -p "$tmp/zip-root/nested"
cp "$tmp/classes.dex" "$tmp/zip-root/nested/classes.dex"
printf 'other\n' > "$tmp/zip-root/readme.txt"
(
    cd "$tmp/zip-root"
    zip -qr "$tmp/bundle.zip" .
)

members=$(release_shelf_list_dex_members "$tmp/bundle.zip")
[ "$members" = "nested/classes.dex" ]
release_shelf_extract_dex_member "$tmp/bundle.zip" "nested/classes.dex" "$tmp/from-zip.dex"
cmp "$tmp/classes.dex" "$tmp/from-zip.dex"

mkdir -p "$tmp/tar-root/deep"
cp "$tmp/classes.dex" "$tmp/tar-root/deep/program.dex"
(
    cd "$tmp/tar-root"
    tar -czf "$tmp/bundle.tar.gz" .
)

members=$(release_shelf_list_dex_members "$tmp/bundle.tar.gz")
printf '%s\n' "$members" | grep -q 'program\.dex$'
member=$(printf '%s\n' "$members" | sed -n '1p')
release_shelf_extract_dex_member "$tmp/bundle.tar.gz" "$member" "$tmp/from-tar.dex"
cmp "$tmp/classes.dex" "$tmp/from-tar.dex"

mkdir -p "$tmp/no-dex"
printf 'none\n' > "$tmp/no-dex/readme.txt"
(
    cd "$tmp/no-dex"
    zip -qr "$tmp/no-dex.zip" .
)
[ -z "$(release_shelf_list_dex_members "$tmp/no-dex.zip")" ]

[ "$(release_shelf_safe_name 'owner/repo release:1')" = "owner-repo-release-1" ]

printf '%s\n' 'release shelf self-test: PASS'
