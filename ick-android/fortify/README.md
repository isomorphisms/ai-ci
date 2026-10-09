# Bounded ICK Bionic Fortify profile

This explicitly selected C profile retains `_FORTIFY_SOURCE=2` for Android
API 26 or later. The original NDK public headers still supply declarations,
types, availability and layout. Only their `bits/fortify` implementation
headers are overlaid. The implementation was checked against NDK r27c and
r29; it does not claim all Clang `overloadable` or `pass_object_size` behavior.

| Supported public function | Checked implementation | Object size |
| --- | --- | --- |
| `memcpy` | `__builtin___memcpy_chk` | destination, mode 0 |
| `memmove` | `__builtin___memmove_chk` | destination, mode 0 |
| `memset` | `__builtin___memset_chk` | destination, mode 0 |
| `strlen` | Bionic `__strlen_chk` | source, mode 0 |
| `strchr` | Bionic `__strchr_chk` | source, mode 0 |
| `snprintf` | `__builtin___snprintf_chk`, Bionic flag 0 | destination, mode 1 |
| `vsnprintf` | `__builtin___vsnprintf_chk`, Bionic flag 0 | destination, mode 1 |
| `fwrite` | Bionic `__fwrite_chk` | source, mode 0 |
| `read` | Bionic `__read_chk` | destination, mode 0 |
| `write` | Bionic `__write_chk` | source, mode 0 |
| `poll` | Bionic `__poll_chk` | descriptor array, mode 1 |

Always-inlined GNU functions evaluate public arguments once and propagate
object sizes after argument side effects. A function-like macro was rejected
during qualification because `memcpy((++count, destination), source, size)`
lost the known destination size. That exact case and corresponding cases for
all eleven supported functions remain runtime regressions. Checked builtins
may optimize proven-safe operations; dynamically unsafe known-size operations
must call Bionic's checked ABI and abort. Unknown object sizes retain the
underlying object-size model's limits.

Fortified functions outside that table are poisoned at compilation:

- String/memory: `memchr`, `memrchr`, `mempcpy`, `stpcpy`, `strcpy`, `strcat`,
  `strncat`, `stpncpy`, `strncpy`, `strlcpy`, `strlcat`, `strrchr`.
- Standard I/O: `fread`, `fgets`, `sprintf`, `vsprintf`.
- File I/O: `getcwd`, `pread`, `pread64`, `pwrite`, `pwrite64`, `readlink`,
  `readlinkat`, `open`, `open64`, `openat`, `openat64`.
- Polling, paths and permissions: `ppoll`, `ppoll64`, `realpath`, `umask`.
- Sockets and legacy memory: `recv`, `recvfrom`, `send`, `sendto`, `bcopy`, `bzero`.

Each of these thirty-seven names has its own required poisoned-identifier negative
test. Applications needing one must extend and qualify the profile or keep
their migration blocked. Do not erase the rejection, redefine Fortify, or
route glyph-bearing C through a different compiler. Explicit function-pointer
calls have the usual Fortify bypass boundary; this profile does not claim
whole-program memory safety.

The runtime fixture compiles with ICK and assembles/links with the consumer's
NDK. Its x86_64 static executables use actual Bionic, run directly on the Linux
host at O1/O2/O3/Os, exercise valid calls, and require twenty-two child processes
to terminate with SIGABRT for dynamic overflows. A control deliberately calls
unfortified `read` on an invalid descriptor; the fixture must reject it with
exit 55. ARMv7 and AArch64 fixtures receive compile, assembly, static-link and
ELF checks; they are not executed by this host gate. Retained `-g`, DWARF 4,
stack protection and warnings-as-errors exercise the real NDK assembly boundary.

At O0, Bionic's existing headers do not enable Fortify. The adapter does not
silently alter that upstream optimization boundary. The profile requires
active runtime checks when its implementation headers are selected, rejects
C++ and API levels below 26, and never lowers the requested hardening level.
