# Android signing identity

This action is the publication-side signer gate for Android APKs.

For a user-facing APK, use the [Android release delivery action](../android-release-delivery/)
pinned to a reviewed full AICI commit on `main`. Use it after the last APK
transformation and before user delivery, including preview and prerelease builds.
It requires the release lane and checks the expected package and single target ABI.

The important boundary is the **finished APK**, not the keystore name, workflow
variable, or a receipt written by the app repository. The action extracts the
package ID and signer certificate SHA-256 directly from the APK and checks that
pair against `identities.tsv`.

An APK fails closed when:

- its package/lane is not registered;
- the finished APK has no signer;
- it has more than one distinct signer certificate;
- the observed certificate does not match the centrally registered identity;
- the registry is malformed or contains duplicate package/lane entries.

Consumer repositories should pin this action by full commit SHA. They should
not carry their own authoritative copy of the expected fingerprint.

The registry deliberately separates lanes. A public stable test signer does not
authorize a production release. A release lane remains unregistered until its
authorized public certificate fingerprint is deliberately added here. A
certificate registered in the test lane cannot pass release verification, even
if a release row repeats its fingerprint.

The signing command itself must also fail closed. It must never generate a
missing key, silently choose a debug key, or accept a caller-supplied fingerprint
as the authority. This action is the independent finished-artifact check after
that build-time enforcement.

Current stable public test identity:

`de9b1d47c5a65e6d46a204b79dd9ee566b9d3c9832ba81ebc4213d3392e92ff9`

The self-test includes hostile cases for a wrong signer, an unregistered
package, an unregistered release lane, and a malformed digest.

## Delivery receipt

On a build host or trusted consumer, invoke `grease check-delivery.grease APK
EXPECTED_PACKAGE EXPECTED_ABI TARGET` from a pinned AICI checkout. The invoking
process supplies the trusted SDK build-tools directory via
`AICI_ANDROID_BUILD_TOOLS` and the trusted ICK-built
`src/aici_android_signing.c` executable via `AICI_ANDROID_SIGNING_VERIFIER`.
The registry is loaded beside the script. The script inspects a private copy of
the APK and prints one `aici-android-release-delivery-v1` TSV receipt on
success. The Action writes the receipt atomically and includes its
`policy_commit`.

Obtain package and ABI expectations from trusted product and device
configuration. Bind the inspection receipt to the protected build run and its
source and packaging revisions in the calling job. Receivers must establish
that provenance through the trusted producer and compare the digest and byte
count against the actual bytes being published or attached. A stand-alone TSV
does not establish who produced it.
