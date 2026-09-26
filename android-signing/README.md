# Android signing identity

This action is the publication-side signer gate for Android APKs.

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
private release certificate fingerprint is deliberately added here.

The signing command itself must also fail closed. It must never generate a
missing key, silently choose a debug key, or accept a caller-supplied fingerprint
as the authority. This action is the independent finished-artifact check after
that build-time enforcement.

Current stable public test identity:

`de9b1d47c5a65e6d46a204b79dd9ee566b9d3c9832ba81ebc4213d3392e92ff9`

The self-test includes hostile cases for a wrong signer, an unregistered
package, an unregistered release lane, and a malformed digest.
