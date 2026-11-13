ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
BUILD ?= $(ROOT)/.build
ICK ?=
ICK_LINK_FLAGS ?=
EXECUTOR := $(BUILD)/aici-meta-corpus

ifeq ($(strip $(ICK)),)
$(error ICK must name the qualified compiler; generic compiler fallback is forbidden)
endif

.PHONY: test

$(BUILD):
	mkdir -p "$(BUILD)"

$(EXECUTOR): $(ROOT)/aici_meta_corpus.c | $(BUILD)
	"$(ICK)" $(ICK_LINK_FLAGS) -std=c17 -O2 -Wall -Wextra -Werror -pedantic "$<" -o "$@"

test: $(EXECUTOR)
	"$(EXECUTOR)" observe "$(ROOT)/cases.tsv" "$(BUILD)/raw-observations.tsv"
	"$(EXECUTOR)" classify "$(ROOT)/cases.tsv" "$(ROOT)/expectations.tsv" "$(BUILD)/raw-observations.tsv" "$(BUILD)/semantic-result.tsv"
	"$(EXECUTOR)" classify "$(ROOT)/cases.tsv" "$(ROOT)/expectations.tsv" "$(BUILD)/raw-observations.tsv" "$(BUILD)/semantic-result-replay.tsv"
	cmp "$(BUILD)/semantic-result.tsv" "$(BUILD)/semantic-result-replay.tsv"
	cmp "$(ROOT)/expected-verdicts.tsv" "$(BUILD)/semantic-result.tsv"
	"$(EXECUTOR)" observe "$(ROOT)/cases-permuted.tsv" "$(BUILD)/raw-observations-permuted.tsv"
	"$(EXECUTOR)" classify "$(ROOT)/cases-permuted.tsv" "$(ROOT)/expectations-permuted.tsv" "$(BUILD)/raw-observations-permuted.tsv" "$(BUILD)/semantic-result-permuted.tsv"
	cmp "$(BUILD)/semantic-result.tsv" "$(BUILD)/semantic-result-permuted.tsv"
	"$(EXECUTOR)" verify-dispositions "$(ROOT)/dispositions.tsv"
	@printf 'AICI-META-CORPUS-ACCEPTED meta_cases=6 scenarios=13 raw_before_classification=yes replay=byte-identical permutation=byte-identical\n'
