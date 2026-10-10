#!/bin/sh
# AICI-owned independent execution of SUN T1: never read a producer's
# self-attested success receipt as a substitute for actually invoking it.
set -eu
aici_root=$(CDPATH= cd -- "$(dirname "$0")/../../.." && pwd)
subject=${1:?Pass an exact checked-out Holomorphic repository path}
expected_revision=${2:?Pass the immutable Holomorphic source revision}
subject=$(CDPATH= cd -- "$subject" && pwd)
observed_revision=$(git -C "$subject" rev-parse HEAD)
if [ "$observed_revision" != "$expected_revision" ]; then
    echo "AICI-WRONG-SOURCE expected=$expected_revision observed=$observed_revision" >&2
    exit 2
fi
source_file="$subject/android/app/src/main/cpp/holomorphic_walk.c"
header_dir="$subject/android/app/src/main/cpp"
smoke_test="$subject/tests/test_holomorphic_walk.c"
oracle="$aici_root/tests/semantic-oracles/holomorphic-t1/independent_reference.c"
oracle_revision=$(git -C "$aici_root" rev-parse HEAD)
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT HUP INT TERM
receipt_dir=${AICI_SEMANTIC_RECEIPT_DIR:-"$scratch"}
mkdir -p "$receipt_dir"
receipt="$receipt_dir/aici-holomorphic-t1.tsv"
printf 'case_id\tsut_revision\taici_revision\tcandidate_sha256\tcandidate_test\toriginal_smoke\tsemantic_result\toracle\tseed\tevidence_boundary\n' > "$receipt"

check() {
    case_id=$1
    candidate=$2
    expected=$3
    sha=$(sha256sum "$candidate" | cut -d ' ' -f 1)
    cc -std=c11 -Wall -Wextra -Werror -O2 -I "$header_dir" \
        "$smoke_test" "$candidate" -pthread -lm -o "$scratch/$case_id-worker-smoke"
    "$scratch/$case_id-worker-smoke" > "$receipt_dir/$case_id-smoke.log" 2>&1 || {
        echo "AICI-WEAK-SMOKE-DID-NOT-PASS case=$case_id" >&2
        exit 1
    }
    grep -Fq 'holomorphic workers ready:' "$receipt_dir/$case_id-smoke.log" || {
        echo "AICI-WEAK-SMOKE-NOT-OBSERVED case=$case_id" >&2
        exit 1
    }
    cc -std=c11 -Wall -Wextra -Werror -O2 -I "$header_dir" \
        -include "$candidate" "$oracle" -pthread -lm -o "$scratch/$case_id-semantic"
    if "$scratch/$case_id-semantic" > "$receipt_dir/$case_id-semantic.log" 2>&1; then
        result=PASS
        grep -Fq 'AICI-SEMANTIC-PASS cases=6' "$receipt_dir/$case_id-semantic.log" || {
            echo "AICI-MISSING-SEMANTIC-PASS-MARKER case=$case_id" >&2
            exit 1
        }
    else
        result=KILLED
        grep -Fq 'AICI-SEMANTIC-MISMATCH case=' "$receipt_dir/$case_id-semantic.log" || {
            echo "AICI-WRONG-KILL-REASON case=$case_id" >&2
            cat "$receipt_dir/$case_id-semantic.log" >&2
            exit 1
        }
    fi
    if [ "$result" != "$expected" ]; then
        echo "AICI-SEMANTIC-UNEXPECTED-RESULT case=$case_id got=$result wanted=$expected" >&2
        exit 1
    fi
    printf '%s\t%s\t%s\t%s\t%s\tPASS\t%s\thand-derived-six-values\tfixed-six\thost-CPU-not-GPU-or-device\n' \
        "$case_id" "$observed_revision" "$oracle_revision" "$sha" \
        "$case_id-semantic" "$result" >> "$receipt"
    printf 'AICI-T1 case=%s old_smoke=PASS independent=%s source=%s\n' \
        "$case_id" "$result" "$observed_revision"
}

mutate() {
    case_id=$1
    pattern=$2
    replacement=$3
    required_hits=$4
    hits=$(grep -c "$pattern" "$source_file" || true)
    if [ "$hits" -ne "$required_hits" ]; then
        echo "AICI-MUTANT-SOURCE-CHANGED case=$case_id expected=$required_hits found=$hits" >&2
        exit 2
    fi
    candidate="$scratch/$case_id.c"
    sed "s/$pattern/$replacement/g" "$source_file" > "$candidate"
    if cmp -s "$candidate" "$source_file"; then
        echo "AICI-MUTANT-NO-OP case=$case_id" >&2
        exit 2
    fi
    check "$case_id" "$candidate" KILLED
}

check good "$source_file" PASS
mutate scale-half 'delta_q\[0\] = 0.0f;' \
    'u_x *= 0.5f; u_y *= 0.5f; delta_q[0] = 0.0f;' 1
mutate derivative-degree 'int degree = index + 1;' \
    'int degree = index;' 1
mutate omit-fifth 'int degree = index + 1;' \
    'int degree = index + 1; if (index == 4) continue;' 1
mutate wrong-real-sign 'delta_q\[0\] += term\[0\];' \
    'delta_q[0] -= term[0];' 1
mutate reverse-coefficients \
    'direction\[index\]\[0\], direction\[index\]\[1\],' \
    'direction[4 - index][0], direction[4 - index][1],' 2

observed_cases=$(awk 'END {print NR-1}' "$receipt")
if [ "$observed_cases" -ne 6 ]; then
    echo "AICI-MISSING-CASES expected=6 observed=$observed_cases" >&2
    exit 1
fi
printf 'AICI-INDEPENDENT-PASS good=1 killed=5 survived=0 cases=6 sut=%s oracle=%s\n' \
    "$observed_revision" "$oracle_revision"
