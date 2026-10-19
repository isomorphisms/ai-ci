# Included only by the explicitly selected _FORTIFY_SOURCE=2 profile.
FORTIFY_SOURCE_FILE = $(QUALIFY_ROOT)fortify/runtime.c
FORTIFY_OPTIMIZATIONS = 1 2 3 s
FORTIFY_ARTIFACTS = $(addprefix $(QUALIFY_BUILD)/fortify-O,$(FORTIFY_OPTIMIZATIONS)) $(QUALIFY_BUILD)/fortify-control
FORTIFY_ASSEMBLY = $(addsuffix .s,$(FORTIFY_ARTIFACTS))
FORTIFY_FORBIDDEN = memchr memrchr mempcpy stpcpy strcpy strcat strncat stpncpy strncpy strlcpy strlcat strrchr fread fgets sprintf vsprintf getcwd pread pread64 pwrite pwrite64 readlink readlinkat ppoll ppoll64 realpath umask open open64 openat openat64 recv recvfrom send sendto bcopy bzero
FORTIFY_REJECTIONS = $(addprefix $(QUALIFY_BUILD)/reject-,$(addsuffix .checked,$(FORTIFY_FORBIDDEN)))
FORTIFY_QUALIFY = fortify-qualify

.PHONY: fortify-qualify fortify-run fortify-reject-api25 fortify-reject-mismatched-api

$(QUALIFY_BUILD)/fortify-O%.s: $(FORTIFY_SOURCE_FILE) FORCE | check-qualification
	"$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) $(ICK_NDK_FLAGS) -D__ANDROID_API__=26 -D__ANDROID_MIN_SDK_VERSION__=26 -std=c17 -O$* $(ICK_DEBUG_FLAGS) -fPIC -fstack-protector-strong -Wall -Wextra -Werror -Wpedantic -S "$<" -o "$@"

$(QUALIFY_BUILD)/fortify-control.s: $(FORTIFY_SOURCE_FILE) FORCE | check-qualification
	"$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) $(ICK_NDK_FLAGS) -D__ANDROID_API__=26 -D__ANDROID_MIN_SDK_VERSION__=26 -DICK_FORTIFY_NEGATIVE_CONTROL -std=c17 -O2 $(ICK_DEBUG_FLAGS) -fPIC -fstack-protector-strong -Wall -Wextra -Werror -Wpedantic -S "$<" -o "$@"

$(QUALIFY_BUILD)/fortify-%.o: $(QUALIFY_BUILD)/fortify-%.s
	"$(NDK_CC)" $(TARGET_FLAGS) -c "$<" -o "$@"

$(QUALIFY_BUILD)/fortify-%: $(QUALIFY_BUILD)/fortify-%.o
	"$(NDK_CC)" $(TARGET_FLAGS) -static -Wl,--no-undefined "$<" -o "$@"

$(QUALIFY_BUILD)/reject-%.checked: FORCE | check-qualification
	printf 'int main(void) { (void)&%s; return 0; }\n' '$*' > "$(QUALIFY_BUILD)/reject-$*.c"
	rm -f "$(QUALIFY_BUILD)/reject-$*.s"
	! "$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) $(ICK_NDK_FLAGS) -D__ANDROID_API__=26 -D__ANDROID_MIN_SDK_VERSION__=26 -std=c17 -O2 -Wall -Wextra -Werror -include "$(QUALIFY_ROOT)fortify/reject-includes.h" -S "$(QUALIFY_BUILD)/reject-$*.c" -o "$(QUALIFY_BUILD)/reject-$*.s" > "$(QUALIFY_BUILD)/reject-$*.log" 2>&1
	grep -E 'attempt to use poisoned.*\b'"$*"'\b' "$(QUALIFY_BUILD)/reject-$*.log"
	test ! -e "$(QUALIFY_BUILD)/reject-$*.s"
	touch "$@"

fortify-reject-api25: check-qualification
	! "$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) $(ICK_NDK_FLAGS) -D__ANDROID_API__=25 -D__ANDROID_MIN_SDK_VERSION__=25 -std=c17 -O2 -fPIC -S "$(FORTIFY_SOURCE_FILE)" -o "$(QUALIFY_BUILD)/fortify-api25.s" > "$(QUALIFY_BUILD)/fortify-api25.log" 2>&1
	grep -F 'ICK Bionic Fortify profile currently requires Android API 26' "$(QUALIFY_BUILD)/fortify-api25.log"
	test ! -e "$(QUALIFY_BUILD)/fortify-api25.s"

fortify-reject-mismatched-api: check-qualification
	! "$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) $(ICK_NDK_FLAGS) -D__ANDROID_API__=26 -D__ANDROID_MIN_SDK_VERSION__=25 -std=c17 -O2 -fPIC -S "$(FORTIFY_SOURCE_FILE)" -o "$(QUALIFY_BUILD)/fortify-mismatched-api.s" > "$(QUALIFY_BUILD)/fortify-mismatched-api.log" 2>&1
	grep -F 'ICK Bionic Fortify profile requires matching Android API floor macros' "$(QUALIFY_BUILD)/fortify-mismatched-api.log"
	test ! -e "$(QUALIFY_BUILD)/fortify-mismatched-api.s"

ifeq ($(ABI),x86_64)
fortify-run: $(FORTIFY_ASSEMBLY) $(FORTIFY_ARTIFACTS)
	test "$$(uname -m)" = x86_64
	"$(QUALIFY_BUILD)/fortify-O1" > "$(QUALIFY_BUILD)/fortify-O1.log" 2>&1
	"$(QUALIFY_BUILD)/fortify-O2" > "$(QUALIFY_BUILD)/fortify-O2.log" 2>&1
	"$(QUALIFY_BUILD)/fortify-O3" > "$(QUALIFY_BUILD)/fortify-O3.log" 2>&1
	"$(QUALIFY_BUILD)/fortify-Os" > "$(QUALIFY_BUILD)/fortify-Os.log" 2>&1
	"$(QUALIFY_BUILD)/fortify-control" > "$(QUALIFY_BUILD)/fortify-control.log" 2>&1; test "$$?" = 55
	printf 'bionic_static_runtime_on_linux_x86_64\tPASS\noverflow_sigabrt_cases_per_optimization\t22\noptimizations\tO1,O2,O3,Os\nunfortified_read_control_exit55\tPASS\nandroid_device_execution\tNOT_RUN\n' > "$(QUALIFY_BUILD)/fortify-runtime.tsv"
else
fortify-run: $(FORTIFY_ASSEMBLY) $(FORTIFY_ARTIFACTS)
	printf 'bionic_static_compile_link\tPASS\nexecution\tNOT_RUN\n' > "$(QUALIFY_BUILD)/fortify-runtime.tsv"
endif

fortify-qualify: fortify-run $(FORTIFY_REJECTIONS) fortify-reject-api25 fortify-reject-mismatched-api
	printf 'unsupported_fortified_functions_rejected\t37\napi25_profile_rejected\tPASS\n' > "$(QUALIFY_BUILD)/fortify-rejections.tsv"
