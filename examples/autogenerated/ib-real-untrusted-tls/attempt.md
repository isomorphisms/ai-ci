# A real certificate-trust negative for installed ICU

The existing HTTPS-to-plaintext probe qualifies a protocol refusal, not
certificate validation. The explicitly selected navigation reader-v4 profile
now starts a real OpenSSL TLS server with a generated self-signed certificate
whose subjectAltName includes the emulator gateway and host loopback IPs.

Independent fixture controls require the same server to handshake successfully
when that exact certificate is explicitly trusted by the host s_client
process, and to fail with the designated self-signed-chain verification error
under default trust. The OpenSSL executable hash/version, public certificate
hash/dates and exact exit/log observations are retained. The ephemeral private
key lives in a separate private temporary directory outside uploaded evidence.
No Android trust store or candidate TLS checks are changed.

Only then does the actual installed reader receive
https://10.0.2.2:18492/ through its normal ICU/Shizuku path. It must refuse
acquisition, retain the last readable title and exact source clipboard, and
preserve its checked history. The SDK observer cannot substitute host TLS
observations for this candidate action. The ordinary Example Domain HTTPS
positive and the prior protocol/framing/source controls remain required.

The profile is explicit. Frozen reader-v2/v3 tests keep their original inputs
and do not acquire a certificate-validation claim from new files. At authoring
this new check is NOT_RUN; physical TAB_P10 remains BLOCKED.

Type sketch: fixture certificate bytes, hostname/IP identity, trust choice,
handshake exit and reader observations remain separate evidence fields.
There is no fallback network client and no simulated Binder transaction.
