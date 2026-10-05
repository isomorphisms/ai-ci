#!/bin/sh
set -eu

[ "$#" -ge 1 ] || {
    echo 'usage: merge/check-workflow-head.sh WORKFLOW [...]' >&2
    exit 2
}

status=0
for workflow do
    if [ ! -f "$workflow" ]; then
        printf 'CI-EXACT-HEAD-WORKFLOW-MISSING\t%s\n' "$workflow"
        status=1
        continue
    fi

    if ! awk -v workflow="$workflow" '
        function flush_checkout() {
            if (!active) return
            if (!dependency) {
                primary++
                if (!exact) {
                    printf "CI-EXACT-HEAD-CHECKOUT-MISSING\t%s:%d\n", workflow, checkout_line
                    bad=1
                }
            }
            active=0
            dependency=0
            exact=0
            checkout_line=0
        }

        /^[[:space:]]*pull_request:[[:space:]]*($|#)/ { pull_request_trigger=1 }

        /^[[:space:]]*-[[:space:]]+(name:|uses:)/ {
            if (active && $0 !~ /uses:[[:space:]]*actions\/checkout@/) flush_checkout()
        }

        /uses:[[:space:]]*actions\/checkout@/ {
            flush_checkout()
            active=1
            checkout_line=NR
            next
        }

        active && /^[[:space:]]*repository:[[:space:]]*/ { dependency=1 }
        active && index($0, "github.event.pull_request.head.sha || github.sha") { exact=1 }

        END {
            flush_checkout()
            if (!pull_request_trigger) {
                printf "CI-EXACT-HEAD-TRIGGER-MISSING\t%s\n", workflow
                bad=1
            }
            if (primary==0) {
                printf "CI-EXACT-HEAD-PRIMARY-CHECKOUT-MISSING\t%s\n", workflow
                bad=1
            }
            if (!bad) printf "PASS\texact-head-workflow\t%s\tprimary_checkouts=%d\n", workflow, primary
            exit bad
        }
    ' "$workflow"; then
        status=1
    fi
done

exit "$status"
