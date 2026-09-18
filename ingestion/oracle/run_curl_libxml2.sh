#!/bin/sh
set -eu

if [ "$#" -ne 6 ]; then
    echo "usage: $0 CORPUS_ROOT BASE_URL FIXTURE_ID CORPUS_REPOSITORY_REVISION IMPLEMENTATION_REVISION OUTPUT" >&2
    exit 2
fi

corpus_root=$1
base_url=$2
fixture_id=$3
corpus_repository_revision=$4
implementation_revision=$5
output=$6

row=$(awk -F '\t' -v wanted="$fixture_id" 'NR > 1 && $1 == wanted { print; exit }' "$corpus_root/fixtures.tsv")
if [ -z "$row" ]; then
    echo "unknown fixture: $fixture_id" >&2
    exit 2
fi
scheme=$(printf '%s\n' "$row" | cut -f2)
path=$(printf '%s\n' "$row" | cut -f3)
content_encoding=$(printf '%s\n' "$row" | cut -f5)
charset=$(printf '%s\n' "$row" | cut -f6)
corpus_revision=$(sed -n '1p' "$corpus_root/REVISION")

case "$scheme" in
    http) url="$base_url$path" ;;
    https)
        authority=${base_url#http://}
        url="https://$authority$path"
        ;;
    *) echo "unsupported scheme in fixture: $scheme" >&2; exit 2 ;;
esac

work=${RUNNER_TEMP:-/tmp}/aici-oracle-$fixture_id-$$
mkdir -p "$work"
trap 'rm -rf "$work"' EXIT HUP INT TERM
body="$work/body.bin"
headers="$work/headers.txt"
status_file="$work/status.txt"
curl_error="$work/curl.err"

set +e
curl --silent --show-error --location \
    --output "$body" --dump-header "$headers" \
    --write-out '%{http_code}\n' "$url" >"$status_file" 2>"$curl_error"
curl_status=$?
set -e
http_status=$(sed -n '1p' "$status_file")
[ -n "$http_status" ] || http_status=000
curl_sha=$(sha256sum "$(command -v curl)" | cut -d ' ' -f1)

emit_meta() {
    printf 'meta\t%s\t%s\n' "$1" "$2"
}
emit_stage() {
    printf 'stage\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$fixture_id" "$1" "$2" "$3" "$4" "$5"
}
blocked_tail() {
    boundary=$1
    shift
    for stage in "$@"; do
        emit_stage "$stage" SKIP "blocked_by_$boundary" oracle-driver not-run
    done
    printf 'summary\tfirst_failure\t%s\n' "$boundary"
    printf 'summary\tfirst_incomplete\t%s\n' "$boundary"
}

{
    emit_meta schema aici-ingestion-receipt-v1
    emit_meta corpus_revision "$corpus_revision"
    emit_meta corpus_repository_revision "$corpus_repository_revision"
    emit_meta fixture_id "$fixture_id"
    emit_meta implementation_role oracle
    emit_meta implementation_name curl+libxml2+iconv
    emit_meta implementation_revision "$implementation_revision"
    emit_meta executable_sha256 "$curl_sha"
    emit_meta fallback none
    emit_meta scope network-through-document
    emit_meta producer external-oracle-driver
    emit_stage input_acquisition PASS curl_invoked curl attempted

    if [ "$curl_status" -ne 0 ]; then
        case "$fixture_id" in
            truncated_body) code=partial_body ;;
            tls_plaintext) code=tls_handshake_failure ;;
            *) code=curl_failure ;;
        esac
        emit_stage network FAIL "$code" curl "curl_exit=$curl_status;status=$http_status"
        blocked_tail network decompression decoding html_recovery document_construction downstream_extraction
        exit 0
    fi
    if [ "$http_status" -lt 200 ] || [ "$http_status" -ge 300 ]; then
        emit_stage network FAIL non_2xx curl "status=$http_status"
        blocked_tail network decompression decoding html_recovery document_construction downstream_extraction
        exit 0
    fi

    body_size=$(wc -c <"$body" | tr -d ' ')
    emit_stage network PASS complete_response curl "status=$http_status;received_length=$body_size"

    decoded="$work/decoded.bin"
    if [ "$content_encoding" = identity ]; then
        cp "$body" "$decoded"
        emit_stage decompression PASS identity curl identity
    elif [ "$content_encoding" = gzip ]; then
        if gzip -cd "$body" >"$decoded" 2>"$work/gzip.err"; then
            decoded_sha=$(sha256sum "$decoded" | cut -d ' ' -f1)
            emit_stage decompression PASS gzip gzip "decoded_sha256=$decoded_sha"
        else
            emit_stage decompression FAIL truncated_gzip gzip invalid-stream
            blocked_tail decompression decoding html_recovery document_construction downstream_extraction
            exit 0
        fi
    else
        emit_stage decompression FAIL unknown_content_encoding oracle-driver "$content_encoding"
        blocked_tail decompression decoding html_recovery document_construction downstream_extraction
        exit 0
    fi

    if [ "$charset" != utf-8 ]; then
        emit_stage decoding FAIL unknown_charset iconv "$charset"
        blocked_tail decoding html_recovery document_construction downstream_extraction
        exit 0
    fi
    if ! iconv -f UTF-8 -t UTF-8 "$decoded" >"$work/text.html" 2>"$work/iconv.err"; then
        emit_stage decoding FAIL invalid_utf8 iconv invalid-byte-sequence
        blocked_tail decoding html_recovery document_construction downstream_extraction
        exit 0
    fi
    text_size=$(wc -c <"$work/text.html" | tr -d ' ')
    emit_stage decoding PASS utf8_valid iconv "utf8=valid;bytes=$text_size"

    document="$work/document.html"
    if [ ! -s "$work/text.html" ]; then
        : >"$document"
        emit_stage html_recovery PASS empty_document libxml2 recovery=empty
        title=
    elif xmllint --html --recover "$work/text.html" >"$document" 2>"$work/xmllint.err"; then
        emit_stage html_recovery PASS libxml2_recovery libxml2 recovery=libxml2
        title=$(xmllint --html --recover --xpath 'string(//title)' "$document" 2>/dev/null || true)
    else
        emit_stage html_recovery FAIL libxml2_failure libxml2 parse-failed
        blocked_tail html_recovery document_construction downstream_extraction
        exit 0
    fi
    title_key=$(printf '%s' "$title" | tr ' \t\r\n' '_')
    emit_stage document_construction PASS libxml2_document libxml2 "title=$title_key"
    emit_stage downstream_extraction SKIP not_applicable_scope oracle-driver not-run
    printf 'summary\tfirst_failure\tnone\n'
    printf 'summary\tfirst_incomplete\tnone\n'
} >"$output"
