# Cat Food ↔ issh

Cat Food should feed `isomorphisms/issh` as an ordinary moving checkout:

```text
issh https://github.com/isomorphisms/issh.git master none
```

This is deliberately not a submodule or commit pin. Cat Food tracks the current `issh` workbench branch, while `issh` remains a separate repository for the SSH library/CLI boundary used by consumers such as `mbox`.

`contracts/catfood-issh-v0.contract.tsv` checks the exact Cat Food manifest declaration. Its hostile fixtures prove that a missing `tools.tsv` and a nonempty manifest without the `issh` link are both rejected.

The contract does not make network claims. Cat Food's own `check-manifest.sh --remote` remains responsible for proving that the declared remote branch exists.
