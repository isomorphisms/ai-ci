# Fixed make command interface. Host gcc/g++ only bootstrap ICK.
# ICK compiles all qualification C; NDK tools assemble, link and inspect it.
.DEFAULT_GOAL := all
ABI ?=
GNU_TARGET_armeabi-v7a = arm-linux-gnueabi
GNU_TARGET_arm64-v8a = aarch64-linux-gnu
GNU_TARGET_x86_64 = x86_64-linux-gnu
HEADER_TARGET_armeabi-v7a = arm-linux-androideabi
HEADER_TARGET_arm64-v8a = aarch64-linux-android
HEADER_TARGET_x86_64 = x86_64-linux-android
NDK_TARGET_armeabi-v7a = armv7a-linux-androideabi
NDK_TARGET_arm64-v8a = aarch64-linux-android
NDK_TARGET_x86_64 = x86_64-linux-android
TARGET_FLAGS_armeabi-v7a = -marm -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp
TARGET_FLAGS_arm64-v8a = -ffixed-x18
TARGET_FLAGS_x86_64 = -march=x86-64-v2 -mno-avx -mno-movbe
ELF_CLASS_armeabi-v7a = ELF32
ELF_CLASS_arm64-v8a = ELF64
ELF_CLASS_x86_64 = ELF64
ELF_MACHINE_armeabi-v7a = ARM
ELF_MACHINE_arm64-v8a = AArch64
ELF_MACHINE_x86_64 = Advanced Micro Devices X86-64
ifeq ($(GNU_TARGET_$(ABI)),)
$(error ABI must be armeabi-v7a, arm64-v8a, or x86_64)
endif
GNU_TARGET = $(GNU_TARGET_$(ABI))
HEADER_TARGET = $(HEADER_TARGET_$(ABI))
TARGET_FLAGS = $(TARGET_FLAGS_$(ABI))
ELF_CLASS = $(ELF_CLASS_$(ABI))
ELF_MACHINE = $(ELF_MACHINE_$(ABI))
ICK_SOURCE ?= $(CURDIR)/.ick-android-$(ABI)-source
ICK_BUILD ?= $(CURDIR)/.ick-android-$(ABI)-build
ICK_STAGE ?= $(CURDIR)/.ick-android-$(ABI)-stage
ICK_REVISION = fbe86e23d55cfec2000c08e61deea2a407fd7175
GCC_REVISION = 6294f1d9e7536e5ffcde09d1528c918d63abfef5
ICK_MATERIALIZED = $(ICK_BUILD)/source
ICK_COMPILER ?= $(ICK_STAGE)/bin/$(GNU_TARGET)-gcc
ICK_EXTRA_FLAGS ?=
ICK_BUILTIN_INCLUDE ?= $(shell "$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) -print-file-name=include)
EXPECTED_TARGET ?= $(GNU_TARGET)
BUILD_JOBS ?= 2
BOOTSTRAP_CFLAGS ?= -O2 -g0
BOOTSTRAP_CXXFLAGS ?= -O2 -g0
NDK ?=
FORTIFY_SOURCE ?=
ifneq ($(FORTIFY_SOURCE),)
ifneq ($(FORTIFY_SOURCE),2)
$(error FORTIFY_SOURCE must be empty or 2; other profiles are not qualified)
endif
FORTIFY_FLAGS = -D_FORTIFY_SOURCE=$(FORTIFY_SOURCE)
endif
NDK_BIN = $(NDK)/toolchains/llvm/prebuilt/linux-x86_64/bin
NDK_SYSROOT = $(NDK)/toolchains/llvm/prebuilt/linux-x86_64/sysroot
NDK_CC = $(NDK_BIN)/$(NDK_TARGET_$(ABI))26-clang
NDK_READELF = $(NDK_BIN)/llvm-readelf
ICK_NDK_BASE_FLAGS = $(TARGET_FLAGS) --sysroot="$(NDK_SYSROOT)" -nostdinc -isystem "$(ICK_BUILTIN_INCLUDE)" -isystem "$(NDK_SYSROOT)/usr/include" -isystem "$(NDK_SYSROOT)/usr/include/$(HEADER_TARGET)" -D__ANDROID__ -DBIONIC_IOCTL_NO_SIGNEDNESS_OVERLOAD
ICK_NDK_FLAGS = $(HEADER_OVERLAY_FLAGS) $(ICK_NDK_BASE_FLAGS) $(FORTIFY_FLAGS)
ICK_DEBUG_FLAGS = -g -gdwarf-4 -gno-variable-location-views
QUALIFY_ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
QUALIFY_BUILD ?= $(ICK_STAGE)/qualification
ifeq ($(FORTIFY_SOURCE),2)
HEADER_OVERLAY = $(QUALIFY_ROOT)fortify/include
HEADER_OVERLAY_FLAGS = -I"$(HEADER_OVERLAY)"
ifeq ($(filter outputs archive-stage restore-stage,$(MAKECMDGOALS)),)
include $(QUALIFY_ROOT)fortify/Makefile
endif
endif
GLYPH_SOURCE = $(QUALIFY_ROOT)../ick-host/assignment-arrow.c
COMPLEX_SOURCE = $(ICK_SOURCE)/ick/source/gcc/testsuite/gcc.dg/ick-complex-extraction-only.c
COMPLEX_LEVELS = 0 1 2 3 s
COMPLEX_ARTIFACTS = $(addprefix $(QUALIFY_BUILD)/complex-O,$(COMPLEX_LEVELS))
BIONIC_SOURCE = $(ICK_SOURCE)/qualification/android-boundary
QUALIFY_ARTIFACTS = $(QUALIFY_BUILD)/glyphs-O0 $(QUALIFY_BUILD)/glyphs-O2 $(QUALIFY_BUILD)/atomics-O0 $(QUALIFY_BUILD)/atomics-O2 $(QUALIFY_BUILD)/libbionic-headers.so $(QUALIFY_BUILD)/bionic-nullability.o $(QUALIFY_BUILD)/bionic-availability.o $(FORTIFY_ARTIFACTS)
QUALIFY_ASSEMBLY = $(addprefix $(QUALIFY_BUILD)/,glyphs-O0.s glyphs-O2.s atomics-O0.s atomics-O2.s bionic-headers.s bionic-nullability.s bionic-availability.s)
QUALIFY_ARTIFACTS += $(COMPLEX_ARTIFACTS)
QUALIFY_ASSEMBLY += $(addsuffix .s,$(COMPLEX_ARTIFACTS))
QUALIFY_ELF_CHECKS = $(addsuffix .elf,$(QUALIFY_ARTIFACTS))

.PHONY: all validate check-compiler check-qualification qualify reject-api25 outputs FORCE
.SECONDARY:
all: $(ICK_COMPILER)

FORCE:

validate:
	@test "$(ABI)" = "$(strip $(ABI))"

ifeq ($(filter outputs archive-stage restore-stage,$(MAKECMDGOALS)),)
$(ICK_BUILD)/source/.materialized:
	test "$$(git -C "$(ICK_SOURCE)" rev-parse HEAD)" = "$(ICK_REVISION)"
	test "$$(git -C "$(ICK_SOURCE)/gcc" rev-parse HEAD)" = "$(GCC_REVISION)"
	mkdir -p "$(ICK_BUILD)"
	sh "$(ICK_SOURCE)/ick/materialize.sh" "$(ICK_SOURCE)/gcc" "$(ICK_MATERIALIZED)"
	touch "$@"

$(ICK_BUILD)/objects/Makefile: $(ICK_BUILD)/source/.materialized
	mkdir -p "$(ICK_BUILD)/objects"
	cd "$(ICK_BUILD)/objects" && CFLAGS="$(BOOTSTRAP_CFLAGS)" CXXFLAGS="$(BOOTSTRAP_CXXFLAGS)" "$(ICK_MATERIALIZED)/configure" --target="$(GNU_TARGET)" --prefix="$(ICK_STAGE)" --with-as="/usr/bin/$(GNU_TARGET)-as" --with-ld="/usr/bin/$(GNU_TARGET)-ld" --enable-languages=c --disable-bootstrap --disable-multilib --disable-nls --disable-shared --disable-threads --without-headers --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libssp --disable-libvtv --without-isl --without-zstd

$(ICK_COMPILER): $(ICK_BUILD)/objects/Makefile
	$(MAKE) -C "$(ICK_BUILD)/objects" -j$(BUILD_JOBS) all-gcc
	$(MAKE) -C "$(ICK_BUILD)/objects" install-gcc
	test "$$("$(ICK_COMPILER)" -dumpmachine)" = "$(GNU_TARGET)"
	test -x "$$("$(ICK_COMPILER)" -print-prog-name=cc1)"

check-compiler:
	test "$$(git -C "$(ICK_SOURCE)" rev-parse HEAD)" = "$(ICK_REVISION)"
	test -x "$(ICK_COMPILER)"
	test "$$("$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) -dumpmachine)" = "$(EXPECTED_TARGET)"
	test -x "$$("$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) -print-prog-name=cc1)"
	test -f "$(ICK_BUILTIN_INCLUDE)/stdatomic.h"
	test -f "$(ICK_BUILTIN_INCLUDE)/stddef.h"

