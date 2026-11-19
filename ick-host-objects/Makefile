# Bootstrap the pinned ICK frontend for C-to-object compilation.
ICK_SOURCE ?= $(CURDIR)/ick-toolchain
BUILD_JOBS ?= 2
ICK_REF = c61e448251744a2f40ad743ebef1a027bdcd2f9d
GCC_REF = 6294f1d9e7536e5ffcde09d1528c918d63abfef5
STAGE = $(ICK_SOURCE)/stage
BUILD = $(ICK_SOURCE)/build

.PHONY: all check-source

all: check-source
	sh "$(ICK_SOURCE)/ick/materialize.sh" "$(ICK_SOURCE)/gcc" "$(ICK_SOURCE)/source"
	mkdir -p "$(BUILD)" "$(STAGE)"
	cd "$(BUILD)" && ../source/configure \
		--target=x86_64-linux-gnu --prefix="$(STAGE)" \
		--with-as="$$(command -v x86_64-linux-gnu-as)" \
		--with-ld="$$(command -v x86_64-linux-gnu-ld)" \
		--enable-languages=c --disable-bootstrap --disable-multilib \
		--disable-nls --disable-shared --disable-threads --without-headers \
		--disable-libatomic --disable-libgomp --disable-libquadmath \
		--disable-libssp --disable-libvtv
	$(MAKE) -C "$(BUILD)" -j$(BUILD_JOBS) all-gcc
	$(MAKE) -C "$(BUILD)" install-gcc

check-source:
	test "$$(git -C "$(ICK_SOURCE)" rev-parse HEAD)" = "$(ICK_REF)"
	test "$$(git -C "$(ICK_SOURCE)/gcc" rev-parse HEAD)" = "$(GCC_REF)"
	grep -Fxq 'gcc_commit=$(GCC_REF)' "$(ICK_SOURCE)/ick/SOURCE.lock"
