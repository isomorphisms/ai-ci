# AICI-owned host semantic and ABI checks for the explicit ICKY source lane.
CASE_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
export LC_ALL := C
BUILD ?=
ICK ?=
ICK_PARSER_PACKAGE ?=
ICK_MUTANT_FRONTEND ?=
PARSER_APPLICATION := $(ICK_PARSER_PACKAGE)/app/icky-parser_app/icky-parser.so
PARSER_LOADER := $(ICK_PARSER_PACKAGE)/runtime/elf/ld-linux-x86-64.so.2
TRACE := strace -f -qq -s 8192 -e trace=execve
FLAGS := -std=c17 -Wall -Wextra -Werror -finput-charset=UTF-8 -fno-diagnostics-color=never -fno-lto -fno-pie
parser := -ficky-parser-package=$(ICK_PARSER_PACKAGE)

.NOTPARALLEL:
.PHONY: check init oracle verify-object refusals ignored-assignment
check: init oracle host-O0 host-O2 refusals ignored-assignment
	diff -qr "$(BUILD)/inputs" "$(CASE_DIR)" -x Makefile -x README.md
	sha256sum "$(ICK)" "$$("$(ICK)" -print-prog-name=cc1)" \
		"$(ICK_MUTANT_FRONTEND)" "$(PARSER_LOADER)" "$(PARSER_APPLICATION)" \
		"$(CASE_DIR)/Makefile" "$(BUILD)/inputs/"* \
		"$(BUILD)/host-O0.o" "$(BUILD)/host-O0" "$(BUILD)/host-O2.o" "$(BUILD)/host-O2" \
		"$(BUILD)/ignored-assignment.o" "$(BUILD)/ignored-assignment" > "$(BUILD)/materials.sha256"
	printf '%s\n' 'host_semantics	PASS' 'elf_x86_64_abi	PASS' \
		'negative_controls	PASS' 'parser_codegen_effect	PASS' \
		'registered_producer_admission	NOT_RUN' 'android_abi	NOT_RUN' > "$(BUILD)/result.tsv"

init:
	@test "$(words $(BUILD) $(ICK) $(ICK_PARSER_PACKAGE) $(ICK_MUTANT_FRONTEND))" = 4 && \
		test "$(words $(filter /%,$(BUILD) $(ICK) $(ICK_PARSER_PACKAGE) $(ICK_MUTANT_FRONTEND)))" = 4 || \
		{ printf '%s\n' 'Provide absolute paths for BUILD, ICK, ICK_PARSER_PACKAGE and ICK_MUTANT_FRONTEND.' >&2; exit 1; }
	test -x "$(ICK)" && test -x "$(ICK_MUTANT_FRONTEND)"
	test -x "$(PARSER_LOADER)" && test -r "$(PARSER_APPLICATION)"
	test "$(notdir $(ICK_MUTANT_FRONTEND))" = cc1
	test "$$(uname -sm)" = 'Linux x86_64'
	test "$$("$(ICK)" -dumpmachine)" = x86_64-pc-linux-gnu
	test -x "$$("$(ICK)" -print-prog-name=cc1)"
	! cmp -s "$$("$(ICK)" -print-prog-name=cc1)" "$(ICK_MUTANT_FRONTEND)"
	mkdir -- "$(BUILD)"
	mkdir -- "$(BUILD)/inputs"
	cp -- "$(CASE_DIR)/"*.c "$(CASE_DIR)/"*.tsv "$(CASE_DIR)/"*.patch "$(BUILD)/inputs/"
	"$(ICK)" -print-prog-name=cc1 > "$(BUILD)/cc1.path"

oracle:
	"$(ICK)" $(FLAGS) -O2 -c "$(BUILD)/inputs/oracle.c" -o "$(BUILD)/oracle.o"

define verify_parser_trace
	grep -F 'execve("$(PARSER_LOADER)",' "$(1)" | \
		grep -F '"$(PARSER_APPLICATION)", "--parse-v3",' | grep -F ' = 0'
endef

define check_cc1_trace
	grep -F "execve(\"$(1)\"," "$(2)" | grep -F ' = 0'
endef

define host
.PHONY: host-$(1)
host-$(1):
	timeout 60 $(TRACE) -o "$(BUILD)/host-$(1)-compile.trace" \
		"$(ICK)" $(FLAGS) -$(1) "$(parser)" \
		-ficky-receipt="$(BUILD)/host-$(1)-parser.tsv" \
		-c "$(BUILD)/inputs/candidate.c" -o "$(BUILD)/host-$(1).o"
	$(call verify_parser_trace,$(BUILD)/host-$(1)-compile.trace)
	$(call check_cc1_trace,$$$$(cat "$(BUILD)/cc1.path"),$(BUILD)/host-$(1)-compile.trace)
	grep -E 'execve\("[^"]*/([^"/]*-)?as",.* = 0$$$$' "$(BUILD)/host-$(1)-compile.trace"
	$$(MAKE) -f "$(CASE_DIR)/Makefile" verify-object OBJECT="$(BUILD)/host-$(1).o"
	timeout 60 $(TRACE) -o "$(BUILD)/host-$(1)-link.trace" \
		"$(ICK)" -no-pie -fno-link-libatomic "$(BUILD)/host-$(1).o" "$(BUILD)/oracle.o" -o "$(BUILD)/host-$(1)"
	grep -E 'execve\("[^"]*/([^"/]*-)?ld(\.bfd)?",.* = 0$$$$' "$(BUILD)/host-$(1)-link.trace"
	timeout 10 "$(BUILD)/host-$(1)" > "$(BUILD)/host-$(1).tsv"
	cmp "$(BUILD)/inputs/expected.tsv" "$(BUILD)/host-$(1).tsv"
