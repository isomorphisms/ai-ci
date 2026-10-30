#!/bin/sh
# Independent oracle for source-pinned Flexible Pipes Amazon shopping receipts.
# It checks the command that actually ran, never executes a substitute AZ.
set -eu
fail() { printf 'ai-ci Amazon receipt FAIL: %s\n' "$*" >&2; exit 1; }
[ "$#" -eq 2 ] || fail "usage: check-receipts.sh ACCEPTANCE_DIR FLEXIBLE_PIPES_CHECKOUT"
receipts_root=$1
fp_root=$2
[ -d "$receipts_root" ] || fail "no retained acceptance receipts"
[ -f "$fp_root/pipelines/amazon-product-lookup.json" ] ||
    fail "missing checked-in Amazon pipeline specification"
command -v jq >/dev/null 2>&1 || fail "missing jq"
command -v sha256sum >/dev/null 2>&1 || fail "missing sha256sum"
commit=$(git -C "$fp_root" rev-parse HEAD) || fail "missing repository revision"
spec_sha=$(sha256sum "$fp_root/pipelines/amazon-product-lookup.json" | awk '{print $1}')

require_line() {
    file=$1
    key=$2
    value=$3
    grep -Fx "$(printf '%s\t%s' "$key" "$value")" "$file" >/dev/null ||
        fail "missing or contradicted $key=$value in $file"
}

check_lane() {
    lane=$1
    expected_exec=$2
    expected_status=$3
    found=0
    for receipt in "$receipts_root/$lane"/amazon-product-lookup-*/receipt.json; do
        [ -f "$receipt" ] || fail "missing receipt for lane $lane"
        found=$((found + 1))
        [ "$found" -eq 1 ] || fail "ambiguous duplicate receipts for $lane"
        dir=${receipt%/*}
        out=$dir/01-product-lookup/stdout.bin
        err=$dir/01-product-lookup/stderr.bin
        [ -f "$out" ] && [ -f "$err" ] || fail "missing retained raw stage stream in $lane"
        observed_out=$(sha256sum "$out" | awk '{print $1}')
        observed_err=$(sha256sum "$err" | awk '{print $1}')
        jq -e --arg c "$commit" --arg p "$spec_sha" --arg so "$observed_out" --arg se "$observed_err" \
            --arg status "$expected_exec" '
          .schema_version == 1 and
          .pipeline == "amazon-product-lookup" and
          .repository_commit == $c and
          .pipeline_sha256 == $p and
          .status == $status and
          (.stages | length) == 1 and
          .stages[0].kind == "command" and
          .stages[0].name == "product-lookup" and
          .stages[0].argv[0] == "/bin/sh" and
          .stages[0].argv[1] == "scripts/amazon-product-lookup" and
          .stages[0].stdout_sha256 == $so and
          .stages[0].stderr_sha256 == $se and
          .parameters.tag == "macguyver03-20"
        ' "$receipt" >/dev/null || fail "source/command/status/hash mismatch: $lane"
        if [ "$expected_exec" = PASS ]; then
            jq -e '.stages[0].exit_code == 0' "$receipt" >/dev/null ||
                fail "successful runner hides failed stage: $lane"
        else
            jq -e '.stages[0].exit_code != 0' "$receipt" >/dev/null ||
                fail "failed runner claims successful stage: $lane"
        fi
        require_line "$out" status "$expected_status"
        require_line "$out" availability UNKNOWN
        require_line "$out" price UNKNOWN
        require_line "$out" identity_evidence NOT_LIVE_VERIFIED
        require_line "$out" affiliate_disclosure "The operator may earn from qualifying purchases"
        if grep -Eq "$(printf '(^status\tQUALIFIED$|^availability\tAVAILABLE$)')" "$out"; then
            fail "unverified offer promoted to qualified: $lane"
        fi
    done
    [ "$found" -eq 1 ] || fail "no exactly one retained receipt for $lane"
}

check_lane link-good PASS PARTIAL
check_lane moisture PASS PARTIAL
check_lane wrong-fit FAIL BLOCKED
check_lane malformed FAIL BLOCKED
check_lane no-evidence FAIL BLOCKED
check_lane no-price PASS PARTIAL
check_lane no-az FAIL BLOCKED
check_lane no-grease FAIL BLOCKED
check_lane search-fixture PASS PARTIAL
check_lane search-challenge FAIL BLOCKED
check_lane swapped FAIL BLOCKED

find_stdout() {
    lane=$1
    for f in "$receipts_root/$lane"/amazon-product-lookup-*/01-product-lookup/stdout.bin; do
        [ -f "$f" ] || fail "missing $lane stdout"
        printf '%s\n' "$f"
    done
}
good=$(find_stdout link-good)
moisture=$(find_stdout moisture)
wrong=$(find_stdout wrong-fit)
unknown=$(find_stdout no-price)
search=$(find_stdout search-fixture)
challenge=$(find_stdout search-challenge)

require_line "$good" product_role exterior-weatherstrip
require_line "$good" product_name "3M Black Super Weatherstrip Adhesive 03602"
require_line "$good" affiliate_link "https://www.amazon.com/dp/B000CCFXYY?tag=macguyver03-20"
require_line "$good" provider_command link
require_line "$good" provider_exit_code 0
require_line "$moisture" product_role interior-moisture-barrier
require_line "$moisture" affiliate_link "https://www.amazon.com/dp/B000PEZ1L4?tag=macguyver03-20"
grep -Fq "a different repair role" "$wrong" ||
    fail "wrong-role case did not reject the historical mismatch"
if grep -q '^affiliate_link' "$wrong"; then
    fail "wrong-role case emitted a tagged purchase URL"
fi
require_line "$unknown" price_status UNKNOWN_OR_UNAVAILABLE_CREDENTIALS
require_line "$search" search_status EXTRACTED_UNVERIFIED
if grep -q '^affiliate_link' "$challenge"; then
    fail "challenge emitted a trusted affiliate link"
fi
printf 'ai-ci Amazon independent receipt oracle PASS: %s (fixtures, no live Amazon seller/stock)\n' "$commit"
