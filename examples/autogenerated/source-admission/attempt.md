# Independent source admission

## Types before implementation

The desired result is independent admission of a producer's acquired checkout against caller-owned repository, full commit, submodule policy and source role. A self-consistent candidate record is evidence to compare, not the expected answer.

Domain values: repository identity, source commit, source tree, checkout path, reference policy (`none`, `skip`, `recursive`), ordinary or ICK source role, committed reference declaration, gitlink, source material digest and candidate evidence bytes.

The central action has the contract `SourceExpectation → CheckoutPath → CandidateEvidence → IO Admission`. It independently reads Git objects and raw checkout bytes, reconstructs canonical material and compares complete rows and SHA-256. An admission failure names the first demonstrated mismatch. A passing result proves the selected source-checkout scope only.

Pure operations parse and validate domain values, pair declarations with gitlinks, enforce row/cardinality/path rules and construct canonical expected records. Effects read source, query Git, hash raw bytes and inspect symlinks. Process calls use the existing Idriç escaped argv-list API; no generated shell script, repair, fetch, checkout, producer invocation or source mutation belongs in the verifier.

Invariants: expected repository/commit/policy/role come from the independent caller; raw source matches the committed tree; declarations correspond one-to-one with gitlinks; recursively required children match exact origins/commits; skipped child bytes are outside admission scope; ICK's source lock agrees with its GCC declaration; complete canonical evidence matches independent observation. The separate fresh workbench replay checks that GCC was not populated. Invalid evidence, source or subprocess results fail closed. Equal material under relocation preserves identity.

The real implementation is attempted in Idriç first. Compiler source `2bce7677f513d711875e978bd6f5ad28b9e54d58` has a verified local Chez-backed host entrypoint, `Data.Text`, file reads and `System.File.Process.Escaped.popen2`. These facilities are sufficient for the first full attempt; no Python, Ithon, generic-C or shell implementation is selected.

## Acceptance plan

Independent fixtures construct their own real Git repositories and expected records. Required controls include valid none/skip/recursive material, nested references, empty `.gitmodules` leaves, whitespace relocation and repeats; rehashed wrong tree/material/omitted reference; wrong root or child origin/commit; incomplete or normalization-hidden source; wrong ICK lock; hidden index; and unsupported/escaping declarations. Verify that the checker never repairs the source or invokes network/build operations.

## Executed host evidence — 2026-11-14

The actual `.idric` verifier, fixture runner and staged replay compiled and executed through Idriç `2bce7677f513d711875e978bd6f5ad28b9e54d58`, its existing Chez host backend and its matching prelude/base library paths. The first invocation had an unset library search path and reported a missing Prelude while returning exit zero; subsequent checks require a real generated executable and actual behavior, not the compiler's exit alone. Explicit `CHEZ`, `IDRIS2_PREFIX` and `IDRIS2_PATH` locate the verified compiler-owned material. An unavailable composition alias was replaced with ordinary explicit function application. No fallback language/backend was used.

All 43 independent small Git cases pass. They execute the checker as a separate process and fingerprint source plus Git metadata before and after every verdict. Internally valid, rehashed wrong records reject; benign metadata and pathname variations pass. The final case list and exact first-failure diagnostics live in `SourceAdmissionFixtures.idric`, not in Cat Food's tests. The FIFO control is bounded by a timeout and requires the intended rejection, so a hang cannot count as a pass.

Actual ICK source `8a7aac0e42bc8af4550577bbc87e2a5a15eb9db7` was acquired through the existing Cat Food CLI, then independently admitted under both workbench/skip and producer/recursive expectations. The producer reference is GCC `6294f1d9e7536e5ffcde09d1528c918d63abfef5`. The full observer processes 167,777 committed entries, including 161,666 tracked GCC files. Complete recursive admission passed twice. Canonical records are retained under `source-closure/receipts/2026-11-14-host/`.

Independent controls exposed and repaired exact declaration-subsection prefix matching and reading a FIFO before checking its node kind. They also exposed Cat Food's false rejection of empty leaf declaration files; its existing branch was repaired. Root acquisition and the independent observer keep different implementations and fixtures.

One initial full-checker attempt ended with an invalid memory reference. Later complete runs and eight focused captures did not reproduce a primitive failure; `capture-attempt.md` retains the narrow investigation. No compiler or pipe-capture defect is claimed from that unexplained failed attempt. Hosted reproduction is a separate exact-head gate, not inferred from these local observations.

Source-only admission remains distinct from compiler execution witnessing, packaged closure, deployment, Android and physical-device acceptance. No specific missing Idriç capability remains for this implemented slice. If the unexplained runtime failure recurs, retain executable identity and the stage trace before selecting a language change.
