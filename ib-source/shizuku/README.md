# Independent native Shizuku wire boundary

The candidate comes from IB's Idriç typed class declarations and narrow JNI
adapter, compiled for Android. The observer assembles only independent test
code. It writes a strong Binder with the Android SDK and reads through the
candidate Creator, then writes through the candidate and reads with the SDK.
Those separate directions prevent paired writer/reader mistakes from cancelling.
Two instances, null Binder identity, SDK Parcelable class lookup, array bounds
and null-Parcel refusal are checked under `-Xcheck:jni` on actual ART.

A separately compiled native mutant drops the received Binder reference.
It must reach the exact independent identity assertion and exit 73; a loader,
verifier, JNI or signal failure cannot count as its rejection. DEX and ELF bytes
are pulled back and compared before either result is accepted.

The lane validates API 29 or API 34 and x86_64 emulator identity. It does not
claim a kernel Binder transaction, a Shizuku server, authorization, app-owned
capability lifecycle, acquisition, a working Activity, or physical TAB_P10 use.