check-qualification: check-compiler
	test -x "$(NDK_CC)"
	test -x "$(NDK_READELF)"
	test -f "$(NDK_SYSROOT)/usr/include/android/native_activity.h"
	mkdir -p "$(QUALIFY_BUILD)"
	rm -f "$(QUALIFY_BUILD)/receipt.tsv"

$(QUALIFY_BUILD)/glyphs-O%.s: $(GLYPH_SOURCE) FORCE | check-qualification
	"$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) $(ICK_NDK_FLAGS) -D__ANDROID_API__=26 -D__ANDROID_MIN_SDK_VERSION__=26 -DICK_ANDROID_EXTERNAL_DATA -std=c17 -O$* $(ICK_DEBUG_FLAGS) -fPIC -Wall -Wextra -Werror -S "$<" -o "$@"

$(QUALIFY_BUILD)/glyphs-O%.o: $(QUALIFY_BUILD)/glyphs-O%.s
	"$(NDK_CC)" $(TARGET_FLAGS) -c "$<" -o "$@"

$(QUALIFY_BUILD)/glyphs-O%: $(QUALIFY_BUILD)/glyphs-O%.o
	"$(NDK_CC)" $(TARGET_FLAGS) -pie -Wl,--no-undefined -Wl,-z,max-page-size=16384 "$<" -o "$@"

