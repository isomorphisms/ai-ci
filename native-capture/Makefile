ICK ?= /explicit-source-qualified-ICK-is-required
CFLAGS ?= -fno-link-libatomic -std=c11 -O2 -Wall -Wextra -Werror -pedantic
.PHONY: check
build/check: check.c
	mkdir -p build
	$(ICK) $(CFLAGS) check.c -lcrypto -o $@
check: build/check
	./build/check --check-workflow fixtures/eligible-trigger.yml
	./build/check --reject-skipped-trigger fixtures/skipped-trigger.yml
