# Native libc boundary: Bionic and the Debian/glibc follower

This is a reusable **platform probe**, independent of curses. It exercises real
libc calls through the selected C compiler/headers/linker. It is not a replacement
for a consumer's own native wrapper, Idric ABI lowering, JNI, DEX, curses, or
application acceptance. A passing standalone probe cannot grant any of those
implementation-specific claims.

## What runs

Seventeen diagnostic groups cover anonymous mappings and zero-fill; mapping
error/errno translation; nonzero file offsets; sparse file offsets above 4 GiB;
private versus shared mappings and `msync`; `mprotect` including a real rejected
write followed by restored write access; non-destructive `madvise`; relative
`openat`, file identity, close-on-exec, read/write/seek; invalid-descriptor errno;
empty and ready pipe `poll`/`select`; socket readiness and a full 64-bit epoll
payload; loading and calling a real fixture DSO plus missing-symbol errors;
mutex/condition/create/join and thread-local errno; monotonic clock/nanosleep;
and API-24-safe random-byte acquisition from `/dev/urandom`.

Random-byte acquisition does not test entropy quality. `MADV_NORMAL` does not
claim every advice works. POSIX fd-based waiting is one backend, not the semantic
model for every event source. There are no raw futex or raw syscall-number tests.

Each case runs in a separate, time-bounded child process, with core files disabled.
Setup errors, signals and timeouts fail; none count as an expected bad result.
One deliberate semantic mutation per diagnostic group must be rejected by the
self-test. These mutations exist only in a separately compiled self-test binary,
never in a shipped runtime probe. This proves discrimination of these particular
bad observations, not exhaustive coverage of every possible libc/ABI defect.

## Target matrix

| Target | Compiler/libc | Offset builds | Execution here |
| --- | --- | --- | --- |
| Debian x86-64 | native C17 / glibc | default and `_FILE_OFFSET_BITS=64` | Host checks run during build |
| Android ARMv7a | NDK 27.3.13750724 / Bionic / API 24 | default and `_FILE_OFFSET_BITS=64` | Cross-build only |
| Android AArch64 | same pinned NDK / Bionic / API 24 | default and `_FILE_OFFSET_BITS=64` | Cross-build only |

Both explicit `mmap64` and ordinary `mmap` are exercised. The large ordinary-mmap
case runs only when the actual `off_t` is wide enough; the explicit 64-bit case
always runs. This keeps the ARMv7 default ABI visible instead of hiding it behind
a global large-file define. Pointer, long, offset and time widths are recorded.

Mapping lengths and offsets use `sysconf(_SC_PAGESIZE)`. The ARM `mmap2` syscall's
4096-byte offset unit is **not** an assertion that memory pages are 4096 bytes.
Applications call libc `mmap`/`mmap64` with byte offsets; the libc wrapper owns
syscall conversion. No syscall encoding is duplicated here.

AArch64 binaries use the two NDK-r27 16-KiB linker flags and their actual ELF
LOAD/RELRO alignment is checked. A 4-KiB run does not establish 16-KiB runtime
acceptance. A 16-KiB emulator/device run remains a separate follower obligation.
The sparse-file test writes only a few bytes, but the filesystem must support a
logical file size above 4 GiB. Lack of support is a visible setup failure.

## Build and host verification

Use a clean checkout at the intended immutable commit. Output directories must
be new: existing directories are rejected rather than recycled as evidence.
The build scripts are an explicit Bash/POSIX-shell build/test boundary; the
assertions and negative-test runner are C17. No Python, Java, Gradle, compiler
backend, or package-manager bootstrap is introduced.

```sh
bash native-boundary/build.sh host /tmp/native-host
ANDROID_NDK_HOME=/opt/android-ndk-r27d \
  bash native-boundary/build.sh armv7a /tmp/native-armv7a
ANDROID_NDK_HOME=/opt/android-ndk-r27d \
  bash native-boundary/build.sh aarch64 /tmp/native-aarch64
```

Prerequisites: Debian, Bash/POSIX sh, a C17 compiler and development headers,
Git, awk, coreutils, tar/gzip and readelf. Cross-building additionally requires
exactly NDK `27.3.13750724` with its Linux x86-64 toolchain. Provisioning is outside
the script: absent/wrong NDK is a failure, never another toolchain or runner OS.

