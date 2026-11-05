# Scientific control pixel sampler

This is a Grease terminal orchestration task: install exact signed bytes into a
fresh emulator, launch the actual checked-shader application, verify its runtime
source binding and read independent control pixels from the real screenshot.
It does not implement the scientific renderer or replace its mathematical oracle.

The type boundary is APK/source digests and target identity → observed native
viewport dimensions → bounded integer sample positions → decoded RGB roles.
The native dimensions come from the real process, not an invented viewport.
Control centers/radii are derived independently from the documented placement
geometry. Integer rounding stays within the opaque interior of each mark/surface.

The initial shell arithmetic-expansion probe was rejected by the exact verified
canonical Grease entrypoint with OILS-ERR-19. It is retained beside this account.
The native Grease integer expression `height * 48 // 1000` and explicit
`int("480")` conversion both execute successfully through the published portable
launcher and unchanged pinned host engine. No Bash or substitute runtime is used.
The sampler uses those native expressions. Its parser check is separate from
actual Android execution.

The first actual candidate was source 5025b41cea08b2f173eb54b9344819be7c82fc55.
Run 41973691296 retained two observer failures. API 29 sampled the .40R outer
antialiased ring edge (137), while both opaque control backgrounds passed. The
correct primary sample is the midband .325R, preserving the #F4F4F4 predicate.
API 34 captured an entirely black compositor frame: the application's native
first-frame log occurs before eglSwapBuffers. A bounded presented-control poll
now retains every attempted screenshot and still fails if the actual selected
control never appears. It does not certify the startup transition sequence.

The scientific field is excluded from dark coverage because its intended colors
are data. The checks sample selected #383838 and inactive #2F2F2F control interiors,
primary #F4F4F4 marks and secondary #B4B4B4 marks, with the same two-value compositor
tolerance as the native View observers. Numeric/color parity, rotation, startup
frame sequences and physical C67 behavior are not inferred from these samples.
