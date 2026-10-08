# Direct commands at make's fixed tool interface.
ICK ?= ick
ICK_LINK_FLAGS ?= -fno-link-libatomic
BUILD ?= /tmp/aici-c-source
SOURCE_ROOT = $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
CHECKER = $(BUILD)/assignments

.PHONY: all test check
all: $(CHECKER)
$(CHECKER): $(SOURCE_ROOT)/c-source/assignments.c
	mkdir -p "$(BUILD)"
	$(ICK) $(ICK_LINK_FLAGS) -std=c17 -O2 -Wall -Wextra -Werror -pedantic $< -o $@

check: $(CHECKER)
	$(CHECKER) check $(FILES)

test: $(CHECKER)
	cd "$(SOURCE_ROOT)" && $(CHECKER) check c-source/assignments.c c-source/tests/good.c c-source/tests/good-splice.c
	cd "$(SOURCE_ROOT)" && $(CHECKER) inventory c-source/tests/good.c c-source/tests/good-splice.c c-source/tests/bad-preprocessor.c c-source/tests/bad-assignment.c c-source/tests/bad-splice.c > "$(BUILD)/inventory.tsv"
	cmp "$(SOURCE_ROOT)/c-source/tests/expected.tsv" "$(BUILD)/inventory.tsv"
	cd "$(SOURCE_ROOT)" && ! $(CHECKER) check c-source/tests/bad-assignment.c > "$(BUILD)/bad-assignment.out" 2> "$(BUILD)/bad-assignment.err"
	grep -F 'bad-assignment.c:1: ordinary assignment token' "$(BUILD)/bad-assignment.err"
	cd "$(SOURCE_ROOT)" && ! $(CHECKER) check c-source/tests/bad-splice.c > "$(BUILD)/bad-splice.out" 2> "$(BUILD)/bad-splice.err"
	grep -F 'bad-splice.c:2: ordinary assignment token' "$(BUILD)/bad-splice.err"
	cd "$(SOURCE_ROOT)" && ! $(CHECKER) check c-source/tests/bad-preprocessor.c > "$(BUILD)/bad-preprocessor.out" 2> "$(BUILD)/bad-preprocessor.err"
	grep -F 'ordinary assignment in preprocessor source' "$(BUILD)/bad-preprocessor.err"
	cd "$(SOURCE_ROOT)" && ! $(CHECKER) check c-source/tests/bad-unterminated.c > "$(BUILD)/bad-unterminated.out" 2> "$(BUILD)/bad-unterminated.err"
	grep -F 'unterminated quoted literal' "$(BUILD)/bad-unterminated.err"
	cd "$(SOURCE_ROOT)" && ! $(CHECKER) check c-source/tests/bad-trigraph.c > "$(BUILD)/bad-trigraph.out" 2> "$(BUILD)/bad-trigraph.err"
	grep -F 'trigraph phase 1 requires compiler-aware review' "$(BUILD)/bad-trigraph.err"