$(QUALIFY_BUILD)/atomics-O%.s: $(QUALIFY_ROOT)atomics.c FORCE | check-qualification
	"$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) $(ICK_NDK_FLAGS) -D__ANDROID_API__=26 -D__ANDROID_MIN_SDK_VERSION__=26 -std=c17 -O$* $(ICK_DEBUG_FLAGS) -fPIC -Wall -Wextra -Werror -S "$<" -o "$@"

$(QUALIFY_BUILD)/atomics-O%.o: $(QUALIFY_BUILD)/atomics-O%.s
	"$(NDK_CC)" $(TARGET_FLAGS) -c "$<" -o "$@"

$(QUALIFY_BUILD)/atomics-O%: $(QUALIFY_BUILD)/atomics-O%.o
	"$(NDK_CC)" $(TARGET_FLAGS) -static -Wl,--no-undefined "$<" -o "$@"

$(QUALIFY_BUILD)/complex-O%.s: $(COMPLEX_SOURCE) FORCE | check-qualification
	"$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) $(ICK_NDK_FLAGS) -D__ANDROID_API__=26 -D__ANDROID_MIN_SDK_VERSION__=26 -std=c17 -O$* $(ICK_DEBUG_FLAGS) -fPIC -Wall -Wextra -Werror -S "$<" -o "$@"

$(QUALIFY_BUILD)/complex-O%.o: $(QUALIFY_BUILD)/complex-O%.s
	"$(NDK_CC)" $(TARGET_FLAGS) -c "$<" -o "$@"

