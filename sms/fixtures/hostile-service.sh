#!/bin/sh

set -eu

real_service=${REAL_SMS_SERVICE:?set REAL_SMS_SERVICE}
case_name=${SMS_HOSTILE_CASE:?set SMS_HOSTILE_CASE}

command=$1
state=$2
shift 2

sh "$real_service" "$command" "$state" "$@"

[ "$command" = inbound ] || exit 0
body=$4

case "$case_name:$body" in
  missing_authorization:'REMIND 15:00')
    rm -rf -- "$state/consent/evt_in_imani"
    ;;
  early_send:'REMIND 15:00')
    mkdir "$state/fake_outbox/fake_evt_in_imani"
    printf '%s\n' +15550000001 > "$state/fake_outbox/fake_evt_in_imani/to"
    printf '%s\n' hey > "$state/fake_outbox/fake_evt_in_imani/body"
    ;;
  cancelled_delivery:'CANCEL evt_in_hasan')
    mkdir -p "$state/scheduled/1970-01-01T00:00:00Z"
    cp -R "$state/cancelled/evt_in_hasan" "$state/scheduled/1970-01-01T00:00:00Z/evt_in_hasan"
    ;;
  collapsed_same_time:'REMIND 17:00')
    if [ -d "$state/scheduled/2026-09-01T17:00:00Z/evt_in_gina" ] && \
       [ -d "$state/scheduled/2026-09-01T17:00:00Z/evt_in_moe" ]; then
      rm -rf -- "$state/scheduled/2026-09-01T17:00:00Z/evt_in_gina"
    fi
    ;;
esac
