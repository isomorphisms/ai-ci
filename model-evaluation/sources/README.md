# Pinned model implementation source checkouts

The gitlinks retain GPT-OSS's reference implementation plus two distinct Pythia-capable implementation sources: Hugging Face Transformers (GPT-NeoX model architecture) and EleutherAI GPT-NeoX. Their upstream licenses and history stay in the source repositories. Git submodule initialization materializes the code; weights are never committed here.

GPT-OSS source: `openai/gpt-oss` at `7b583341fe16729127f6d5b94a7b09ccae97e1a1`.
Transformers source: `huggingface/transformers` at `90ef040d400e94c771edb8b806c9c294e1b6a13f`.
GPT-NeoX source: `EleutherAI/gpt-neox` at `cf40e42142694e40aab158b6c81ff3f1d4fc921a`.

These pins are inspection/materialization dependencies, not claims that these revisions have executed this suite. The local adapter currently uses an explicitly provisioned Transformers/PyTorch runtime and records its actual installed versions. GPT-NeoX-native execution and cross-implementation token/logit agreement remain unimplemented comparison work. Pythia-12B and Pythia-6.9B are two model sizes, not substitutes for implementation diversity. Flexible Pipes references these AICI-owned sources instead of creating another mutable model source registry.
