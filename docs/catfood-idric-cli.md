# Cat Food ↔ Idriç CLI

Cat Food should feed `isomorphisms/idric-cli` as an ordinary moving checkout:

```text
idric-cli https://github.com/isomorphisms/idric-cli.git main none
```

This is deliberately not a submodule or commit pin. The CLI repository is adjacent to the Idriç compiler rather than part of the compiler, and merely making the CLI available must not pin Idriç or ICU.

`contracts/catfood-idric-cli-v0.contract.tsv` checks the exact Cat Food manifest declaration. Its hostile fixtures prove that a missing `tools.tsv` and a nonempty manifest without the Idriç CLI link are both rejected.

The contract does not make network claims. Cat Food's own `check-manifest.sh --remote` remains responsible for proving that the declared remote branch exists.
