#!/bin/sh

set -eu

service=${SMS_SERVICE:?set SMS_SERVICE to the Grease SMS service}
parser=${IDRIC_SMS_REQUEST:?set IDRIC_SMS_REQUEST to the compiled Idric-Net parser}
test_root=$(mktemp -d)

cleanup() {
  case "$test_root" in
    /tmp/*) rm -rf -- "$test_root" ;;
  esac
}
trap cleanup EXIT HUP INT TERM

fail() {
  printf 'FAIL\t%s\t%s\n' "$1" "$2" >&2
  exit 1
}

pass() {
  printf 'PASS\t%s\t%s\n' "$1" "$2"
}

value_is() {
  file=$1
  expected=$2
  observation=$3
  [ -f "$file" ] || fail "$observation" "missing $file"
  actual=$(sed -n '1p' "$file")
  [ "$actual" = "$expected" ] || fail "$observation" "$file expected '$expected', got '$actual'"
}

run_service() {
  IDRIC_SMS_REQUEST="$parser" "$service" "$@"
}

state="$test_root/remind"
run_service init "$state"
receipt=$(run_service inbound "$state" +15550000001 2026-09-01T14:00:00Z in_imani 'REMIND 15:00')
[ "$receipt" = 'scheduled evt_in_imani 2026-09-01T15:00:00Z' ] || \
  fail parser_handoff "unexpected schedule receipt: $receipt"
pass parser_handoff 'compiled Network.SMS parser accepted REMIND 15:00'

principal=$(sed -n '1p' "$state/addresses/+15550000001")
value_is "$state/principals/$principal/kind" public_correspondent authorization_provenance
value_is "$state/consent/evt_in_imani/principal" "$principal" authorization_provenance
value_is "$state/consent/evt_in_imani/destination" +15550000001 authorization_provenance
value_is "$state/consent/evt_in_imani/requested_at" 2026-09-01T14:00:00Z authorization_provenance
value_is "$state/consent/evt_in_imani/inbound_id" in_imani authorization_provenance
value_is "$state/consent/evt_in_imani/original_request" 'REMIND 15:00' authorization_provenance
value_is "$state/consent/evt_in_imani/scheduled_for" 2026-09-01T15:00:00Z authorization_provenance
value_is "$state/consent/evt_in_imani/message" hey authorization_provenance
value_is "$state/scheduled/2026-09-01T15:00:00Z/evt_in_imani/authorization" consent/evt_in_imani authorization_provenance
pass authorization_provenance 'event retains principal, destination, request, schedule, message, and consent link'

run_service run_due "$state" 2026-09-01T14:59:59Z >/dev/null
[ ! -e "$state/fake_outbox/fake_evt_in_imani" ] || fail not_early 'event reached outbox before scheduled time'
pass not_early '14:59:59 run leaves 15:00 event scheduled'

sent=$(run_service run_due "$state" 2026-09-01T15:00:00Z)
[ "$sent" = 'sent evt_in_imani' ] || fail due_delivery "unexpected send receipt: $sent"
[ -d "$state/sent/evt_in_imani" ] || fail due_delivery 'event was not moved to sent'
[ ! -e "$state/scheduled/2026-09-01T15:00:00Z/evt_in_imani" ] || fail due_delivery 'sent event remains scheduled'
value_is "$state/fake_outbox/fake_evt_in_imani/to" +15550000001 due_delivery
value_is "$state/fake_outbox/fake_evt_in_imani/body" hey due_delivery
pass due_delivery 'fresh invocation moves event to sent and fake outbox contains exact destination and hey'

state="$test_root/cancel"
run_service init "$state"
run_service inbound "$state" +15550000002 2026-09-01T14:00:00Z in_hasan 'REMIND 15:00' >/dev/null
run_service inbound "$state" +15550000002 2026-09-01T14:05:00Z in_hasan_cancel 'CANCEL evt_in_hasan' >/dev/null
run_service run_due "$state" 2026-09-01T15:00:00Z >/dev/null
[ -d "$state/cancelled/evt_in_hasan" ] || fail cancelled_stays_cancelled 'cancelled event is missing'
[ ! -e "$state/fake_outbox/fake_evt_in_hasan" ] || fail cancelled_stays_cancelled 'cancelled event reached outbox'
pass cancelled_stays_cancelled 'CANCEL prevents later delivery'

state="$test_root/stop"
run_service init "$state"
run_service inbound "$state" +15550000003 2026-09-01T14:00:00Z in_armani 'REMIND 16:00' >/dev/null
run_service inbound "$state" +15550000003 2026-09-01T14:01:00Z in_armani_stop STOP >/dev/null
run_service run_due "$state" 2026-09-01T16:00:00Z >/dev/null
[ ! -e "$state/fake_outbox/fake_evt_in_armani" ] || fail stop_prevents_delivery 'STOPped event reached outbox'
if run_service inbound "$state" +15550000003 2026-09-01T14:02:00Z in_armani_again 'REMIND 16:00' >/dev/null 2>&1; then
  fail stop_prevents_delivery 'STOPped principal scheduled another event'
fi
pass stop_prevents_delivery 'STOP cancels pending work and blocks later scheduling'

state="$test_root/same-time"
run_service init "$state"
run_service inbound "$state" +15550000004 2026-09-01T14:00:00Z in_gina 'REMIND 17:00' >/dev/null
run_service inbound "$state" +15550000005 2026-09-01T14:00:00Z in_moe 'REMIND 17:00' >/dev/null
[ -d "$state/scheduled/2026-09-01T17:00:00Z/evt_in_gina" ] || fail same_time_distinct 'Gina event was collapsed'
[ -d "$state/scheduled/2026-09-01T17:00:00Z/evt_in_moe" ] || fail same_time_distinct 'Moe event was collapsed'
run_service run_due "$state" 2026-09-01T17:00:00Z >/dev/null
[ -f "$state/fake_outbox/fake_evt_in_gina/body" ] || fail same_time_distinct 'Gina receipt is missing'
[ -f "$state/fake_outbox/fake_evt_in_moe/body" ] || fail same_time_distinct 'Moe receipt is missing'
pass same_time_distinct 'two principals at one instant retain distinct events and receipts'

state="$test_root/rejection"
run_service init "$state"
if run_service inbound "$state" +15550000006 2026-09-01T14:00:00Z in_paul 'remind me at 3' >/dev/null 2>&1; then
  fail rejected_language_no_effect 'casual language was accepted'
fi
[ -f "$state/inbound/in_paul/body" ] || fail rejected_language_no_effect 'rejected inbound evidence is missing'
if find "$state/scheduled" -mindepth 1 -print -quit | grep -q .; then
  fail rejected_language_no_effect 'rejected request created a scheduled effect'
fi
pass rejected_language_no_effect 'casual language remains inbound evidence and creates no effect'
