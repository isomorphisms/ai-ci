# Finished APK qualification

The first gate at a977ef3e83958db21b05635ebd40277871d25bd7 rejected a valid A1 candidate because it assumed older aapt2 badging field names. Build-tools 35.0.0 actually reports `minSdkVersion` and an `application: label=...` line. The SDK and label checks now admit the two known tool spellings and still require one exact observed value. The maintained android-NDK packager already handled both label spellings; its successful package observation was not an Android execution result.

The independent gate compiles the existing central signing verifier through ICK, runs its unchanged identity fixtures, reads actual finished APK signatures and badging, checks the application source marker inside each native payload, rejects DEX or extra ABI libraries, and checks stripping and alignment. Required negative cases include a valid APK with the wrong signer and a valid APK with the wrong launcher label. No package, emulator, physical-device or managed-runtime result is inferred from another evidence class.

The public-development signer row is inherited from the existing registry change at 5a3c7b2361e162c5743fcbb92191258bf7dc4dbe. This consumer does not register a second key or authorize production signing.
