# Fixed make command interface. Host gcc/g++ only bootstrap ICK.
# ICK compiles all qualification C; NDK tools assemble, link and inspect it.
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
ICK_REVISION = c61e448251744a2f40ad743ebef1a027bdcd2f9d
GCC_REVISION = 6294f1d9e7536e5ffcde09d1528c918d63abfef5
ICK_MATERIALIZED = $(ICK_BUILD)/source
ICK_COMPILER ?= $(ICK_STAGE)/bin/$(GNU_TARGET)-gcc
ICK_EXTRA_FLAGS ?=
EXPECTED_TARGET ?= $(GNU_TARGET)
BUILD_JOBS ?= 2
BOOTSTRAP_CFLAGS ?= -O2 -g0
BOOTSTRAP_CXXFLAGS ?= -O2 -g0
NDK ?=
FORTIFY_SOURCE ?=
ifneq ($(FORTIFY_SOURCE),)
ifeq ($(filter $(FORTIFY_SOURCE),1 2),)
$(error FORTIFY_SOURCE must be empty, 1, or 2)
endif
FORTIFY_FLAGS = -D_FORTIFY_SOURCE=$(FORTIFY_SOURCE)
endif
NDK_BIN = $(NDK)/toolchains/llvm/prebuilt/linux-x86_64/bin
NDK_SYSROOT = $(NDK)/toolchains/llvm/prebuilt/linux-x86_64/sysroot
NDK_CC = $(NDK_BIN)/$(NDK_TARGET_$(ABI))26-clang
NDK_READELF = $(NDK_BIN)/llvm-readelf
ICK_NDK_FLAGS = $(TARGET_FLAGS) --sysroot="$(NDK_SYSROOT)" -isystem "$(NDK_SYSROOT)/usr/include" -isystem "$(NDK_SYSROOT)/usr/include/$(HEADER_TARGET)" -D__ANDROID__ -DBIONIC_IOCTL_NO_SIGNEDNESS_OVERLOAD $(FORTIFY_FLAGS)
QUALIFY_ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
QUALIFY_BUILD ?= $(ICK_STAGE)/qualification
GLYPH_SOURCE = $(QUALIFY_ROOT)../ick-host/assignment-arrow.c
BIONIC_SOURCE = $(ICK_SOURCE)/qualification/android-boundary
QUALIFY_ARTIFACTS = $(QUALIFY_BUILD)/glyphs-O0 $(QUALIFY_BUILD)/glyphs-O2 $(QUALIFY_BUILD)/libbionic-headers.so $(QUALIFY_BUILD)/bionic-nullability.o $(QUALIFY_BUILD)/bionic-availability.o
QUALIFY_ASSEMBLY = $(addprefix $(QUALIFY_BUILD)/,glyphs-O0.s glyphs-O2.s bionic-headers.s bionic-nullability.s bionic-availability.s)
QUALIFY_ELF_CHECKS = $(addsuffix .elf,$(QUALIFY_ARTIFACTS))

.PHONY: all validate check-compiler check-qualification qualify reject-api25 outputs FORCE
.SECONDARY:
all: $(ICK_COMPILER)

FORCE:

validate:
	@test "$(ABI)" = "$(strip $(ABI))"

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
	test "$$($(ICK_COMPILER) -dumpmachine)" = "$(GNU_TARGET)"
	test -x "$$($(ICK_COMPILER) -print-prog-name=cc1)"

check-compiler:
	test "$$(git -C "$(ICK_SOURCE)" rev-parse HEAD)" = "$(ICK_REVISION)"
	test -x "$(ICK_COMPILER)"
	test "$$($(ICK_COMPILER) $(ICK_EXTRA_FLAGS) -dumpmachine)" = "$(EXPECTED_TARGET)"
	test -x "$$($(ICK_COMPILER) $(ICK_EXTRA_FLAGS) -print-prog-name=cc1)"

check-qualification: check-compiler
	test -x "$(NDK_CC)"
	test -x "$(NDK_READELF)"
	test -f "$(NDK_SYSROOT)/usr/include/android/native_activity.h"
	mkdir -p "$(QUALIFY_BUILD)"
	rm -f "$(QUALIFY_BUILD)/receipt.tsv"

