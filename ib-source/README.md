# Independent IB ICU/Arena v2 source admission

**Scope:** This is an independent AI-CI oracle for already retained,
already committed **admitted HTML** in IB's canonical userspace Arena.

`sh ib-source/verify.sh PRIVATE_ARENA_ROOT REQUEST_ID NAVIGATION_GENERATION REQUESTED_URL`

The host-side oracle uses its own strict receipt-field checks and GNU
`dd` byte-offset read, rather than IB's producer, its native slice helper,
or its Binder source owner. It checks the canonical `.used` boundary,
source identity and navigation generation, HTTP 200, observed effective URL,
`text/html`, explicit UTF-8 charset, identity encoding, ICU-valid UTF-8,
complete acquisition, committed range, SHA-256 and positive navigation
admission. It rejects the old body-only v1 receipt even if the body matches.

`sh ib-source/self-test.sh` first demonstrates a positive retained source,
then mutates each admission field, schema shape, generation, range, digest,
commit-pointer and private-directory permissions, requiring rejection of
each faulty source. A distinct check must re-read the bytes: a matching
receipt does not prove immutable Arena content without that independent read.

This oracle **does not attest that HTTP headers came from ICU's actual
network request**. It evaluates the recorded observation against expected
request identity, consistency and committed bytes. ICU #35's actual native
HTTP/TLS integration is checked separately in IB #152; simulated Shizuku
is not a physical C67 test.

Nor does this oracle verify a real Android Binder transaction, the reader
APK, Idriç HTML-to-Prepaint semantics, FP/Kitchen/Ike execution, or the
human-visible job delivery receipt. Those require separate independent
evidence. A green self-test is not an overall merge verdict.
