# Blackball context-effect evaluation

This directory starts a controlled comparison of responses produced with and without the `blackball` repository supplied as context.

The question is not merely whether the answer becomes more negative. The useful result space must distinguish substantive effect, evidential quality, run state, and uncertainty.

`mocks.tsv` contains the initial fake evaluator outputs. They are fixtures, not claims about a live model.

Initial result kinds:

- `positive`: Blackball improves the response, including guarding against the college trap and holding college administrators accountable for implied as well as explicit claims.
- `negative`: no appreciable difference.
- `in_between`: a real but mixed effect that does not justify a clear positive or negative verdict.
- `terrible`: Blackball makes the response worse.
- `conspiratorial`: the response becomes more pessimistic, but the added negativity is not supported by evidence, argument, or logic and cannot be substantiated from other sources.
- `failure`: the comparison does not yield a substantive result because the run itself failed.
- `unknown`: the comparison completed, but the effect cannot be classified reliably.

Do not collapse `failure` or `unknown` into `negative`. Do not treat `conspiratorial` as evidence that Blackball genuinely worsened the factual answer merely because its surface direction is pessimistic.

The first live experiment should hold the prompt, model, model settings, and evaluator constant and vary only whether the Blackball material is supplied. The transport can be ICU or another provider adapter; the verdict vocabulary remains provider-neutral.
