# iCurses charcoal checkpoint

Product source: `dac8aa64292a54248b1c6804b9e9e60e5d296ce0`, parent `e2c2df710955c99cb2ba3b9b0384a2b8b489e9dd`.

The terminal change inherits the user's configured default foreground and background
through ANSI 39/49, rather than forcing black, white or cyan rows. This is terminal
palette inheritance, not a promise of #212121 under every terminal configuration.
The literal Icky C core, independent output observer, modified iLua application and
native adapters remain the software under test.

The icurses repository accepts the Git tree/commit objects but rejects new branch
references with HTTP422. An optimistic update of the unchanged existing PR5 head
also returned a GitHub server error; a subsequent read confirms that its head
remains e2c2df7. No PR5 source change or new icurses PR is claimed.

The adjacent workflow runs the existing product's own exact-source acceptance
commands against the retained commit, with the same ICK/Lua/observer pins. It builds
and executes real C/iLua code, rather than simulating a terminal. The durable patch
is [patches/icurses-terminal-defaults.patch](patches/icurses-terminal-defaults.patch).

Host checkpoint execution, Android emulator execution and ARM64 packaging are
separate results. No device is accessed or installed environment changed. Existing
shared executable admission remains BLOCKED by the product's documented owner
prerequisite; these functional tests do not replace that contract. Physical C67
acceptance and reviewable icurses branch publication remain outstanding.
