# Deterministic interruption model

Scenario files are controller scripts, not a chosen on-disk ledger format.
`durable` events survive a cut; `volatile-ack` does not. `hidden-remote` belongs
to the controller and is unavailable to recovered client knowledge. The same
visible history must produce the same knowledge even when hidden server state
differs. `corrupt-tail` and `truncated-tail` never constitute durable success.

| Cut | Expected knowledge after recovery | Retry |
| --- | --- | --- |
| Before reading / while reading / parsed but not submitted | Not written | Safe |
| During submission | Unknown | Prohibited automatically |
| Accepted remotely, acknowledgement lost | Unknown | Prohibited automatically |
| Not accepted remotely, same visible history | Unknown | Prohibited automatically |
| Acknowledged, local success still volatile | Unknown | Prohibited automatically |
| Acknowledged and durably recorded | Written | Unnecessary |
| Durable permanent rejection | Failed | Prohibited automatically |
| Torn/corrupt final success record after durable intent | Unknown | Prohibited automatically |

The paired hidden-world cases justify uncertainty independently. They do not
dictate write-ahead logging or claim any existing migration implementation uses
that layout. If an append ledger is chosen, its format needs length/checksum or
equivalent framing, record sequence rules, source snapshot binding, and explicit
file/directory durability guarantees. Recovery tests must cut each record at
every byte, corrupt both payload and framing, repeat recovery, reject mismatched
snapshots, and preserve the last established state without discarding an in-flight
write. No unchosen checksum format is enforced now.

Model adapters are executable today. Actual process kill/restart acceptance is
**PENDING** the real state adapter. Its controller must stop at barriers before
read, during read, after parse, during submission, between remote accept and
ack, between ack and durable recording, after recording, and during recovery.
Kill the process externally, restart from disk in a fresh process, and inspect
both the local records and the fake destination's independent append-only event
log. The fake service must choose acceptance before dropping the reply. Do not
allow the candidate to declare which writes occurred. Uninterrupted and safe-
checkpoint runs must end in equivalent occurrence accounting. Unknown outcomes
must halt for reconciliation rather than replay a write.