$(QUALIFY_BUILD)/complex-O%: $(QUALIFY_BUILD)/complex-O%.o
	"$(NDK_CC)" $(TARGET_FLAGS) -static -Wl,--no-undefined "$<" -lm -o "$@"

.PHONY: qualify-complex-runtime
ifeq ($(ABI),x86_64)
qualify-complex-runtime: $(COMPLEX_ARTIFACTS)
	"$(QUALIFY_BUILD)/complex-O0"
	"$(QUALIFY_BUILD)/complex-O1"
	"$(QUALIFY_BUILD)/complex-O2"
	"$(QUALIFY_BUILD)/complex-O3"
	"$(QUALIFY_BUILD)/complex-Os"
	printf 'floating_complex_extraction_bionic_static_on_linux_x86_64\tPASS\nlevels\tO0 O1 O2 O3 Os\n' > "$(QUALIFY_BUILD)/complex-runtime.tsv"
else
qualify-complex-runtime: $(COMPLEX_ARTIFACTS)
	printf 'floating_complex_extraction_compile_link\tPASS\nlevels\tO0 O1 O2 O3 Os\nexecution\tNOT_RUN\n' > "$(QUALIFY_BUILD)/complex-runtime.tsv"
endif

.PHONY: qualify-atomics-runtime
ifeq ($(ABI),x86_64)
qualify-atomics-runtime: $(QUALIFY_BUILD)/atomics-O0 $(QUALIFY_BUILD)/atomics-O2
	"$(QUALIFY_BUILD)/atomics-O0"
	"$(QUALIFY_BUILD)/atomics-O2"
	printf 'atomic_int_and_flag_bionic_static_on_linux_x86_64\tPASS\n' > "$(QUALIFY_BUILD)/atomics-runtime.tsv"
else
qualify-atomics-runtime: $(QUALIFY_BUILD)/atomics-O0 $(QUALIFY_BUILD)/atomics-O2
	printf 'atomic_int_and_flag_compile_link\tPASS\nexecution\tNOT_RUN\n' > "$(QUALIFY_BUILD)/atomics-runtime.tsv"
endif

$(QUALIFY_BUILD)/bionic-%.s: $(BIONIC_SOURCE)/bionic-%.c FORCE | check-qualification
	"$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) $(ICK_NDK_FLAGS) -D__ANDROID_API__=26 -D__ANDROID_MIN_SDK_VERSION__=26 -std=c17 -O2 $(ICK_DEBUG_FLAGS) -fPIC -Wall -Wextra -Werror -S "$<" -o "$@"

$(QUALIFY_BUILD)/bionic-%.o: $(QUALIFY_BUILD)/bionic-%.s
	"$(NDK_CC)" $(TARGET_FLAGS) -c "$<" -o "$@"

$(QUALIFY_BUILD)/libbionic-headers.so: $(QUALIFY_BUILD)/bionic-headers.o
	"$(NDK_CC)" $(TARGET_FLAGS) -shared -Wl,--no-undefined -Wl,-z,max-page-size=16384 "$<" -o "$@"

$(QUALIFY_ELF_CHECKS): %.elf: %
	"$(NDK_READELF)" -h -r "$<" > "$@"
	grep -Eq 'Class:.*$(ELF_CLASS)' "$@"
	grep -Eq 'Machine:.*$(ELF_MACHINE)' "$@"
	! grep -Eq 'R_[A-Z0-9_]+_COPY' "$@"

.PHONY: reject-copy-relocation
ifeq ($(ABI),x86_64)
reject-copy-relocation: check-qualification
	"$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) $(ICK_NDK_FLAGS) -D__ANDROID_API__=26 -D__ANDROID_MIN_SDK_VERSION__=26 -DICK_ANDROID_EXTERNAL_DATA -std=c17 -O2 $(ICK_DEBUG_FLAGS) -fPIE -Wall -Wextra -Werror -S "$(GLYPH_SOURCE)" -o "$(QUALIFY_BUILD)/copy-negative.s"
	"$(NDK_CC)" $(TARGET_FLAGS) -c "$(QUALIFY_BUILD)/copy-negative.s" -o "$(QUALIFY_BUILD)/copy-negative.o"
	"$(NDK_CC)" $(TARGET_FLAGS) -pie -Wl,--no-undefined "$(QUALIFY_BUILD)/copy-negative.o" -o "$(QUALIFY_BUILD)/copy-negative"
	"$(NDK_READELF)" -r "$(QUALIFY_BUILD)/copy-negative" > "$(QUALIFY_BUILD)/copy-negative.elf"
	grep -Eq 'R_X86_64_COPY' "$(QUALIFY_BUILD)/copy-negative.elf"
	printf 'old_fPIE_external_data_COPY_rejected\tPASS\n' > "$(QUALIFY_BUILD)/copy-negative.tsv"
