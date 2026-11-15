#!/bin/sh
# Independent oracle fixtures. Every failing case mutates one observed field,
# commit boundary or byte string after first proving a correct v2 source passes.
set -eu
export LC_ALL=C
dir=$(CDPATH='' cd -- "$(dirname "$0")" && pwd)
oracle=$dir/verify.sh
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM
root="$work/arena"
mkdir -m 700 "$root" "$root/receipts" "$root/staging"
printf '<p>Independent Arena HTML</p>\n' > "$work/page"
bytes=$(wc -c < "$work/page" | tr -d '[:space:]')
digest=$(sha256sum "$work/page" | cut -d ' ' -f 1)
truncate -s 8192 "$root/responses.arena"
dd if="$work/page" of="$root/responses.arena" bs=65536 conv=notrunc status=none
printf '%s\n' "$bytes" > "$root/responses.arena.used"
: > "$root/responses.arena.lock"
request=verified
generation=17
url=https://example.com/starting
receipt="$root/receipts/$request.tsv"

{
    printf 'schema\tib-icu-arena-v2\n'
    printf 'request_id\tverified\n'
    printf 'source_key\tarena:verified\n'
    printf 'source_generation\t17\n'
    printf 'requested_url\t%s\n' "$url"
    printf 'resolved_url\thttps://example.com/after-one-redirect\n'
    printf 'http_status\t200\n'
    printf 'mime_type\ttext/html\n'
    printf 'charset\tutf-8\n'
    printf 'content_encoding\tidentity\n'
    printf 'utf8\tvalid\n'
    printf 'redirect_count\t1\n'
    printf 'declared_length\t%s\n' "$bytes"
    printf 'received_length\t%s\n' "$bytes"
    printf 'transport\ticu-app-process-via-binder-shizuku\n'
    printf 'arena_name\tresponses.arena\n'
    printf 'arena_offset\t0\n'
    printf 'arena_end\t%s\n' "$bytes"
    printf 'byte_count\t%s\n' "$bytes"
    printf 'sha256\t%s\n' "$digest"
    printf 'reopen_check\tMATCH\n'
    printf 'acquisition_complete\tYES\n'
    printf 'navigation_admitted\tYES\n'
} > "$receipt"
cp "$receipt" "$work/good.tsv"
sh "$oracle" "$root" "$request" "$generation" "$url" > "$work/positive"
grep -Fx "$(printf 'PASS\tib-source-v2-admitted\tverified\t17\t%s\t%s' "$bytes" "$digest")" "$work/positive"

reject() {
    name=$1
    if sh "$oracle" "$root" "$request" "$generation" "$url" \
        > "$work/rejected.stdout" 2> "$work/rejected.stderr"; then
        printf 'ACCEPTED BAD SOURCE: %s\n' "$name" >&2
        exit 1
    fi
    test ! -s "$work/rejected.stdout" || {
        printf 'emitted acceptance for bad source: %s\n' "$name" >&2
        exit 1
    }
    test -s "$work/rejected.stderr"
    printf 'REJECT\t%s\n' "$name"
}
mutate() {
    name=$1 key=$2 new=$3
    awk -F '\t' -v OFS='\t' -v key="$key" -v replacement="$new" '
        $1==key {$2=replacement; replaced++} {print}
        END {if (replaced!=1) exit 1}
    ' "$work/good.tsv" > "$receipt"
    reject "$name"
}
mutate legacy-schema schema ib-icu-arena-v1
mutate wrong-request request_id other
mutate wrong-source-key source_key arena:other
mutate stale-generation source_generation 16
mutate future-generation source_generation 18
mutate wrong-request-url requested_url https://example.com/other
mutate dangerous-final-url resolved_url 'javascript:alert(1)'
mutate unobserved-final-url resolved_url UNOBSERVED
mutate not-found http_status 404
mutate wrong-mime mime_type text/plain
mutate legacy-charset charset UNOBSERVED
mutate wrong-charset charset iso-8859-1
mutate gzip-unsupported content_encoding gzip
mutate unobserved-utf8 utf8 invalid
mutate redirected-too-far redirect_count 9
mutate bad-declared-length declared_length "$((bytes - 1))"
mutate bad-received-length received_length "$((bytes - 1))"
mutate bad-transport transport direct-reader-network
mutate wrong-store arena_name other.arena
mutate wrong-offset arena_offset 1
mutate wrong-end arena_end "$((bytes + 1))"
mutate wrong-body-count byte_count "$((bytes - 1))"
mutate forged-sha sha256 0000000000000000000000000000000000000000000000000000000000000000
mutate absent-reopen reopen_check UNOBSERVED
mutate incomplete acquisition_complete NO
mutate not-admitted navigation_admitted NO
mutate noncanonical-generation source_generation 017
mutate bad-redirect-text redirect_count bad
mutate bad-hex-sha sha256 a
# Duplicate and absent fields cannot be added to the schema unnoticed.
cp "$work/good.tsv" "$receipt"
printf 'http_status\t200\n' >> "$receipt"
reject duplicate-status
awk -F '\t' '$1!="mime_type"{print}' "$work/good.tsv" > "$receipt"
reject missing-mime
cp "$work/good.tsv" "$receipt"
printf 'extension_field\tYES\n' >> "$receipt"
reject extension-field
cp "$work/good.tsv" "$receipt"
printf '\r' >> "$receipt"
reject control
cp "$work/good.tsv" "$receipt"
printf '%s\n' "$((bytes - 1))" > "$root/responses.arena.used"
reject uncommitted-range
printf '9000\n' > "$root/responses.arena.used"
reject used-pointer-outside-capacity
printf '%s\n' "$bytes" > "$root/responses.arena.used"
# Existing hash no longer matches even though source receipt is intact.
printf X | dd of="$root/responses.arena" bs=1 seek=0 conv=notrunc status=none
reject modified-committed-bytes
dd if="$work/page" of="$root/responses.arena" bs=65536 conv=notrunc status=none
# Matching digest is insufficient: the independent reader must verify UTF-8.
printf '\377' | dd of="$root/responses.arena" bs=1 seek=0 conv=notrunc status=none
dd if="$root/responses.arena" of="$work/invalid-utf8" bs=65536 iflag=count_bytes count="$bytes" status=none
invalid_digest=$(sha256sum "$work/invalid-utf8" | cut -d ' ' -f 1)
mutate invalid-utf8-with-matching-hash sha256 "$invalid_digest"
dd if="$work/page" of="$root/responses.arena" bs=65536 conv=notrunc status=none
cp "$work/good.tsv" "$receipt"
chmod 755 "$root"
reject root-readable-by-other-user
chmod 700 "$root"
sh "$oracle" "$root" "$request" "$generation" "$url" > "$work/recovered"
cmp -s "$work/recovered" "$work/positive"
printf 'PASS: independent IB v2 oracle plus negative field, source-generation, commit-pointer, digest, and permission controls\n'
printf 'NOT_RUN: real phone, Binder/PFD and independent HTTP origin attestation\n'
