
# Compiler(s), linker, etc. flags required for CLN cross compilation.
# These linker flags are necessary in order to build the DLL.
LDFLAGS += -Wl,--enable-auto-import -Wl,--export-all-symbols
CXXFLAGS += -finline-limit=1200
export CFLAGS CXXFLAGS LDFLAGS

gmp_CFLAGS :=
gmp_LIBS := -lgmp

# Convince libtool to produce a shared library. Note: this switch can NOT
# be passed via LDFLAGS since GCC bails out on any unknown flags
EXTRA_LDFLAGS += -no-undefined

# x86-32 asm shipped with CLN is *slower* than gcc-generated one
# from C++ code. I've checked with pentium[234], k7, k8.
CPPFLAGS += -DNO_ASM
CPPFLAGS += $(gmp_CFLAGS)
LDFLAGS += $(gmp_LIBS)

