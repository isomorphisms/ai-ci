# Build-tool recipes use make's fixed command interface.
# Host gcc/g++ only bootstrap the pinned ICK compiler; consumers use its output.
ICK_SOURCE ?= $(CURDIR)/.ick-host-source
ICK_BUILD ?= $(CURDIR)/.ick-host-build
ICK_STAGE ?= $(CURDIR)/.ick-host-stage
ICK_REVISION = fbe86e23d55cfec2000c08e61deea2a407fd7175
GCC_REVISION = 6294f1d9e7536e5ffcde09d1528c918d63abfef5
ICK_MATERIALIZED = $(ICK_BUILD)/source
ICK_COMPILER = $(ICK_STAGE)/bin/gcc
ICK_LINK_FLAGS ?= -fno-link-libatomic
ICK_QUALIFY_SOURCE := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))assignment-arrow.c
ICK_QUALIFY_BUILD ?= $(ICK_STAGE)/qualification
BUILD_JOBS ?= 2
UBUNTU_CODENAME ?= $(shell lsb_release -cs)
BOOTSTRAP_APT = -o Dir::Etc::sourcelist=/dev/null -o Dir::Etc::sourceparts=$(ICK_BUILD)/apt-sources -o Acquire::Retries=1 -o Acquire::http::Timeout=20 -o Acquire::https::Timeout=20 -o APT::Update::Error-Mode=any
HOST_RUNTIME ?= /usr/lib/gcc/x86_64-linux-gnu/13
RUNTIME_DEST = $(ICK_STAGE)/lib/gcc/x86_64-pc-linux-gnu/17.0.0
RUNTIME_FILES = libgcc.a libgcc_eh.a libgcc_s.so crtbegin.o crtbeginT.o crtend.o crtbeginS.o crtendS.o libasan.a libasan.so libasan_preinit.o libubsan.a libubsan.so

.PHONY: all dependencies extra-packages qualify qualify-complex cache-key
all: $(ICK_COMPILER)

# Hosted mirror indirection stalled for the full IB job on 2026-10-31.
# Use Ubuntu's signed HTTPS archive directly for these bootstrap packages;
# neither a missing repository nor an exhausted deadline can become success.
dependencies:
	test "$$(lsb_release -is)" = Ubuntu
	test -n "$(UBUNTU_CODENAME)"
	test -f /usr/share/keyrings/ubuntu-archive-keyring.gpg
	mkdir -p "$(ICK_BUILD)/apt-sources"
	printf '%s\n' 'Types: deb' 'URIs: https://archive.ubuntu.com/ubuntu/' 'Suites: $(UBUNTU_CODENAME) $(UBUNTU_CODENAME)-updates $(UBUNTU_CODENAME)-security' 'Components: main universe restricted multiverse' 'Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg' > "$(ICK_BUILD)/apt-sources/ubuntu.sources"
	sudo timeout 240 apt-get $(BOOTSTRAP_APT) update
	sudo timeout 240 apt-get $(BOOTSTRAP_APT) install -y build-essential flex bison texinfo libgmp-dev libmpfr-dev libmpc-dev

extra-packages:
	test -s "$(ICK_BUILD)/apt-sources/ubuntu.sources"
	test -n "$(PACKAGES)"
	sudo timeout 240 apt-get $(BOOTSTRAP_APT) install -y $(PACKAGES)

qualify: qualify-complex
	mkdir -p "$(ICK_QUALIFY_BUILD)"
	"$(ICK_COMPILER)" $(ICK_LINK_FLAGS) -std=c17 -O0 -Wall -Wextra -Werror "$(ICK_QUALIFY_SOURCE)" -o "$(ICK_QUALIFY_BUILD)/glyphs-O0"
	"$(ICK_QUALIFY_BUILD)/glyphs-O0"
	"$(ICK_COMPILER)" $(ICK_LINK_FLAGS) -std=c17 -O2 -Wall -Wextra -Werror "$(ICK_QUALIFY_SOURCE)" -o "$(ICK_QUALIFY_BUILD)/glyphs-O2"
	"$(ICK_QUALIFY_BUILD)/glyphs-O2"
	"$(ICK_COMPILER)" $(ICK_LINK_FLAGS) -std=c17 -O2 -Wall -Wextra -Werror -static "$(dir $(ICK_QUALIFY_SOURCE))static-stdio.c" -Wl,--start-group -lc -lgcc_eh -Wl,--end-group -o "$(ICK_QUALIFY_BUILD)/static-stdio"
	"$(ICK_QUALIFY_BUILD)/static-stdio"
	! readelf -l "$(ICK_QUALIFY_BUILD)/static-stdio" | grep -F INTERP
	"$(ICK_COMPILER)" $(ICK_LINK_FLAGS) -std=c17 -O2 -Wall -Wextra -Werror -DICK_HOST_WRONG_DIVISION "$(ICK_QUALIFY_SOURCE)" -o "$(ICK_QUALIFY_BUILD)/wrong-division"
	"$(ICK_QUALIFY_BUILD)/wrong-division"; test "$$?" = 2
	rm -f "$(ICK_QUALIFY_BUILD)/preprocessor-division.o"
	! "$(ICK_COMPILER)" -std=c17 -DICK_HOST_REJECT_PP_DIVISION -c "$(ICK_QUALIFY_SOURCE)" -o "$(ICK_QUALIFY_BUILD)/preprocessor-division.o" > "$(ICK_QUALIFY_BUILD)/preprocessor-division.log" 2>&1
	grep -F 'not valid in preprocessor expressions' "$(ICK_QUALIFY_BUILD)/preprocessor-division.log"
	test ! -e "$(ICK_QUALIFY_BUILD)/preprocessor-division.o"

qualify-complex:
	test "$$(git -C "$(ICK_SOURCE)" rev-parse HEAD)" = "$(ICK_REVISION)"
	$(MAKE) -f "$(ICK_SOURCE)/qualification/complex-extraction/Makefile" all ICK="$(ICK_COMPILER)" ICK_LINK_FLAGS="$(ICK_LINK_FLAGS)" BUILD="$(ICK_QUALIFY_BUILD)/complex-extraction"

cache-key:
	@mkdir -p "$(ICK_BUILD)"
	@dpkg-query -W libc6 libgcc-13-dev > "$(ICK_BUILD)/host-runtime-key-input.tsv"
	@sha256sum $(addprefix $(HOST_RUNTIME)/,$(RUNTIME_FILES)) >> "$(ICK_BUILD)/host-runtime-key-input.tsv"
	@printf 'runtime_key=%s\n' "$$(sha256sum "$(ICK_BUILD)/host-runtime-key-input.tsv" | cut -d ' ' -f 1)"

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
	test "$$("$(ICK_COMPILER)" -dumpmachine)" = x86_64-pc-linux-gnu
	cp $(addprefix $(HOST_RUNTIME)/,$(RUNTIME_FILES)) "$(RUNTIME_DEST)/"
	dpkg-query -W libc6 libgcc-13-dev > "$(ICK_STAGE)/host-runtime-packages.tsv"
	sha256sum $(addprefix $(HOST_RUNTIME)/,$(RUNTIME_FILES)) > "$(ICK_STAGE)/host-runtime.sha256"
