# Signed direct APK packaging reproduction

Purpose: verify the requested reproducible packaging independently of native-reader runtime acceptance. The same frozen checked DEX, payload bytes/modes, source manifest/resources, SDK tools and public test key are packaged twice with a wall-clock separation. Signed output bytes must match; derived APKs are not delivered as the tested reader.

This calls the maintained android-NDK packager at9861b303a7e6d989125d80cee552a46cb2503555. It creates no second packager and compiles no replacement candidate DEX or native code. Fixture sourceD02 and archive13101964714 are literal ID/size/SHA-bound inputs selected only for packaging. The changed0d2 reader and physical TAB_P10 remain NOT_RUN in this host observation.

Type sketch: FrozenPackageInputs contains source/git identities, a signed fixture, checked DEX, exact extracted payload/modes and declared public test signer. Two PackageOutputs are compared byte for byte after a real timestamp gap. Unequal bytes are FAIL with retained input/output hashes and ZIP records; valid signatures alone grant no reproduction pass.

The source packager copies classes.dex into a fresh directory before zip; this test resolves whether that operation and archive metadata preserve reproducibility. Credentials are used only for the fixed artifact endpoint and are not printed. The existing public test key/certificate is checked. No installation, merge, permanent release, app-data operation or physical inference.
