#!/bin/sh
set -eu

root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
mkdir -p "$tmp/jobs" "$tmp/receipts"

cc -std=c17 -Wall -Wextra -Werror -pedantic -O2 \
    -o "$tmp/aici-followers" "$root/src/aici_followers.c"
binary=$tmp/aici-followers
sha=0123456789abcdef0123456789abcdef01234567

job() {
    id=$1 state=$2 required=$3 evidence=$4 reason=$5 follower=$6 arch=$7 kind=$8
    cat > "$tmp/jobs/$id.tsv" <<EOF_JOB
schema	aici-follower-job-v1
job_id	$id
repository	isomorphisms/catfood
branch	phone/example
pr	28
trigger_commit	$sha
leader_platform	android-phone
leader_arch	armv7
leader_evidence	phone-receipt.tsv
artifact	-
artifact_sha256	-
follower_platform	$follower
follower_arch	$arch
required	$required
action	accept exact source on $follower
acceptance_kind	$kind
acceptance_action	run follower acceptance
state	$state
last_attempt_commit	-
blocker	-
evidence	$evidence
depends_on	-
reason	$reason
superseded_by	-
follow_policy	exact
EOF_JOB
}

receipt() {
    id=$1 result=$2 follower=$3 arch=$4 kind=$5 attempt=${6:-$sha}
    cat > "$tmp/receipts/$id.tsv" <<EOF_RECEIPT
schema	aici-follower-receipt-v1
job_id	$id
repository	isomorphisms/catfood
trigger_commit	$sha
follower_platform	$follower
follower_arch	$arch
acceptance_kind	$kind
result	$result
attempt_commit	$attempt
os_runtime	linux test fixture
build_command	cc fixture
test_command	run fixture
artifact	-
artifact_sha256	-
evidence_url	-
recorded_at	2026-09-11T12:00:00-04:00
note	fixture
EOF_RECEIPT
}

rewrite() {
    file=$1
    expression=$2
    sed "$expression" "$file" > "$file.new"
    mv "$file.new" "$file"
}

job accepted accepted yes accepted.tsv - github-x86_64 x86_64 runtime
receipt accepted pass github-x86_64 x86_64 runtime
job pending pending yes - - hetzner-x86_64 x86_64 runtime
job conditional n/a conditional - 'phone-only path was unchanged' phone armv7 physical-device
job unsupported unsupported yes - 'runtime is explicitly not supported yet' legacy-x86 x86 runtime

"$binary" verify "$tmp/jobs" "$tmp/receipts" >/dev/null
pending=$($binary pending "$tmp/jobs" "$tmp/receipts" "$sha")
printf '%s\n' "$pending" | grep -F 'pending' >/dev/null
printf '%s\n' "$pending" | grep -F 'unsupported' >/dev/null
if printf '%s\n' "$pending" | grep '^accepted[[:space:]]' >/dev/null; then
    echo 'accepted follower remained pending' >&2
    exit 1
fi

bad=$tmp/bad
mkdir -p "$bad/jobs" "$bad/receipts"
cp "$tmp/jobs/accepted.tsv" "$bad/jobs/accepted.tsv"
if "$binary" verify "$bad/jobs" "$bad/receipts" >/dev/null 2>&1; then
    echo 'accepted follower without receipt was accepted' >&2
    exit 1
fi

cp "$tmp/receipts/accepted.tsv" "$bad/receipts/accepted.tsv"
rewrite "$bad/receipts/accepted.tsv" \
    's/^attempt_commit	.*/attempt_commit	1111111111111111111111111111111111111111/'
if "$binary" verify "$bad/jobs" "$bad/receipts" >/dev/null 2>&1; then
    echo 'stale receipt was accepted' >&2
    exit 1
fi

rm -rf "$bad/jobs" "$bad/receipts"
mkdir -p "$bad/jobs" "$bad/receipts"
cp "$tmp/jobs/conditional.tsv" "$bad/jobs/conditional.tsv"
rewrite "$bad/jobs/conditional.tsv" 's/^reason	.*/reason	-/'
if "$binary" verify "$bad/jobs" "$bad/receipts" >/dev/null 2>&1; then
    echo 'unexplained n/a was accepted' >&2
    exit 1
fi

rm -rf "$bad/jobs" "$bad/receipts"
mkdir -p "$bad/jobs" "$bad/receipts"
cp "$tmp/jobs/accepted.tsv" "$bad/jobs/accepted.tsv"
cp "$tmp/receipts/accepted.tsv" "$bad/receipts/accepted.tsv"
rewrite "$bad/jobs/accepted.tsv" 's/^artifact	-$/artifact	abe-armv7/'
rewrite "$bad/jobs/accepted.tsv" \
    's/^artifact_sha256	-$/artifact_sha256	aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa/'
if "$binary" verify "$bad/jobs" "$bad/receipts" >/dev/null 2>&1; then
    echo 'artifact mismatch was accepted' >&2
    exit 1
fi

printf '%s\n' 'follower ledger self-test passes'
