# Provision the receipt verifier before first use

The fresh F43 replay at ai-ci c22c3e5d929016fcc48029b6afe897155162bf86
downloaded the exact frozen archive and verified its SHA256, then stopped before
Android with exit127: rg was not installed. New reproduction-receipt checks used
the declared verifier earlier than the old APK/index-only input path. The
existing installation step was still after archive verification.

Both runtime workflows now run that same existing Grease installation step before
the first new receipt check. There is no fallback command, skipped assertion,
changed archive/source identity, compiler change or APK modification.
The literal F43 source guard, all ten APK hashes, repeated-build receipt gates,
host corruption controls and every Android profile remain mandatory.

Type sketch: declared executable availability precedes its first verification
operation. An unavailable verifier is setup failure, never product acceptance
or a designated mutant rejection. The original failed runs are retained.
Fresh runtime results are pending.
