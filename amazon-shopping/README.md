# Amazon shopping: independent source/receipt oracle

This is the independently maintained *judge*, not an Amazon client or
product search implementation. It consumes the raw receipts of the
\`isomorphisms/flexible-pipes\` candidate \`amazon-product-lookup\` runner.
The runner must use Cat Food's Grease/AZ stable command through the
SHA-pinned Kitchen adapter. Neither the checker nor its mutation test
may fetch or fabricate Amazon product search output.

\`sh amazon-shopping/check-receipts.sh RECEIPTS FLEXIBLE_PIPES_CHECKOUT\`

Requirements verified against the actual runner output:

- one immutable \`receipt.json\` and saved \`stdout.bin\`/\`stderr.bin\`
  per named acceptance case, matching the exact checked-out FP commit,
  pipeline specification hash, stage argv, exit and SHA-256 stream hashes;
- source-provided affiliate links use exactly \`macguyver03-20\` and
  preserve the ASINs linked to documented, **different** repair roles;
- the failed stage must have a nonzero status, not a green wrapper;
- the known price and current listing availability remain \`UNKNOWN\`
  rather than the report upgrading a historical ASIN to in-stock;
- HTML challenge, missing dependencies, unknown ASIN, wrong repair role,
  and invalid input cannot yield accepted merchant links.

\`sh amazon-shopping/mutation-test.sh RECEIPTS FLEXIBLE_PIPES_CHECKOUT\`
requires rejection of eight hostile variants, including semantic lies that
recalculate the receipt hashes. Neither an independent checksum nor a
pass on a mocked search is evidence of an actual available Amazon offer.

The two repair identifiers are historical only. Current vehicle, door,
weatherstrip material, adhesive compatibility and seller conditions are
outside the authorized evidence of this check.

The integration workflow in Flexible Pipes checks out this AI-CI source
at an exact SHA and applies both scripts **after** the real Grease/AZ
integration tests. Its raw receipts are retained as Actions artifacts.
This check must be rerun for every material AZ/Kitchen/Cat Food/FP
source pin change; a green older head does not apply to a new head.
