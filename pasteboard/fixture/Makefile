# Maintained source: ICK. Upstream glue/assembly/linking: pinned Android NDK.
ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
API := 26
FORTIFY_SOURCE := 2
include $(ROOT)/ick-android/Makefile
.DEFAULT_GOAL := fixture
NDK_CC = $(NDK_BIN)/$(NDK_TARGET_$(ABI))$(API)-clang
GLUE = $(NDK)/sources/android/native_app_glue
MODE_arm64-v8a = -ffixed-x18
MODE_armeabi-v7a = -marm -march=armv7-a -mfpu=neon -mfloat-abi=softfp
MODE_x86_64 = -march=x86-64-v2 -mno-avx -mno-movbe
BUILD ?= $(ROOT)/build/pasteboard-fixture/$(ABI)
OUT ?= $(BUILD)/libcopyfixture.so
.PHONY: fixture
fixture: $(OUT)
$(BUILD)/copy_fixture.s: $(ROOT)/pasteboard/fixture/copy_fixture.c
	mkdir -p "$(@D)"
	"$(ICK_COMPILER)" $(ICK_EXTRA_FLAGS) $(ICK_NDK_FLAGS) -std=c17 -O2 -fPIC -fstack-protector-strong -Wall -Wextra -Werror -Wpedantic -Wshadow -D__ANDROID_API__=$(API) -D__ANDROID_MIN_SDK_VERSION__=$(API) -isystem "$(GLUE)" -S "$<" -o "$@"
$(BUILD)/copy_fixture.o: $(BUILD)/copy_fixture.s
	"$(NDK_CC)" $(MODE_$(ABI)) --sysroot="$(NDK_SYSROOT)" -c "$<" -o "$@"
$(BUILD)/glue.o:
	mkdir -p "$(@D)"
	"$(NDK_CC)" $(MODE_$(ABI)) --sysroot="$(NDK_SYSROOT)" -std=c17 -O2 -fPIC -isystem "$(GLUE)" -c "$(GLUE)/android_native_app_glue.c" -o "$@"
$(OUT): $(BUILD)/copy_fixture.o $(BUILD)/glue.o
	mkdir -p "$(@D)"
	"$(NDK_CC)" $(MODE_$(ABI)) --sysroot="$(NDK_SYSROOT)" -shared -Wl,--no-undefined -Wl,-u,ANativeActivity_onCreate -Wl,-z,relro,-z,now $^ -landroid -llog -o "$@"
