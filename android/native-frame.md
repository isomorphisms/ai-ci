# Wait for the target native process to post a frame

`native-frame.grease` is the shared sensor-app emulator acceptance boundary.
Android's launch acknowledgement can precede the first cold font-cache render.
The old one-shot log query failed after successful replacement and launch in
both Gyroscope and Magnetometer.

The helper keeps the first-frame requirement, waits up to 30 one-second polls,
scopes logcat to the launched process, and retains launch, APK digest, frame
time/cache bytes, process logs, memory and screenshot evidence. It records
same-candidate replacement separately from an old-build upgrade and never
claims physical-device acceptance.

Inputs: absolute GITHUB_WORKSPACE, ANDROID_HOME, INSTRUMENT_APK,
INSTRUMENT_PACKAGE and CANDIDATE_SHA. Execute with the authenticated compiled
Grease launcher and host engine used by the existing Subpixel workflow.
