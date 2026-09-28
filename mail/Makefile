CC ?= cc
CFLAGS ?= -std=c17 -Wall -Wextra -Werror -pedantic -O2
BUILD ?= /tmp/aici-mail-build
ROOT := $(abspath ..)

.PHONY: all test corpus-check
all: $(BUILD)/accept $(BUILD)/make-corpus $(BUILD)/replay $(BUILD)/large $(BUILD)/audit $(BUILD)/ssh-command

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/accept: accept.c support.h | $(BUILD)
	$(CC) $(CFLAGS) accept.c -lcrypto -o $@

$(BUILD)/make-corpus: make_corpus.c support.h | $(BUILD)
	$(CC) $(CFLAGS) make_corpus.c -lcrypto -o $@

$(BUILD)/replay: replay_mutant.c support.h | $(BUILD)
	$(CC) $(CFLAGS) replay_mutant.c -lcrypto -o $@

$(BUILD)/large: large/stream.c support.h | $(BUILD)
	$(CC) $(CFLAGS) large/stream.c -lcrypto -o $@

$(BUILD)/audit: audit.c support.h | $(BUILD)
	$(CC) $(CFLAGS) audit.c -lcrypto -o $@

$(BUILD)/ssh-command: ssh/fixture_command.c | $(BUILD)
	$(CC) $(CFLAGS) ssh/fixture_command.c -o $@

corpus-check: all
	$(BUILD)/make-corpus $(BUILD)/regenerated
	diff -r $(ROOT)/mail/corpus $(BUILD)/regenerated

test: corpus-check
	$(BUILD)/audit $(ROOT)/mail/corpus
	$(BUILD)/accept self-test $(ROOT)/mail/corpus $(BUILD)/replay $(BUILD)/mutation-receipts
