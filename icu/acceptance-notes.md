# Fixture correction

The October 23 continuation exposed the fixed 400 ms privacy observation
window: a loaded host could reach the probe before its candidate body existed.
The independent fixture now holds the marked response until the test releases
it, with a ten-second bound. The observer waits at most five seconds for its
exact marker, checks permissions, releases the fixture, and verifies cleanup.
A missing body still fails. Earlier failed runs are not passing evidence.

The first published-head rerun passed the transport behavior cases but its
privacy probe selected two unrelated temporary directories when a live Jobicy
request ran concurrently. The assumption that all host captures belong to this
test was wrong. This was a fixture-scope failure, not transport acceptance.

The next attempt could not inspect the held PID through /proc because the
execution PID namespace and the mounted /proc view differ. It also remains FAIL.
The corrected fixture sends a unique per-run marker before holding the body
open, identifies the capture containing that marker, checks its exact
directory/file permissions, and checks that the exact directory disappears
after its request exits. It never removes another request's capture. Earlier
FAIL receipts remain unchanged.

System-call tracing was attempted separately and refused PTRACE_TRACEME with
Operation not permitted. No trace execution is claimed. Native loader witnesses,
the installed library's dynamic symbols, pinned native source/artifact digests,
and an actual compiled rejecting size-limit mutant support the tested native
path. Curl remains a separately invoked behavioral oracle.
