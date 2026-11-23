The first source did not lower: this Ithon frontend supports `∈` membership,
but not `∉`. The revised implementation spells negation explicitly. This was
a parse failure before any diagnostic task ran, not diagnostic acceptance.
