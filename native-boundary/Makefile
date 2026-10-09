# Source compilation stage for the existing clean-checkout build/test entrypoints.
# ICK parses owned C; Android NDK assembles and links its assembly against Bionic.
.DEFAULT_GOAL := all
TARGET ?= host
KIND ?= probe
MODE ?= default
ICK ?= ick
ICK_EXTRA_FLAGS ?=
ICK_LINK_FLAGS ?= -fno-link-libatomic
NDK ?=
OUTPUT ?=
STAGE_DIR ?= $(dir $(OUTPUT))compiler-stage
REVISION ?= unknown
ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)

ifeq ($(filter $(TARGET),host armv7a aarch64 android-x86_64),)
$(error Unsupported native-boundary TARGET)
endif
ifeq ($(filter $(KIND),fixture probe self-test),)
$(error Unsupported native-boundary KIND)
endif
ifeq ($(filter $(MODE),default largefile),)
$(error Unsupported native-boundary MODE)
endif
ifeq ($(strip $(OUTPUT)),)
$(error OUTPUT must name the exact stage product)
endif

CFLAGS = -std=c17 -Wall -Wextra -Werror -pedantic -O2
LINK_FLAGS ?= -Wl,-z,relro,-z,now
SOURCE = $(ROOT)/native-boundary/probe.c
SOURCE_FLAGS = -fPIE
PRODUCT_FLAGS = -pie
LIBRARIES = -pthread -ldl
ifeq ($(KIND),fixture)
SOURCE = $(ROOT)/native-boundary/fixture.c
SOURCE_FLAGS = -fPIC
PRODUCT_FLAGS = -shared
LIBRARIES =
else ifeq ($(KIND),self-test)
CFLAGS += -DAICI_NATIVE_SELF_TEST
else
CFLAGS += '-DAICI_NATIVE_REVISION="$(REVISION)"'
endif
ifeq ($(MODE),largefile)
CFLAGS += -D_FILE_OFFSET_BITS=64
endif

NDK_TRIPLE_armv7a = armv7a-linux-androideabi
NDK_TRIPLE_aarch64 = aarch64-linux-android
NDK_TRIPLE_android-x86_64 = x86_64-linux-android
HEADER_TRIPLE_armv7a = arm-linux-androideabi
HEADER_TRIPLE_aarch64 = aarch64-linux-android
HEADER_TRIPLE_android-x86_64 = x86_64-linux-android
POINTER_WIDTH_armv7a = 4
POINTER_WIDTH_aarch64 = 8
POINTER_WIDTH_android-x86_64 = 8
TARGET_FLAGS_armv7a = -marm -march=armv7-a -mfpu=neon -mfloat-abi=softfp
TARGET_FLAGS_aarch64 = -march=armv8-a -ffixed-x18
TARGET_FLAGS_android-x86_64 = -march=x86-64
TARGET_FLAGS = $(TARGET_FLAGS_$(TARGET))
NDK_BIN = $(NDK)/toolchains/llvm/prebuilt/linux-x86_64/bin
NDK_SYSROOT = $(NDK)/toolchains/llvm/prebuilt/linux-x86_64/sysroot
PLATFORM_COMPILER = $(NDK_BIN)/$(NDK_TRIPLE_$(TARGET))24-clang
BUILTIN_INCLUDE = $(shell $(ICK) $(ICK_EXTRA_FLAGS) -print-file-name=include)

ifneq ($(TARGET),host)
# Bionic rejects COPY relocations. GCC PIE can emit them for libc data such as
# stderr; compile Android sources as PIC while retaining the PIE executable link.
SOURCE_FLAGS = -fPIC
LINK_FLAGS += -Wl,-z,text,-z,nocopyreloc
CFLAGS += $(TARGET_FLAGS) --sysroot="$(NDK_SYSROOT)" -nostdinc -isystem "$(BUILTIN_INCLUDE)" -isystem "$(NDK_SYSROOT)/usr/include/$(HEADER_TRIPLE_$(TARGET))" -isystem "$(NDK_SYSROOT)/usr/include" -D__ANDROID__ -D__ANDROID_API__=24 -D__ANDROID_MIN_SDK_VERSION__=24 -DBIONIC_IOCTL_NO_SIGNEDNESS_OVERLOAD -DAICI_REQUIRE_BIONIC=1 -DAICI_EXPECT_POINTER_SIZE=$(POINTER_WIDTH_$(TARGET))
ifneq ($(TARGET),armv7a)
LINK_FLAGS += -Wl,-z,max-page-size=16384 -Wl,-z,common-page-size=16384
endif
endif

.PHONY: all
.SECONDARY:
all: $(OUTPUT)

ASSEMBLY = $(STAGE_DIR)/$(notdir $(OUTPUT)).s
OBJECT = $(STAGE_DIR)/$(notdir $(OUTPUT)).o

$(ASSEMBLY): $(SOURCE) $(ROOT)/native-boundary/Makefile
	mkdir -p "$(@D)"
	$(ICK) $(ICK_EXTRA_FLAGS) $(CFLAGS) $(SOURCE_FLAGS) -S "$<" -o "$@"

ifeq ($(TARGET),host)
$(OUTPUT): $(ASSEMBLY)
	$(ICK) $(ICK_EXTRA_FLAGS) $(ICK_LINK_FLAGS) $(PRODUCT_FLAGS) "$<" $(LIBRARIES) $(LINK_FLAGS) -o "$@"
else
$(OBJECT): $(ASSEMBLY)
	"$(PLATFORM_COMPILER)" $(TARGET_FLAGS) -c "$<" -o "$@"

$(OUTPUT): $(OBJECT)
	"$(PLATFORM_COMPILER)" $(TARGET_FLAGS) $(PRODUCT_FLAGS) "$<" $(LIBRARIES) $(LINK_FLAGS) -o "$@"
endif
