# Screenshot-oracle compiler qualification

The original workflow compiled both maintained screenshot programs using an
ambient `cc`. Its historical image controls therefore did not qualify their
actual production through ICK.

The workflow now obtains the explicit compiler from the pinned shared
`ick-host` qualification action and refuses an unavailable compiler before
building either program. The image arithmetic, fixtures, thresholds and all
three negative-control diagnostics are unchanged. The existing fixed Actions
shell boundary is retained; no alternate compiler or runtime is selected.

The local compiler driver and frontend matched the retained ICK hashes, but
five current host support-object digests did not match that delivered runtime
closure. Local compiler qualification is therefore not claimed. Hosted
qualification of this exact workflow is the execution boundary. No emulator,
physical device, installation or renderer result follows from source review.
