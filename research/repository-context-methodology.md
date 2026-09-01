# Repository context is evidence, not training

Issue [#58](https://github.com/isomorphisms/ai-ci/issues/58) was opened
after a paired biomedical-engineering answer changed vocabulary and supporting
details when given curated repository context, but barely changed its
substantive recommendation. That result invalidates a working assumption:
putting relevant repository text in a prompt does not by itself create a
mechanism that will revise a model's conclusion.

This is not a claim that retrieval is useless. It is a boundary statement.
Retrieval can make evidence available at inference time. Availability,
selection, correct interpretation, state update, and decision change are
different events. A repository-backed system must supply the missing links
between them.

## What inference does

For an ordinary autoregressive transformer, generation at a token position can
be summarized as

```text
next-token distribution = model_with_fixed_parameters(
    system text,
    user text,
    retrieved text,
    earlier generated tokens
)
```

The parameters are fixed during an ordinary inference request. Self-attention
allows each position to compute with representations of earlier positions, and
the feed-forward layers transform those representations. The retrieved text
therefore changes activations, attention patterns, and the key/value state used
while generating this request. It does not ordinarily update the model
parameters, become durable model memory, or install a new reasoning procedure.
The basic architecture is described by
[Vaswani et al. (2017)](https://arxiv.org/abs/1706.03762).

“Pretrained prior” is useful shorthand but should not be mistaken for a
separate box that the implementation explicitly combines with a context box.
Pretraining and post-training produced parameters `θ`; those parameters
implement a conditional distribution `pθ(next token | preceding tokens)`.
Both familiar default answers and responsiveness to supplied evidence are
behaviors of that same fixed network. Because their interaction is nonlinear,
an output usually cannot be decomposed into an independently measurable
“percentage from weights” and “percentage from context.”

The parameters encode strong regularities learned across training: common
answer structures, associations, facts, styles of argument, and post-training
preferences. Prompt text conditions those regularities. A passage can be
copied, summarized, ignored, misread, or assimilated into a familiar answer
pattern. Attention makes use of context possible; it does not guarantee that a
particular passage controls the decision.

Research bears out the practical limits:

- In-context information is not used uniformly across a long prompt.
  [Liu et al. (2024)](https://aclanthology.org/2024.tacl-1.9/) found strong
  position effects, often with better use near the beginning or end than in the
  middle.
- When external evidence conflicts with parametric knowledge, receptiveness
  depends on how coherent and convincing the evidence is. Mixed evidence can
  produce confirmation bias toward the model's existing knowledge
  ([Xie et al., 2024](https://arxiv.org/abs/2305.13300)).
- Irrelevant retrieved material can reduce performance rather than merely waste
  tokens. Training models when to use retrieval improved robustness in the
  experiments of
  [Yoran et al. (2024)](https://arxiv.org/abs/2310.01558).

Context position, length, density, redundancy, relevance, conflict, and source
signals therefore affect the computation. None is a universal knob whose
setting guarantees evidence-sensitive reasoning.

## RAG, in-context learning, and training are not synonyms

| Method | What is supplied or changed | Persists after the request? | What it is suited to |
|---|---|---:|---|
| Pretraining | Model parameters are optimized on a large token-prediction corpus | Yes | Broad linguistic and world regularities; the starting repertoire |
| Supervised or instruction fine-tuning | Parameters, or trainable adapters, are optimized on demonstrations and task instructions | Yes | Repeated task behavior, formats, domain procedures, and response policies |
| Preference tuning, including RLHF or DPO | Parameters are optimized from preferences between outputs, directly or through a reward model | Yes | Which behaviors or answers are preferred; not a dependable document store |
| In-context learning | Instructions or demonstrations are placed in the current token sequence | No | Temporarily selecting or inferring a task, mapping, format, or strategy already learnable by the fixed model |
| Retrieval-augmented generation | A retrieval system selects external material and makes it available to the generator for this request | The corpus persists; the model change does not | Current, private, case-specific, sourceable evidence |
| Constrained intermediate representation and executor | The system turns evidence into declared states, relations, rules, or operations and checks or executes them outside free-form generation | The representation and rules persist | Invariants, diagnostic transitions, calculations, provenance, and refusal boundaries |

The original RAG work did more than paste search results into a generic prompt:
it defined a model with a parametric generator and non-parametric document
memory and trained retrieval/generation components for knowledge-intensive
tasks ([Lewis et al., 2020](https://proceedings.neurips.cc/paper/2020/hash/6b493230205f780e1bc26945df7481e5-Abstract.html)).
Current usage often calls any “retrieve passages, then prompt a chat model”
pipeline RAG. That usage is reasonable, but it describes a weaker guarantee:
the generator may never have been trained to use this repository, resolve its
conflicts, or follow its decision structure.

In-context learning is a behavior of the generator, not the retrieval step.
Few-shot prompting showed that models can change task behavior without gradient
updates ([Brown et al., 2020](https://arxiv.org/abs/2005.14165)). Work on
simplified regression tasks shows that transformers can implement learning-like
algorithms in their forward pass, but also emphasizes that the general
mechanisms remain incompletely understood
([von Oswald et al., 2023](https://proceedings.mlr.press/v202/von-oswald23a.html)).
This establishes capacity, not a guarantee that arbitrary prose examples cause
a deployed model to infer the procedure we intended.

Training changes the persistent behavior. Instruction tuning changes parameters
using many demonstrated tasks and can improve generalization to unseen
instructions ([Wei et al., 2022](https://arxiv.org/abs/2109.01652)).
Supervised fine-tuning followed by human-preference training is the InstructGPT
pattern ([Ouyang et al., 2022](https://arxiv.org/abs/2203.02155)). LoRA changes
a smaller set of trainable adapter parameters while leaving the base parameters
frozen, but it is still training, not retrieval
([Hu et al., 2021](https://arxiv.org/abs/2106.09685)). Preference methods such
as DPO likewise alter behavior from ranked outputs
([Rafailov et al., 2023](https://arxiv.org/abs/2305.18290)).

The design boundary is consequently:

- retrieve evidence that is current, private, case-specific, voluminous, or
  must remain sourceable;
- train when the system repeatedly lacks a behavior for selecting, comparing,
  or applying evidence, and that behavior cannot be made explicit more safely;
- use a constrained representation and an executable procedure when the
  required inference has stable states, admissible transitions, arithmetic,
  lookup rules, or hard invariants.

Fine-tuning does not make a guarantee either. It changes the probability of
behaviors over a training distribution. A rule engine, type checker, database
constraint, or diagnostic transition table can enforce a property that a
fine-tuned generator can still violate.

## Reading the biomedical-engineering experiment correctly

The paired result established at least two things: the supplied material was
available enough for the model to mention additional facts, and those facts did
not materially alter the recommendation. It did not identify which of the
following explanations is true:

1. the new evidence lay on the same side of the decision boundary as the
   model's default recommendation;
2. the evidence was relevant but not decisive;
3. the prompt did not identify the decision rule or the user's actual tradeoffs;
4. the model extracted facts but failed to update a decision-bearing state;
5. a strong familiar answer pattern dominated the evidence;
6. conflicting, redundant, or badly positioned context diluted the decisive
   material.

The result is therefore a failure of the assumption “more curated text
reliably improves reasoning,” not proof that no retrieval architecture can
work. The next investigation should observe the intermediate state that the
current experiment left hidden.

A useful repository-backed run separates four claims:

1. **Retrieval:** the decisive record was returned.
2. **Interpretation:** the record was converted into the right scoped claim.
3. **Update:** that claim changed a hypothesis, constraint, score, or candidate
   action.
4. **Outcome:** the changed state produced a better conclusion or next action.

Success at the first or second claim cannot stand in for success at the third
or fourth.

## Architecture for ASE

ASE should not be primarily a pile of prose chunks presented to a model. It
should preserve source prose, but compile the decision-bearing parts into
diagnostic records. A record should be able to state, where applicable:

- vehicle, system, operating condition, and symptom scope;
- observation or measurement, including units and allowed range;
- candidate fault or mechanism;
- diagnostic test and prerequisites;
- expected observation if the candidate is true and if it is false;
- what the result supports, weakens, or rules out;
- next test or action;
- safety boundary, contraindication, and stopping condition;
- source, edition, section, and uncertainty.

The run should then have an explicit path:

```text
case observations
    -> applicable diagnostic records
    -> competing candidates and discriminating tests
    -> checked state update
    -> next test / diagnosis / missing-evidence result
    -> natural-language explanation
```

The model may help translate a user's account into proposed observations,
retrieve records, and explain the checked result. It should not silently invent
measurements, collapse unknown into false, or replace the diagnostic state with
a fluent paragraph. When a decision table, threshold comparison, electrical
relation, torque specification, or state transition can be executed
deterministically, execute it. Reserve model judgment for genuinely semantic
boundaries and expose the evidence used there.

This architecture gives repository growth a plausible causal route to better
answers: a new ASE record can add a candidate the system previously lacked,
introduce a discriminating test, change an applicability condition, or correct
a transition. Merely adding another explanation of the same default advice
does none of those things.

## Other repository-backed systems

The same division applies, but the decision-bearing representation differs by
domain.

- **Blackball:** represent claims, cited source spans, dates, institutional
  actors, causal assertions, competing interpretations, and scope limits.
  Retrieval should populate a claim/source graph. The generated account should
  be downstream of explicit support and conflict relations, not an invitation
  to make a default narrative sound more repository-aware.
- **Syllabus:** represent books, excerpts, courses, teachers, departments, and
  provenance links. Retrieval can answer where a work appears; a separate
  declared method is required before inferring what a complete education or
  canon means.
- **IB and ingestion systems:** preserve source identity, acquisition and
  recovery stages, extracted records, and unknown fields. A generator can
  summarize those records, but its prose cannot repair a failed acquisition or
  extraction boundary.
- **Compiler and release repositories:** use retrieval to locate specifications
  and prior incidents; use types, compilers, artifact probes, and exact receipts
  to decide acceptance.

The general rule is that repository text belongs on the evidence plane.
Domain states, relations, admissible transitions, and acceptance predicates
belong on the decision plane. A language model can mediate between the planes,
but should not make the boundary invisible.

## Evidence that would justify the infrastructure claim

A small number of causal, domain-valid experiments is more useful than a huge
lexical-overlap suite. To claim that ASE, Blackball, or another repository
improves downstream reasoning, require a chain like this:

1. Identify a real case that the unassisted system conflates, misdiagnoses, or
   cannot resolve.
2. Declare the correct discriminating outcome with an expert, primary source,
   calculation, or executable oracle before inspecting the new answer.
3. Show that the relevant repository record is retrieved and produces the
   intended intermediate state.
4. Remove or replace the decisive record. The state and conclusion should
   change in the predicted direction.
5. Change one decision-bearing fact in a paired case. The system should change
   the diagnosis, next test, ruled-out candidate, historical claim, or
   uncertainty exactly when the domain method says it should.
6. Add irrelevant, redundant, and conflicting material. Irrelevance should not
   move the conclusion; genuine conflict should become an explicit unresolved
   state or be resolved by a declared source rule.
7. Repeat on held-out, incident-derived cases and report downstream errors,
   abstentions, and harmful changes, not citation count, answer length, or
   repository vocabulary.

The decisive tests are interventions. If adding, removing, or changing the
repository's decision-bearing evidence does not cause the predicted state
change, the repository has not been shown to be responsible for the answer.
If it does cause that change but the final outcome is not better under an
independent oracle, the architecture is responsive but not yet useful.

For ASE, useful outcome measures include whether the system distinguishes two
previously conflated faults, chooses a more discriminating next test, avoids an
unsafe or unnecessary action, rules out a tempting wrong diagnosis, or returns
`missing_evidence` when the required measurement is absent. For Blackball,
they include whether a claim gains or loses support, whether a dispute remains
explicit, whether a causal conclusion narrows to the source's scope, and whether
a newly added primary source changes the account for a stated reason.

Lexical overlap, citation presence, retrieval recall, and context utilization
can remain plumbing diagnostics. They are not outcome measures.

## Consequence for ai-ci

ai-ci should add a repository-backed evaluation case only when it declares:

- the decision-bearing repository record;
- the scoped intermediate state it should change;
- the independent downstream oracle;
- an ablation or replacement intervention;
- a paired fact change that should alter the result;
- an irrelevant-context control that should not;
- the exact revision of repository, representation, model, and evaluator.

These cases belong beside the existing incident-derived evaluations, not in a
large provider leaderboard. The first goal is to validate one causal chain for
ASE and one for a claim/source system such as Blackball. Only observed failures
from those chains should become additional regression families.

The architecture claim is justified when repository changes repeatedly produce
the predicted intermediate changes and improve held-out downstream decisions
under independent oracles. Until then, the honest description is narrower:
the system retrieves and presents repository evidence.
