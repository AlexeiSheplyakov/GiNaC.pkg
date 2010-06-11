
CXXFLAGS += -finline-limit=1200
# This linker flags are necessary in order to build the DLL.
LDFLAGS += -Wl,--enable-auto-import -Wl,--export-all-symbols -no-undefined

PKG_CONFIG_PATH := $(MINGW_TARGET)/lib/pkgconfig
export PKG_CONFIG_PATH
define pkgconfig
$(strip $(shell set -e; export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH); \
		pkg-config --define-variable=prefix=$(MINGW_TARGET) $(1)))
endef

CLN_CFLAGS := $(call pkgconfig, --cflags cln)
CLN_LIBS := $(call pkgconfig, --libs cln)

CPPFLAGS += -I$(MINGW_TARGET)/include $(CLN_CFLAGS)
LDFLAGS += -L$(MINGW_TARGET)/lib $(call pkgconfig, --libs-only-L cln)

