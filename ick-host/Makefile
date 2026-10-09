# Build-tool recipes use make's fixed command interface.
# Host gcc/g++ only bootstrap the pinned ICK compiler; consumers use its output.
ICK_SOURCE ?= $(CURDIR)/.ick-host-source
ICK_BUILD ?= $(CURDIR)/.ick-host-build
ICK_STAGE ?= $(CURDIR)/.ick-host-stage
ICK_REVISION = c61e448251744a2f40ad743ebef1a027bdcd2f9d
GCC_REVISION = 6294f1d9e7536e5ffcde09d1528c918d63abfef5
ICK_MATERIALIZED = $(ICK_BUILD)/source
ICK_COMPILER = $(ICK_STAGE)/bin/gcc
ICK_LINK_FLAGS ?= -fno-link-libatomic
ICK_QUALIFY_SOURCE := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))assignment-arrow.c
ICK_QUALIFY_BUILD ?= $(ICK_STAGE)/qualification
BUILD_JOBS ?= 2
HOST_RUNTIME ?= /usr/lib/gcc/x86_64-linux-gnu/13
RUNTIME_DEST = $(ICK_STAGE)/lib/gcc/x86_64-pc-linux-gnu/17.0.0
RUNTIME_FILES = libgcc.a libgcc_eh.a libgcc_s.so crtbegin.o crtend.o crtbeginS.o crtendS.o libasan.a libasan.so libasan_preinit.o libubsan.a libubsan.so

.PHONY: all qualify
all: $(ICK_COMPILER)

qualify:
	mkdir -p "$(ICK_QUALIFY_BUILD)"
	"$(ICK_COMPILER)" $(ICK_LINK_FLAGS) -std=c17 -O0 -Wall -Wextra -Werror "$(ICK_QUALIFY_SOURCE)" -o "$(ICK_QUALIFY_BUILD)/glyphs-O0"
	"$(ICK_QUALIFY_BUILD)/glyphs-O0"
	"$(ICK_COMPILER)" $(ICK_LINK_FLAGS) -std=c17 -O2 -Wall -Wextra -Werror "$(ICK_QUALIFY_SOURCE)" -o "$(ICK_QUALIFY_BUILD)/glyphs-O2"
	"$(ICK_QUALIFY_BUILD)/glyphs-O2"
	"$(ICK_COMPILER)" $(ICK_LINK_FLAGS) -std=c17 -O2 -Wall -Wextra -Werror -DICK_HOST_WRONG_DIVISION "$(ICK_QUALIFY_SOURCE)" -o "$(ICK_QUALIFY_BUILD)/wrong-division"
	"$(ICK_QUALIFY_BUILD)/wrong-division"; test "$$?" = 2

$(ICK_BUILD)/source/.materialized:
	test "$$(git -C "$(ICK_SOURCE)" rev-parse HEAD)" = "$(ICK_REVISION)"
	test "$$(git -C "$(ICK_SOURCE)/gcc" rev-parse HEAD)" = "$(GCC_REVISION)"
	mkdir -p "$(ICK_BUILD)"
	sh "$(ICK_SOURCE)/ick/materialize.sh" "$(ICK_SOURCE)/gcc" "$(ICK_MATERIALIZED)"
	touch "$@"

$(ICK_BUILD)/objects/Makefile: $(ICK_BUILD)/source/.materialized
	mkdir -p "$(ICK_BUILD)/objects"
	cd "$(ICK_BUILD)/objects" && "$(ICK_MATERIALIZED)/configure" --prefix="$(ICK_STAGE)" --enable-languages=c --disable-bootstrap --disable-multilib --disable-nls --disable-shared --disable-libsanitizer --disable-libquadmath --disable-libgomp --without-isl --without-zstd

$(ICK_COMPILER): $(ICK_BUILD)/objects/Makefile
	$(MAKE) -C "$(ICK_BUILD)/objects" -j$(BUILD_JOBS) all-gcc
	$(MAKE) -C "$(ICK_BUILD)/objects" install-gcc
	test "$$($(ICK_COMPILER) -dumpmachine)" = x86_64-pc-linux-gnu
	cp $(addprefix $(HOST_RUNTIME)/,$(RUNTIME_FILES)) "$(RUNTIME_DEST)/"
	dpkg-query -W libc6 libgcc-13-dev > "$(ICK_STAGE)/host-runtime-packages.tsv"
	sha256sum $(addprefix $(HOST_RUNTIME)/,$(RUNTIME_FILES)) > "$(ICK_STAGE)/host-runtime.sha256"
