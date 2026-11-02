# Read the actual API34 decoder acknowledgement

The fresh F43 API34 decoder job125049928125 passed actual decoded text,
clipboard/reflow and offline/reboot observations, then stopped at the observer's
literal ADB unroot acknowledgement check before independent source readback.
The retained artifact13111240470 is21088218 bytes, SHA256
39eb376b2a5d3642e04c66be61aa393a4bf27e4c55c97cc9cfa8f6138caa2620.

This Grease inspector verifies that immutable archive and reads only its exact
snapshot-root, snapshot-unroot and exit files, including byte lengths and hex.
It neither contacts an Android device nor claims the post-unroot UID, which the
failed observer did not reach. No missing acknowledgement is fabricated.

Type sketch: immutable archive identity -> bounded original process result and
stdout bytes -> diagnosis. This is evidence gathering, not reader, Binder or
physical acceptance. The runtime must still require a bounded reconnect and the
actual shell UID2000 before source validation. Results are pending.
