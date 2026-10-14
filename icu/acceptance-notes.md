# Fixture correction

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
