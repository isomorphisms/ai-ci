# Harness engineering and agent-legible repositories

Source: Ryan Lopopolo, “Harness engineering: leveraging Codex in an agent-first world,” OpenAI, 2026-02-11.
https://openai.com/index/harness-engineering/

This is a summary and design reference, not a replacement for this repository's current contracts or `AGENTS.md`. If this note conflicts with executable acceptance or current repository instructions, the current repository wins.

## What OpenAI reports

OpenAI describes an internal product built under an unusual constraint: humans did not directly write the repository's code. Codex produced application code, tests, CI, documentation, observability support, and repository tooling. The article reports roughly a million lines of code and about 1,500 pull requests over five months.

The useful result is not the production number. It is the change in engineering work. The humans concentrated on specifying intent, improving the environment in which agents operate, exposing evidence, and encoding feedback loops.

## Main lessons

### Fix the environment, not just the prompt

When an agent repeatedly fails, the durable question is what capability is missing: a tool, a clear interface, an observable state, a test, a constraint, or repository knowledge. Re-prompting harder is not a substitute for repairing the working environment.

### Make the running system inspectable

The article's agents can launch isolated application instances and inspect browser state, logs, metrics, and traces. This lets them reproduce failures and validate fixes instead of reasoning only from source text.

Agent-readable evidence is therefore part of the engineering interface.

### Keep repository knowledge in the repository

Important architecture, operating rules, plans, decisions, and known debt should be versioned and discoverable beside the code. Information available only in chat, private documents, or someone's memory is effectively absent from an unattended agent run.

### Use `AGENTS.md` as a map, not an encyclopedia

The team reports that a very large instruction file became noisy, stale, hard to verify, and expensive in context. Their replacement is a short entry point that directs the agent to structured, narrower documents.

This is progressive disclosure: begin with a small stable map and load deeper material only when the task requires it.

### Optimize for legibility

Repository structure should make the domain and its constraints recoverable by a new agent run. Predictable boundaries, boring interfaces, stable abstractions, explicit schemas, and directly inspectable behavior are often more valuable than cleverness hidden behind opaque machinery.

### Turn important rules into executable constraints

Documentation alone drifts. The article describes structural tests and custom linters for dependency direction, logging, naming, file size, reliability rules, and other architectural invariants.

The distinction is important: enforce invariants centrally while leaving implementation choices open where they do not affect correctness.

### Autonomy comes from feedback loops

Long autonomous runs are useful only when the agent can observe state, test its work, review failures, receive criticism, repair the change, and determine when human judgment is actually required. Autonomy is produced by that loop, not by merely giving a model a larger task.

### Agent-generated repositories still accumulate entropy

Agents reproduce patterns already present in a repository, including bad ones. OpenAI describes recurring cleanup work that scans for drift and converts repeated human preferences into durable rules.

Maintenance therefore becomes partly a garbage-collection problem: remove stale instructions, consolidate duplicated patterns, and encode recurring corrections before they spread.

### Their merge policy is local to their environment

The article also describes short-lived pull requests and relatively light blocking gates because agent throughput is high and corrections are cheap in their particular system. That is not a general conclusion that evidence or authorization can be weakened.

In this repository, exact evidence, authority, required checks, receipts, and unresolved blockers remain controlling.

## Relevance to ai-ci

The article supports several directions that already fit `ai-ci`:

- reusable rules should become executable contracts rather than duplicated prose;
- evidence should be machine-readable and tied to the exact revision and target under test;
- bad fixtures should prove that a claimed check can reject the corresponding failure;
- repository-local instructions should point to narrower sources of truth instead of growing without bound;
- stale documentation and stale trackers are themselves correctness problems because later agents may treat them as current state;
- human review preferences that recur should, when possible, be converted into deterministic checks with useful diagnostics.

A useful future question is whether agent-legibility itself can be partially tested: for example, whether required acceptance commands, authoritative documents, active plans, and evidence locations are discoverable from a bounded entry point. This note does not define such a contract.

## Limits of the article

The experiment is young, uses a particular internal product and tooling stack, and does not establish how a mostly agent-generated codebase behaves over many years. The authors explicitly identify long-term architectural coherence and the best placement of human judgment as unresolved questions.

The transferable lesson is narrower: if agents are expected to do substantial engineering work, the repository, runtime, tests, documentation, and evidence paths should be designed as an inspectable control system rather than as a pile of source files plus prompts.
