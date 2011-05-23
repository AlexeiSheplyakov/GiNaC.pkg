
# Compiler(s), linker, etc. flags required for CLN cross compilation.
# These linker flags are necessary in order to build the DLL.
LDFLAGS += -Wl,--enable-auto-import -Wl,--export-all-symbols -no-undefined
CXXFLAGS += -finline-limit=1200
export CFLAGS CXXFLAGS LDFLAGS

# XXX: fix GMP to support pkg-config
gmp_CFLAGS :=
gmp_LIBS := -lgmp

# x86-32 asm shipped with CLN is *slower* than gcc-generated one
# from C++ code. I've checked with pentium[234], k7, k8.
CPPFLAGS += -DNO_ASM
CPPFLAGS += $(gmp_CFLAGS)
LDFLAGS += $(gmp_LIBS)