else
reject-copy-relocation:
endif

reject-api25: check-qualification
	rm -f "$(QUALIFY_BUILD)/bionic-availability-api25.s"
	! "$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) $(ICK_NDK_BASE_FLAGS) -D__ANDROID_API__=25 -D__ANDROID_MIN_SDK_VERSION__=25 -std=c17 -O2 -fPIC -Wall -Wextra -Werror -S "$(BIONIC_SOURCE)/bionic-availability.c" -o "$(QUALIFY_BUILD)/bionic-availability-api25.s" > "$(QUALIFY_BUILD)/bionic-availability-api25.log" 2>&1
	grep -Eqi 'requires Android API 26' "$(QUALIFY_BUILD)/bionic-availability-api25.log"
	test ! -e "$(QUALIFY_BUILD)/bionic-availability-api25.s"

qualify: $(QUALIFY_ASSEMBLY) $(QUALIFY_ELF_CHECKS) reject-api25 $(FORTIFY_QUALIFY) qualify-atomics-runtime qualify-complex-runtime reject-copy-relocation
	sha256sum "$(ICK_COMPILER)" "$$("$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) -print-prog-name=cc1)" > "$(QUALIFY_BUILD)/compiler.sha256"
	sha256sum "$(NDK)/source.properties" "$(NDK_BIN)/clang" "$(NDK_READELF)" > "$(QUALIFY_BUILD)/ndk.sha256"
	sha256sum $(QUALIFY_ARTIFACTS) > "$(QUALIFY_BUILD)/artifacts.sha256"
	printf 'source\t%s\ngcc_reference\t%s\nabi\t%s\nobserved_target\t%s\napi\t26\nfortify_source\t%s\nc_frontend\tick\nassembler\tndk\nlinker\tndk\nglyph_and_bionic_compile_link\tPASS\nstrict_api25_rejection\tPASS\nandroid_execution\tNOT_RUN\n' "$(ICK_REVISION)" "$(GCC_REVISION)" "$(ABI)" "$(EXPECTED_TARGET)" "$(if $(FORTIFY_SOURCE),$(FORTIFY_SOURCE),undefined)" > "$(QUALIFY_BUILD)/receipt.tsv"
endif

outputs:
	@printf 'compiler=%s\ntarget_flags=%s\nheader_target=%s\ngnu_target=%s\nheader_overlay=%s\nbuiltin_include=%s\n' "$(ICK_COMPILER)" "$(TARGET_FLAGS)" "$(HEADER_TARGET)" "$(GNU_TARGET)" "$(HEADER_OVERLAY)" "$(ICK_BUILTIN_INCLUDE)"

.PHONY: archive-stage restore-stage
archive-stage:
	test -n "$(ICK_ARCHIVE)"
	test -x "$(ICK_COMPILER)"
	mkdir -p "$$(dirname "$(ICK_ARCHIVE)")"
	tar -C "$(ICK_STAGE)" -czf "$(ICK_ARCHIVE)" .

restore-stage:
	test -f "$(ICK_ARCHIVE)"
	mkdir -p "$(ICK_STAGE)"
	tar -C "$(ICK_STAGE)" -xzf "$(ICK_ARCHIVE)"
	test -x "$(ICK_COMPILER)"
	test "$$("$(ICK_COMPILER)" -dumpmachine)" = "$(GNU_TARGET)"
	test -x "$$("$(ICK_COMPILER)" -print-prog-name=cc1)"
