# Syllabus emotion classifier reuse

Canonical corpus: `bl4ckb4ll/syllabus/poetry/emotions/`.

The syllabus repository represents emotion labels as a many-to-many filesystem relation: canonical works stay in their normal location and each emotion directory contains symbolic links to works carrying that label. The initial label vocabulary is the Poetry Foundation-derived set already recorded in Syllabus: Anger; Anxiety & Insecurity; Blame & Guilt; Boredom; Disappointment; Gratitude; Grief; Humor; Joy & Contentment; Melancholy & Despair; Optimism; Passion.

This graph is intended to become reusable supervision for a learned multi-label classifier. Poetry is only the first labeled corpus; later the same classifier/index can be applied to other texts and, where useful, other kinds of material.

## Planned AI-CI role

- ingest canonical items plus symlink-derived reference labels;
- preserve multi-label membership rather than forcing one class per item;
- keep human/reference labels distinct from model-generated suggestions;
- evaluate exact-label-set behavior as well as per-label precision/recall where useful;
- split training/evaluation by canonical work (and preferably author/source where leakage matters), never by individual symlink;
- retain provenance for every reference label so corrections to the syllabus graph propagate cleanly;
- never mutate the reference symlink graph as a side effect of an evaluation run.

No training implementation is added by this note. It records the corpus and intended contract so future classifier experiments have a shared source of truth.