endef
$(foreach level,O0 O2,$(eval $(call host,$(level))))

verify-object:
	readelf -h -s -r -W "$(OBJECT)" > "$(OBJECT).elf.txt"
	grep -E 'Class:[[:space:]]+ELF64$$' "$(OBJECT).elf.txt"
	grep -E 'Data:.*little endian$$' "$(OBJECT).elf.txt"
	grep -E 'Machine:[[:space:]]+Advanced Micro Devices X86-64$$' "$(OBJECT).elf.txt"
	grep -E 'Type:[[:space:]]+REL ' "$(OBJECT).elf.txt"
	awk '$$4 == "FUNC" && $$5 == "GLOBAL" && $$7 != "UND" && $$8 == "k3_transition" { api++ } \
		$$3 == "8" && $$4 == "OBJECT" && $$5 == "GLOBAL" && $$7 != "UND" && $$8 == "k3_state" { state++ } \
		$$5 == "GLOBAL" && $$7 == "UND" && $$8 == "k3_record" { callback++ } \
		$$3 ~ /^R_X86_64_/ && $$5 == "k3_record" { callback_relocation++ } \
		END { exit !(api == 1 && state == 1 && callback == 1 && callback_relocation > 0) }' "$(OBJECT).elf.txt"

define refuse
	status=0; timeout 30 "$(ICK)" $(FLAGS) $(2) -c "$(BUILD)/inputs/negative.c" \
		-o "$(BUILD)/$(1).o" > "$(BUILD)/$(1).log" 2>&1 || status=$$?; test "$$status" = 1
	test ! -e "$(BUILD)/$(1).o"
	grep -E 'ICKY source lane refused: $(3)$$' "$(BUILD)/$(1).log"
endef

refusals:
	"$(ICK)" $(FLAGS) -no-pie -fno-link-libatomic "$(BUILD)/inputs/wrong-provider.c" -o "$(BUILD)/wrong-literal"
	"$(ICK)" $(FLAGS) -no-pie -fno-link-libatomic -DK3_WRONG_FRAME "$(BUILD)/inputs/wrong-provider.c" -o "$(BUILD)/wrong-frame"
	$(call refuse,provider-success-only,-ficky-parser=/usr/bin/true,ICKY_PROTOCOL_BOUNDARY)
	$(call refuse,wrong-literal,-ficky-parser=$(BUILD)/wrong-literal,ICKY_LITERAL_VALUE)
	$(call refuse,wrong-frame,-ficky-parser=$(BUILD)/wrong-frame,ICKY_SOURCE_FRAME)
	$(call refuse,neighboring-glyph,"$(parser)" -DK3_NEIGHBOR,ICKY_(TOKEN_UNSUPPORTED|PARSER_EXECUTION|AST_UNSUPPORTED))
	$(call refuse,malformed,"$(parser)" -DK3_MALFORMED,ICKY_TOKEN_UNSUPPORTED)
	$(call refuse,stale-map,"$(parser)" -DK3_STALE_MAP,ICKY_EXPANSION_MAP)
	cp "$(BUILD)/host-O2.o" "$(BUILD)/corrupted.o"
	truncate -s 4 "$(BUILD)/corrupted.o"
	! readelf -h "$(BUILD)/corrupted.o" > "$(BUILD)/corrupted.log" 2>&1

ignored-assignment:
	timeout 60 $(TRACE) -o "$(BUILD)/ignored-assignment-compile.trace" \
		"$(ICK)" -B "$(dir $(ICK_MUTANT_FRONTEND))" $(FLAGS) -O2 "$(parser)" \
		-ficky-receipt="$(BUILD)/ignored-assignment-parser.tsv" \
		-c "$(BUILD)/inputs/candidate.c" -o "$(BUILD)/ignored-assignment.o"
	$(call verify_parser_trace,$(BUILD)/ignored-assignment-compile.trace)
	$(call check_cc1_trace,$(ICK_MUTANT_FRONTEND),$(BUILD)/ignored-assignment-compile.trace)
	$(MAKE) -f "$(CASE_DIR)/Makefile" verify-object OBJECT="$(BUILD)/ignored-assignment.o"
	"$(ICK)" -no-pie -fno-link-libatomic "$(BUILD)/ignored-assignment.o" "$(BUILD)/oracle.o" -o "$(BUILD)/ignored-assignment"
	status=0; timeout 10 "$(BUILD)/ignored-assignment" > "$(BUILD)/ignored-assignment.tsv" || status=$$?; test "$$status" = 1
	cmp "$(BUILD)/inputs/ignored-assignment.expected.tsv" "$(BUILD)/ignored-assignment.tsv"