GitHub jobs use `[self-hosted, linux, debian]`, check the userspace and architecture,
guard fork PRs at job scope, use immutable action pins, and check out the event's
exact source SHA. They do not establish runner registration or Hetzner execution
just by containing those labels. There is no Ubuntu-hosted fallback here.

The build records the actual checkout SHA, native-boundary tree, source hashes,
compiler version, compiler commands, target/API/NDK, inspected ELF files and
checksums. Android preprocessing must identify Bionic and the requested pointer
width; ELF checks verify class, machine, DYN/PIE interpreter, dependencies and
AArch64 LOAD/RELRO alignment. None of these inspect-and-package steps execute
Android code.

The host path also runs 34 positive cases and 34 targeted semantic rejections
across the two offset builds, executes the actual packaged probes, and rejects
four damaged bundles: changed binary, missing library, partial manifest and
duplicate manifest. To exercise only C fixtures:

```sh
bash native-boundary/test.sh /tmp/native-fixtures
CC=clang bash native-boundary/test.sh /tmp/native-clang-fixtures
```

## Execute the bundle on Android

Copy the **matching ABI bundle**, not a host executable, to an executable private
Termux directory. The normal delivery path is binary-only: do not install a
compiler or build the suite on the phone as a missing-package fallback.
Verify the archive's expected SHA-256 from its trusted build/publisher before
extracting. For a bundle already extracted into `bundle/`:

```sh
sh bundle/run.sh "$HOME/native-receipt-001"
```

The runtime requires only sh, standard file/hash utilities, Android `getprop`,
the dynamic linker and libc, and a writable scratch directory. It does not need
root, networking, shared-storage permissions, Java, curses or a compiler.
It checks the complete manifest before executing both offset builds and retains
all stdout/stderr, hashes, source revision, API/build/ABI properties, kernel,
actual page size and type widths. A failure in either build remains a failure.

`runtime.tsv` says `android-runtime-unclassified`, not physical-device accepted.
`ro.kernel.qemu` is recorded as an observation, never used to promote an emulator
or an unknown Android environment into physical-device evidence. An actual
operator/runner must attach this output to the existing follower-receipt system
with independently identified emulator/device and exact artifact digest.
Checksums detect changed bytes relative to the manifest; they do not authenticate
a manifest supplied by an untrusted party.

## Consumer integration and limits

Consumers check out this suite at a full immutable SHA and invoke the same build
script; they must record both their own source SHA and the suite pin. Do not copy
the C probe into each repository. ncurses is the first proposed consumer alongside
its independent linked PTY harness; no pruned implementation is restored.

Follow-up obligations remain explicit:

- Cat Food: publish and deliver both ABI bundles with digests, without compiling
  on the device or changing intended inventory to conceal missing deliverables.
- Idric/native/JNI: run corresponding operations through the **actual** bindings
  and retain a separate receipt. Do not gate independent direct-DEX generation on
  an unfinished ARM/Thumb compiler backend. The fork-based CLI probe must not be
  embedded unchanged into a multithreaded ART process.
- IB: exercise actual mapped fragment/index storage and cleanup with this platform
  result alongside it, including real page size, large offsets and error handling.
- Grease/Ish: exercise actual native file/mapping/wait wrappers and retain the
  distinction between fd, handle, queue and other event-source representations.
- Debian/Hetzner, ARMv7 runtime, AArch64 runtime and AArch64 16-KiB runtime each need
  their own exact-source follower evidence; one cannot stand in for another.

More API-specific coverage should be driven by real consumer imports, not by an
invented universal libc checklist. Cancellation, realtime signal ABI, raw syscalls,
W^X/JIT policy, JNI calling conventions, dynamic-loader namespace differences,
32-bit time rollover and end-to-end app behavior are not accepted by this suite.

## Sources

- Android Bionic, [32-bit ABI details](https://android.googlesource.com/platform/bionic/+/refs/heads/main/docs/32-bit-abi.md): `off_t`, large-file interfaces and time-width distinctions.
- Android, [16-KiB page-size support](https://developer.android.com/guide/practices/page-sizes): runtime page-size queries, NDK-r27 linker flags and actual-device/emulator testing.
- Bionic [mmap wrapper source](https://android.googlesource.com/platform/bionic/+/107cdd4/libc/bionic/mmap.cpp): byte-offset libc boundary versus the ARM mmap2 offset unit. This link is historical implementation evidence, not a claim that that revision is the current platform.
