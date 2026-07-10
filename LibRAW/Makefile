#-------------------------------------------------------------------------------
# Copyright (c) 2026, Jean-David Gadina - www.xs-labs.com
# Distributed under the terms of the MIT License.
#
# Builds LibRAW as a universal (x86_64 + arm64) static library targeting a
# specific macOS deployment version, then installs the headers and archives
# into `include/` and `lib/`.
#
# The pre-built LibRAW distribution ships archives whose minimum OS version does
# not match SwiftRAW's, so we compile from source here to control the deployment
# target. LibRAW's own `Makefile.dist` can only build for the host architecture,
# so each slice is compiled separately and merged with `lipo`.
#-------------------------------------------------------------------------------

DIR_ROOT            := $(realpath .)/
DIR_BUILD           := $(DIR_ROOT)build/
DIR_TMP             := $(DIR_ROOT)tmp/
DIR_INC             := $(DIR_ROOT)include/
DIR_LIB             := $(DIR_ROOT)lib/

LIBRAW_VERSION      := 0.22.1
LIBRAW_URL          := https://github.com/LibRaw/LibRaw/archive/refs/tags/$(LIBRAW_VERSION).tar.gz
LIBRAW_SRC          := $(DIR_TMP)libraw-src.tar.gz
LIBRAW_DIR          := LibRaw-$(LIBRAW_VERSION)

# The macOS deployment target the archives are built against.
MACOS_VERSION_MIN   := 15.0

SYSROOT             := $(shell xcrun --sdk macosx --show-sdk-path)
JOBS                := $(shell sysctl -n hw.ncpu)

# Per-architecture compiler flags. LibRAW's `Makefile.dist` appends its own
# flags (such as `-DUSE_ZLIB`) to `CFLAGS`, so these are injected through the
# compiler command instead of by overriding `CFLAGS`, which would discard them.
FLAGS_x86_64        := -arch x86_64 -mmacosx-version-min=$(MACOS_VERSION_MIN) -isysroot $(SYSROOT)
FLAGS_arm64         := -arch arm64  -mmacosx-version-min=$(MACOS_VERSION_MIN) -isysroot $(SYSROOT)

.PHONY: all clean download dist dist-clean

all: download build-x86_64 build-arm64 dist

	@:

clean:

	@rm -rf $(DIR_BUILD)
	@rm -rf $(DIR_TMP)

download:

	@if [ ! -f $(LIBRAW_SRC) ]; then mkdir -p $(DIR_TMP) && curl -L -o $(LIBRAW_SRC) $(LIBRAW_URL); fi

dist-clean:

	@rm -f  $(DIR_LIB)*.a
	@rm -rf $(DIR_INC)libraw

$(DIR_LIB)%.a:

	@mkdir -p $(DIR_LIB)
	@lipo -create -output $@ $(DIR_BUILD)x86_64/lib/$*.a $(DIR_BUILD)arm64/lib/$*.a

.SECONDEXPANSION:

dist: _LIBS  = libraw.a libraw_r.a
dist: _FILES = $(addprefix $(DIR_LIB), $(_LIBS))
dist: dist-clean $$(_FILES)

	@cp -R $(DIR_BUILD)x86_64/include/libraw $(DIR_INC)libraw

build-%: _FLAGS     = $(FLAGS_$*)
build-%: _DIR_TMP   = $(DIR_TMP)$*/
build-%: _SRC       = $(_DIR_TMP)$(LIBRAW_DIR)/
build-%: _DIR_BUILD = $(DIR_BUILD)$*/
build-%:

	@rm -rf $(_DIR_TMP)
	@mkdir -p $(_DIR_TMP)
	@tar -xf $(LIBRAW_SRC) -C $(_DIR_TMP)
	@mkdir -p $(_SRC)object $(_SRC)lib $(_SRC)bin
	@cd $(_SRC) && make -j$(JOBS) -f Makefile.dist library CC="clang $(_FLAGS)" CXX="clang++ $(_FLAGS)"
	@mkdir -p $(_DIR_BUILD)lib $(_DIR_BUILD)include
	@cp $(_SRC)lib/libraw.a $(_SRC)lib/libraw_r.a $(_DIR_BUILD)lib/
	@cp -R $(_SRC)libraw $(_DIR_BUILD)include/libraw
