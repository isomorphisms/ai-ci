# Observe new Intent forwarding independently

Input: actual compiler-produced NewIntentActivity DEX and a separately pinned
baksmali decoder. Output: decoded method evidence and a host-only acceptance
receipt. Neither a source plan nor the compiler's own readable output is an
input to this observer.

The observable contract is parent lifecycle before the checked handler, exact
Activity/Intent parameter forwarding, and retention of that same Intent by the
fixture. A separately compiled source which retains the earlier Intent must
fail. This fixed fixture has a fully specified instruction sequence; a general
DEX program is outside the observer's scope. The existing decoded instruction
format permits a small Grease orchestration of the independent decoder and
plain-text comparisons; no general helper program or fallback is needed.

ART dispatch, package lifecycle, cold/warm application delivery, query history,
and physical devices remain separate boundaries. The actual compiler-produced
positive and recovery DEX passed. A separately compiled checked source which
keeps the old Intent failed with the expected retention diagnostic. The
observer checks complete method bodies, including register declarations and
every instruction, so inserted argument-overwriting instructions cannot be
hidden by filtering only invocation lines. ART and physical devices remain
NOT_RUN.
