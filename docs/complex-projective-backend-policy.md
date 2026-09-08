# Complex/projective backend leadership policy

Thumb-2 remains the human-in-the-loop leader for general backend development.
Complex and projective arithmetic are an explicit current exception. Their
leading executable implementation and CPU oracle are x86-64. Thumb-2, GPU, and
other implementations are followers of the shared mathematical semantics. The
current Thumb-2 complex/projective implementation is provisional and may later
be overwritten or replaced when the user personally returns to hands-on Thumb
backend work.

That replacement is not a semantic break when the new lowering continues to
satisfy the same mathematical contract and corpus. In particular, the current
Thumb-2 implementation is provisional and disposable: its register grouping,
floating-point choices, helpers, and lowering shape do not constrain either the
canonical semantics or the x86-64 leader.

This exception is deliberately narrow. It does not make x86-64 the general
leading Idric backend. It establishes this order only for complex and
projective arithmetic:

1. backend-neutral mathematical semantics in the canonical compiler/library;
2. the x86-64 executable implementation and CPU oracle;
3. the shared numerical, projective, and rendering corpus;
4. provisional Thumb-2 and GPU/shader followers.

`Complex`, a dimensioned complex coordinate space, and a projective point are
semantic distinctions. A pair of machine reals, an XMM register, a Thumb
register group, or a two-component shader vector is a lowering choice. A
projective point is represented by nonzero homogeneous coordinates modulo
common nonzero complex scaling; raw coordinate equality is not projective
equality. Receipt policy must therefore keep exact representation checks,
floating numerical checks, projective equivalence, and rendering checks as
separate acceptance categories.

## Evidence policy

The reusable verifier under `complex-projective/` checks a contract written by
the trusted receipt-producing workflow. Every row is bound to:

- the canonical corpus repository, ref, full revision, path, and SHA-256;
- the compiler repository, ref, and full revision;
- the backend repository, ref, and full revision;
- an application repository, ref, and full revision when an application is in
  the tested path;
- one target, backend family, leader/follower role, environment, and witnessed
  acceptance stage.

All refs and revisions must be repeated exactly in every receipt row. A receipt
from a different branch or revision does not match. The trusted caller must pin
the contract to the revisions checked out for the current event; it must not
select a previously green contract or receipt from another branch. This is an
irreducible trust boundary: a local verifier cannot independently learn which
remote branch head a CI coordinator intended. A receipt-producing workflow
must write evidence only after the named command ran against those exact
checkouts, and must preserve the resulting witness bytes.

For the x86-64 leader, a complete contract requires successful evidence for
direct build, native execution, exact corpus, numerical corpus, projective
equivalence corpus, deterministic headless rendering, thin-Debian execution,
and GitHub Actions execution. A contract cannot downgrade those requirements
to `skip` or `blocked`.

Follower contracts still declare all four mathematical acceptance categories,
but may state `skip` or `blocked` for work not yet demonstrated. Those states
are recorded honestly and never mean that the stage passed. GPU contracts also
declare the strongest demonstrated pipeline stage. They must contain the full
ordered ladder from generated shader through vendor/device receipt; only the
contiguous prefix through the declared ceiling may pass. Shader inspection,
compilation, linking, loading, execution, captured rendering, and a real
vendor/device receipt are distinct claims.

This repository contains synthetic self-test receipts only. They demonstrate
that the verifier accepts and rejects the intended shapes; they are not Idric
backend, thin-Debian, GitHub Actions, rendering, or hardware receipts.