$(QUALIFY_BUILD)/glyphs-O%.s: $(GLYPH_SOURCE) FORCE | check-qualification
	"$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) $(ICK_NDK_FLAGS) -D__ANDROID_API__=26 -std=c17 -O$* -fPIE -Wall -Wextra -Werror -S "$<" -o "$@"

$(QUALIFY_BUILD)/glyphs-O%.o: $(QUALIFY_BUILD)/glyphs-O%.s
	"$(NDK_CC)" $(TARGET_FLAGS) -c "$<" -o "$@"

$(QUALIFY_BUILD)/glyphs-O%: $(QUALIFY_BUILD)/glyphs-O%.o
	"$(NDK_CC)" $(TARGET_FLAGS) -fPIE -pie -Wl,--no-undefined -Wl,-z,max-page-size=16384 "$<" -o "$@"

$(QUALIFY_BUILD)/bionic-%.s: $(BIONIC_SOURCE)/bionic-%.c FORCE | check-qualification
	"$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) $(ICK_NDK_FLAGS) -D__ANDROID_API__=26 -std=c17 -O2 -fPIC -Wall -Wextra -Werror -S "$<" -o "$@"

$(QUALIFY_BUILD)/bionic-%.o: $(QUALIFY_BUILD)/bionic-%.s
	"$(NDK_CC)" $(TARGET_FLAGS) -c "$<" -o "$@"

$(QUALIFY_BUILD)/libbionic-headers.so: $(QUALIFY_BUILD)/bionic-headers.o
	"$(NDK_CC)" $(TARGET_FLAGS) -shared -Wl,--no-undefined -Wl,-z,max-page-size=16384 "$<" -o "$@"

$(QUALIFY_ELF_CHECKS): %.elf: %
	"$(NDK_READELF)" -h "$<" > "$@"
	grep -Eq 'Class:.*$(ELF_CLASS)' "$@"
	grep -Eq 'Machine:.*$(ELF_MACHINE)' "$@"

reject-api25: check-qualification
	rm -f "$(QUALIFY_BUILD)/bionic-availability-api25.s"
	! "$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) $(ICK_NDK_FLAGS) -D__ANDROID_API__=25 -std=c17 -O2 -fPIC -Wall -Wextra -Werror -S "$(BIONIC_SOURCE)/bionic-availability.c" -o "$(QUALIFY_BUILD)/bionic-availability-api25.s" > "$(QUALIFY_BUILD)/bionic-availability-api25.log" 2>&1
	grep -Eqi 'requires Android API 26' "$(QUALIFY_BUILD)/bionic-availability-api25.log"
	test ! -e "$(QUALIFY_BUILD)/bionic-availability-api25.s"

qualify: $(QUALIFY_ASSEMBLY) $(QUALIFY_ELF_CHECKS) reject-api25
	sha256sum "$(ICK_COMPILER)" "$$($(ICK_COMPILER) $(ICK_EXTRA_FLAGS) -print-prog-name=cc1)" > "$(QUALIFY_BUILD)/compiler.sha256"
	sha256sum "$(NDK)/source.properties" "$(NDK_BIN)/clang" "$(NDK_READELF)" > "$(QUALIFY_BUILD)/ndk.sha256"
	sha256sum $(QUALIFY_ARTIFACTS) > "$(QUALIFY_BUILD)/artifacts.sha256"
	printf 'source\t%s\ngcc_reference\t%s\nabi\t%s\nobserved_target\t%s\napi\t26\nfortify_source\t%s\nc_frontend\tick\nassembler\tndk\nlinker\tndk\nglyph_and_bionic_compile_link\tPASS\nstrict_api25_rejection\tPASS\nandroid_execution\tNOT_RUN\n' "$(ICK_REVISION)" "$(GCC_REVISION)" "$(ABI)" "$(EXPECTED_TARGET)" "$(if $(FORTIFY_SOURCE),$(FORTIFY_SOURCE),undefined)" > "$(QUALIFY_BUILD)/receipt.tsv"

outputs:
	@printf 'compiler=%s\ntarget_flags=%s\nheader_target=%s\ngnu_target=%s\n' "$(ICK_COMPILER)" "$(TARGET_FLAGS)" "$(HEADER_TARGET)" "$(GNU_TARGET)"
