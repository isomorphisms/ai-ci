# Signed direct APK packaging reproduction

Purpose: verify the requested reproducible packaging independently of native-reader runtime acceptance. The same frozen checked DEX, payload bytes/modes, source manifest/resources, SDK tools and public test key are packaged twice with a wall-clock separation. Signed output bytes must match; derived APKs are not delivered as the tested reader.

This calls the maintained android-NDK packager at9861b303a7e6d989125d80cee552a46cb2503555. It creates no second packager and compiles no replacement candidate DEX or native code. Fixture sourceD02 and archive13101964714 are literal ID/size/SHA-bound inputs selected only for packaging. The changed0d2 reader and physical TAB_P10 remain NOT_RUN in this host observation.

Type sketch: FrozenPackageInputs contains source/git identities, a signed fixture, checked DEX, exact extracted payload/modes and declared public test signer. Two PackageOutputs are compared byte for byte after a real timestamp gap. Unequal bytes are FAIL with retained input/output hashes and ZIP records; valid signatures alone grant no reproduction pass.

The source packager copies classes.dex into a fresh directory before zip; this test resolves whether that operation and archive metadata preserve reproducibility. Credentials are used only for the fixed artifact endpoint and are not printed. The existing public test key/certificate is checked. No installation, merge, permanent release, app-data operation or physical inference.


## Verified defect and producer repair

Run41365426201 on48065212 observed two different valid signed APK hashes from identical frozen D02 inputs under backend9861 (comparator exit1). Backend153e7fc8053ba4072954a5e77d4efa3609d829e4 now normalizes only owned staging timestamps and excludes host ZIP extras while preserving input Unix modes. This updated independent test runs both exact producers, requires the old nondeterminism counterexample and fixed byte equality, and compares all caller input bytes, modes and mtimes before and after. No source input is normalized in place. Results are pending; this does not execute the reader, rebuild candidate DEX/ELF or qualify physical hardware.
