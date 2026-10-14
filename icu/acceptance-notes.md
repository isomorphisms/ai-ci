# Fixture correction

The first published-head rerun passed the transport behavior cases but its
privacy probe selected two unrelated temporary directories when a live Jobicy
request ran concurrently. The assumption that all host captures belong to this
test was wrong. This was a fixture-scope failure, not transport acceptance.

The corrected fixture observes the open body file through the held probe's
process descriptor table, checks that exact directory/file permissions, and
checks that the exact directory disappears after that process exits. It does
not inspect or remove another request's capture. Earlier FAIL receipts remain.

System-call tracing was attempted separately and refused PTRACE_TRACEME with
Operation not permitted. No trace execution is claimed. Native loader witnesses,
the installed library's dynamic symbols, pinned native source/artifact digests,
and an actual compiled rejecting size-limit mutant support the tested native
path. Curl remains a separately invoked behavioral oracle.
