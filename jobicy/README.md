# Jobicy status oracle

The independent expected results are 123456 active, 123457 closed, 123458
unknown. Kitchen must obtain actual.tsv by running the installed Idriç CLI
against the shared synthetic status response and projecting its exact ID/status
columns. The expected result belongs here and does not call the CLI's decoder.

The deliberately incorrect mutant changes unknown to closed. The same
`JOBICY-STATUS-DISTINCTIONS` assertion must reject that output. Both the passing
comparison and the rejected mutant must be executed and captured in the
Flexible Pipes receipt. Synthetic status evidence does not establish provider
status or physical-device execution.
