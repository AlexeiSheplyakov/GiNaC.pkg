
CXXFLAGS += -finline-limit=1200
# This linker flags are necessary in order to build the DLL.
LDFLAGS += -Wl,--enable-auto-import -Wl,--export-all-symbols -no-undefined

CLN_CFLAGS := $(call pkgconfig, --cflags cln)
CLN_LIBS := $(call pkgconfig, --libs cln)

CPPFLAGS += -I$(MINGW_TARGET)/include $(CLN_CFLAGS)
LDFLAGS += -L$(MINGW_TARGET)/lib $(call pkgconfig, --libs-only-L cln)

