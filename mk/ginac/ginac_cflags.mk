
CXXFLAGS += -finline-limit=1200
# This linker flags are necessary in order to build the DLL.
LDFLAGS += -Wl,--enable-auto-import -Wl,--export-all-symbols

CLN_CFLAGS :=
CLN_LIBS := -lcln
export CLN_CFLAGS CLN_LIBS

# Convince libtool to produce a shared library. Note: this switch can NOT
# be passed via LDFLAGS since GCC bails out on any unknown flags
EXTRA_LDFLAGS += -no-undefined

CPPFLAGS += $(CLN_CFLAGS)
LDFLAGS += $(CLN_LIBS)

