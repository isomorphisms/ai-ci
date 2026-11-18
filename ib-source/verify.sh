#!/bin/sh
# Independently check the IB/ICU v2 admitted source contract, not the IB
# producer/reader code. Host GNU coreutils lane only; never asserts C67 use.
set -eu
export LC_ALL=C

fail() { printf 'ai-ci ib-source: %s\n' "$1" >&2; exit 1; }
test "$#" -eq 4 || fail 'usage: verify.sh PRIVATE_ARENA_ROOT REQUEST_ID NAVIGATION_GENERATION REQUESTED_URL'
root=$1
request=$2
generation=$3
requested=$4

case "$root" in /*) ;; *) fail 'root is not absolute' ;; esac
case "$request" in ''|.|..|*[!a-zA-Z0-9._-]*) fail 'unsafe request identity' ;; esac
test "${#request}" -le 64 || fail 'request identity exceeds native cap'
case "$generation" in ''|0|0*|*[!0-9]*) fail 'noncanonical expected generation' ;; esac
test "${#generation}" -le 18 || fail 'expected generation out of range'
safe_url() {
    case "$1" in http://*|https://*) ;; *) return 1 ;; esac
    test "${#1}" -gt 8 && test "${#1}" -le 2048 || return 1
    printf %s "$1" | grep -Eq '^[!-&(-~]+$'
}
safe_url "$requested" || fail 'unsafe requested URL'
test -d "$root" && test ! -L "$root" || fail 'invalid private root'
root=$(CDPATH='' cd -P -- "$root" && pwd -P) || fail 'private root not accessible'
case "$(stat -c %a "$root")" in 700|0700) ;; *) fail 'nonprivate root' ;; esac
receipt="$root/receipts/$request.tsv"
arena="$root/responses.arena"
used="$root/responses.arena.used"
lock="$root/responses.arena.lock"
for file in "$receipt" "$arena" "$used" "$lock"; do
    test -f "$file" && test ! -L "$file" || fail 'missing, linked, or nonregular Arena file'
done
test "$(wc -c < "$receipt" | tr -d '[:space:]')" -le 16384 || fail 'oversized receipt'
tr -cd '\011\012\040-\176' < "$receipt" | cmp -s - "$receipt" ||
    fail 'control bytes in receipt'
awk -F '\t' '
    BEGIN {
        count=split("schema request_id source_key source_generation requested_url resolved_url http_status mime_type charset content_encoding utf8 redirect_count declared_length received_length transport arena_name arena_offset arena_end byte_count sha256 reopen_check acquisition_complete navigation_admitted", names," ")
        for (i=1;i<=count;i++) allowed[names[i]]=1
        allowed["redirect_chain"]=1
        allowed["transfer_decoding"]=1
    }
    NF!=2 || !allowed[$1] || $2=="" { bad=1 }
    $1=="transfer_decoding" && $2!="identity" && $2!="chunked" { bad=1 }
    { seen[$1]++ }
    END {
        for (i=1;i<=count;i++) if (seen[names[i]]!=1) bad=1
        if (bad || seen["redirect_chain"]>1 || seen["transfer_decoding"]>1 ||
            NR!=count+seen["redirect_chain"]+seen["transfer_decoding"]) exit 1
    }
' "$receipt" || fail 'receipt field set or duplicates invalid'
field() { awk -F '\t' -v key="$1" '$1==key{print $2}' "$receipt"; }

test "$(field schema)" = ib-icu-arena-v2 || fail 'v1/unobserved schema is not admitted'
test "$(field request_id)" = "$request" || fail 'request identity mismatch'
test "$(field source_key)" = "arena:$request" || fail 'source key mismatch'
test "$(field source_generation)" = "$generation" || fail 'stale/wrong source generation'
test "$(field requested_url)" = "$requested" || fail 'original request mismatch'
safe_url "$(field resolved_url)" || fail 'unobserved/unsafe effective URL'
test "$(field http_status)" = 200 || fail 'status does not admit HTML'
test "$(field mime_type)" = text/html || fail 'MIME does not admit HTML'
test "$(field charset)" = utf-8 || fail 'charset not observed UTF-8'
test "$(field content_encoding)" = identity || fail 'encoded payload is not decoded'
test "$(field utf8)" = valid || fail 'native UTF-8 observation missing'
test "$(field transport)" = icu-app-process-via-binder-shizuku || fail 'producer identity mismatch'
test "$(field arena_name)" = responses.arena || fail 'wrong backing store'
test "$(field reopen_check)" = MATCH || fail 'producer reopen evidence missing'
test "$(field acquisition_complete)" = YES || fail 'incomplete request'
test "$(field navigation_admitted)" = YES || fail 'navigation explicitly refused'

canonical_number() {
    case "$1" in ''|*[!0-9]*|0?*|0?*|0[0-9]*) return 1 ;; esac
    test "${#1}" -le 18 || return 1
}
# Zero is allowed for offsets, redirect count and the commit-pointer.
redirects=$(field redirect_count)
canonical_number "$redirects" || fail 'bad redirect count'
test "$redirects" -le 8 || fail 'redirect overflow'
# Independent R1 decoding reads fields from the file itself; -v must not
# reinterpret backslashes in observed URLs. Legacy retained v2 records remain
# readable, while a present chain is mandatory evidence rather than decoration.
awk -F '\t' '
    function initial_projection(request,   scheme, authority, target, host, port, pieces, count) {
        scheme=(request ~ /^https:\/\// ? "https://" : "http://")
        authority=substr(request,length(scheme)+1)
        sub(/[\/?#].*$/,"",authority)
        target=substr(request,length(scheme)+length(authority)+1)
        sub(/#.*/,"",target)
        if (target=="" || substr(target,1,1)=="?") target="/" target
        count=split(authority,pieces,":")
        if (count>2 || pieces[1]=="" || index(authority,"@")) return ""
        host=pieces[1]
        port=(scheme=="https://" ? 443 : 80)
        if (count==2) {
            if (pieces[2] !~ /^[0-9]+$/ || pieces[2]+0<1 || pieces[2]+0>65535) return ""
            port=pieces[2]+0
        }
        return scheme host ((scheme=="https://" && port==443) || (scheme=="http://" && port==80) ? "" : ":" sprintf("%d",port)) target
    }
    function url_part(   head, amount, value, authority) {
        if (!match(rest,/^[1-9][0-9]* /)) { bad=1; return "" }
        head=RLENGTH
        if (head>5) { bad=1; return "" }
        amount=substr(rest,1,head-1)+0
        rest=substr(rest,head+1)
        if (amount>2048 || length(rest)<amount) { bad=1; return "" }
        value=substr(rest,1,amount)
        rest=substr(rest,amount+1)
        if (value !~ /^https?:\/\// || value ~ /[^!-~]/ || index(value,sprintf("%c",39))) { bad=1; return "" }
        authority=value
        sub(/^https?:\/\//,"",authority)
        sub(/[\/?#].*$/,"",authority)
        if (authority=="" || index(authority,"@")) { bad=1; return "" }
        return value
    }
    { fields[$1]=$2 }
    END {
        wire=fields["redirect_chain"]
        if (wire=="") exit 0
        if (substr(wire,1,3)!="R1 " || length(wire)>8192) exit 1
        rest=substr(wire,4)
        value=url_part()
        if (bad || value!=initial_projection(fields["requested_url"])) exit 1
        for (hop=0;hop<fields["redirect_count"]+0;hop++) {
            status=substr(rest,1,3)
            if (status !~ /^(301|302|303|307|308)$/ || substr(rest,4,1)!=" ") exit 1
            rest=substr(rest,5)
            value=url_part()
            if (bad) exit 1
        }
        if (rest!="" || value!=fields["resolved_url"]) exit 1
    }
' "$receipt" || fail 'redirect chain identity, count, status or URL mismatch'
offset=$(field arena_offset)
finish=$(field arena_end)
length=$(field byte_count)
received=$(field received_length)
declared=$(field declared_length)
for n in "$offset" "$finish" "$length" "$received"; do
    canonical_number "$n" || fail 'noncanonical Arena number'
done
test "$length" -gt 0 && test "$length" -le 4194304 || fail 'unbounded/empty content'
test "$received" -eq "$length" || fail 'ICU observed length mismatch'
test "$((offset + length))" -eq "$finish" || fail 'Arena slice range mismatch'
if test "$declared" != -1; then
    canonical_number "$declared" || fail 'invalid declared content length'
    test "$declared" -eq "$length" || fail 'truncated declared HTTP response'
fi
digest=$(field sha256)
test "${#digest}" -eq 64 || fail 'bad digest length'
case "$digest" in *[!0-9a-f]*) fail 'bad digest characters' ;; esac

# The .used pointer is the canonical appendfat commit boundary, not arena
# allocation capacity. The independent oracle reads only committed bytes.
test "$(wc -c < "$used" | tr -d '[:space:]')" -le 20 || fail 'invalid used pointer size'
pointer=$(cat "$used") || fail 'unreadable commit pointer'
canonical_number "$pointer" || fail 'invalid commit pointer'
test "$finish" -le "$pointer" || fail 'uncommitted byte range'
test "$pointer" -le "$(stat -c %s "$arena")" || fail 'commit pointer exceeds allocation'
test -d "$root/staging" && test ! -L "$root/staging" ||
    fail 'private staging unavailable'
work=$(mktemp -d "$root/staging/aici-source.XXXXXXXX") || fail 'cannot stage independent read'
trap 'rm -rf "$work"' EXIT HUP INT TERM
# GNU dd provides byte units without the O(n) per-byte syscalls of bs=1.
dd if="$arena" of="$work/body" bs=65536 iflag=skip_bytes,count_bytes \
    skip="$offset" count="$length" status=none ||
    fail 'independent committed read failed'
test "$(wc -c < "$work/body" | tr -d '[:space:]')" -eq "$length" ||
    fail 'short independent committed read'
actual=$(sha256sum "$work/body" | cut -d ' ' -f 1)
test "$actual" = "$digest" || fail 'committed bytes differ from receipt SHA-256'
iconv -f UTF-8 -t UTF-8 < "$work/body" > /dev/null 2>&1 ||
    fail 'committed HTML bytes are not valid UTF-8'
test "$(cat "$used")" = "$pointer" ||
    fail 'commit pointer changed during read'
printf 'PASS\tib-source-v2-admitted\t%s\t%s\t%s\t%s\n' "$request" "$generation" "$length" "$digest"
