
# Compiler(s), linker, etc. flags required for CLN cross compilation.
# These linker flags are necessary in order to build the DLL.
LDFLAGS := -Wl,--enable-auto-import -Wl,--export-all-symbols -no-undefined
CXXFLAGS += -finline-limit=1200
export CFLAGS CXXFLAGS LDFLAGS

PKG_CONFIG_PATH := $(MINGW_TARGET)/lib/pkgconfig
export PKG_CONFIG_PATH
define pkgconfig
$(strip $(shell set -e; export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH); \
		pkg-config --define-variable=prefix=$(MINGW_TARGET) $(1)))
endef

# XXX: fix GMP to support pkg-config
gmp_CFLAGS := -I$(MINGW_TARGET)/include
gmp_LIBS := -L$(MINGW_TARGET)/lib -lgmp

# x86-32 asm shipped with CLN is *slower* than gcc-generated one
# from C++ code. I've checked with pentium[234], k7, k8.
CPPFLAGS += -DNO_ASM
CPPFLAGS += $(gmp_CFLAGS)
LDFLAGS += $(gmp_LIBS)

