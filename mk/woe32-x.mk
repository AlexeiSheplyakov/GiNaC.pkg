
# Compile a package for woe32 on Linux (either x86-64 or x86-32)
# using MinGW Linux-hosted cross-compiler and wine (and libtool 2.2.x).

# Different distros call MinGW compiler in different ways
ARCH := i586-mingw32msvc

MINGW_TARGET := $(HOME)/target/$(ARCH)
STOWDIR := $(MINGW_TARGET)/stow
GINAC_PREFIX := /opt/$(ARCH)/ginac
GINAC_DESTDIR := $(shell pwd)/../../inst/all

# What to build:
BIN_TBZ := $(shell pwd)/../../upload/$(PACKAGE)-$(VERSION)-$(ARCH).tar.bz2
BIN_DBG_TBZ := $(shell pwd)/../../upload/$(PACKAGE)-$(VERSION)-$(ARCH)-dbg.tar.bz2
BIN_TARBALLS := $(BIN_TBZ) $(BIN_DBG_TBZ)
MD5SUMS := $(BIN_TARBALLS:%=%.md5)
GPG_SIGN :=
ifneq (,$(GPGKEY))
GPG_SIGN += $(BIN_TARBALLS:%=%.asc)
endif

all: $(BIN_TARBALLS) $(MD5SUMS) $(GPG_SIGN)


# If the package is re-configured, make will try rebuild everything,
# since the `config.h' file and friends have been re-generated. Use ccache(1)
# as a work around. N.B.: ccache is a *NIX
CCACHE ?= ccache

# Use MinGW toolchain
CC := $(CCACHE) $(ARCH)-gcc
CXX := $(CCACHE) $(ARCH)-g++
# XXX: libtool 2.2.x dislikes AS containing whitespace
# AS := $(CCACHE) $(ARCH)-as
AS := $(ARCH)-as
LD := $(ARCH)-ld
NM := $(ARCH)-nm
AR := $(ARCH)-ar
RANLIB := $(ARCH)-ranlib
DLLTOOL := $(ARCH)-dlltool
WINDRES := $(ARCH)-windres
OBJDUMP := $(ARCH)-objdump
STRIP := $(ARCH)-strip
export CC CXX AS LD NM AR RANLIB DLLTOOL WINDRES OBJDUMP STRIP

# We also need some *NIX tools (shell, make, TeX, etc.)
# XXX: libtool cross compilation with wine works only with bash
SHELL := /bin/bash
CONFIG_SHELL := /bin/bash
PATH := /usr/$(ARCH)/bin:/bin:/usr/bin
export SHELL CONFIG_SHELL PATH

# Compile for generic pentium-compatible CPU.
CFLAGS := -O2 -g -Wall -pipe -march=i686
CXXFLAGS := $(CFLAGS)
CPPFLAGS :=
LDFLAGS :=
include $(PACKAGE)_cflags.mk
export CFLAGS CXXFLAGS CPPFLAGS LDFLAGS

PREFIX := /opt/$(ARCH)/$(PACKAGE)-$(VERSION)
SRCDIR := $(shell pwd)/../../$(PACKAGE)
BUILDDIR := $(shell pwd)/../../build-tree/build/$(PACKAGE)-$(VERSION)
DESTDIR := $(shell pwd)/../../build-tree/inst/$(PACKAGE)-$(VERSION)
STAMPDIR := $(shell pwd)/../../build-tree/stamps
$(info DESTDIR $(DESTDIR))

# Classical cross-compilation
# XXX: configure script fails detect cross-compilation since we set up
# binfmt_misc to directly execute woe32 binaries (which is necessary for
# tests). So --host=... and --build=... arguments below *are* necessary.
# In order to find out politically correct for of the --build we need
# the config.guess script from libtool. However the package might put it into
# a different subdirectory, hence we need to parse configure.{ac,in} to
# find out where that directory is.
define configure_ac
$(SRCDIR)/configure$(if $(wildcard $(SRCDIR)/configure.ac),.ac,.in)
endef
ac_config_aux_dir_rx := 's/^AC_CONFIG_AUX_DIR([[]*\([^])]\+\)[]]*)[ \t]*$$/\1/p'
define ac_config_aux_dir
$(strip $(shell sed -n -e $(ac_config_aux_dir_rx) $(configure_ac)))
endef
define config_guess
$(SRCDIR)/$(if $(ac_config_aux_dir),$(ac_config_aux_dir)/,)config.guess
endef

CONFIGURE := $(CONFIGURE_ENV) $(SHELL) $(SRCDIR)/configure \
	--host=$(ARCH) --build=$(shell $(config_guess)) \
	--enable-shared --disable-static --prefix=$(PREFIX) \
	$(CONFIGURE_ARGS)

CONFIG_STAMP := $(STAMPDIR)/config.$(PACKAGE)-$(VERSION).stamp
BUILD_STAMP := $(STAMPDIR)/build.$(PACKAGE)-$(VERSION).stamp
CHECK_STAMP := $(STAMPDIR)/check.$(PACKAGE)-$(VERSION).stamp
INSTALL_STAMP := $(STAMPDIR)/install.$(PACKAGE)-$(VERSION).stamp

config: $(CONFIG_STAMP)
build: $(BUILD_STAMP)
check: $(CHECK_STAMP)
install: $(INSTALL_STAMP)

$(CONFIG_STAMP):
	set -e; unset CONFIG_SITE ; \
	mkdir -p $(BUILDDIR); cd $(BUILDDIR); \
	$(CONFIGURE)
	if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
	touch $@

$(BUILD_STAMP): $(CONFIG_STAMP)
	$(MAKE) -C $(BUILDDIR)
	$(MAKE) -C $(BUILDDIR) pdf
	if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
	touch $@

$(CHECK_STAMP): $(BUILD_STAMP)
	$(MAKE) -C $(BUILDDIR) check
	if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
	touch $@

do_extra_install := : #
-include $(PACKAGE)_extra_build.mk

define do_install_real
set -e ; \
$(MAKE) -C $(BUILDDIR) install$(1) DESTDIR=$(2)$(if $(1),.stripped,) prefix=$(3) ; \
$(MAKE) -C $(BUILDDIR) install-pdf DESTDIR=$(2)$(if $(1),.stripped,) prefix=$(3) ; \
rm -rf $(2)$(if $(1),.stripped,)$(3)/share/info ; \
rm -rf $(2)$(if $(1),.stripped,)$(3)/share/man ; \
rm -rf $(2)$(if $(1),.stripped,)$(3)/info ; \
rm -rf $(2)$(if $(1),.stripped,)$(3)/man ; \
find $(2)$(if $(1),.stripped,)$(3) -type f -name '*.la' | xargs rm -f ; \
$(call do_extra_install,$(1),$(2),$(3))
endef
define do_install
$(call do_install_real,$(strip $(1)),$(strip $(2)),$(strip $(3)))
endef

define do_stow_install
$(MAKE) -C $(BUILDDIR) install DESTDIR=$(STOWDIR) prefix=/$(PACKAGE)-$(VERSION) ; \
rm -rf $(STOWDIR)/$(PACKAGE)-$(VERSION)/share/info ; 				\
rm -rf $(STOWDIR)/$(PACKAGE)-$(VERSION)/share/man ;				\
find $(STOWDIR)/$(PACKAGE)-$(VERSION) -type f -name '*.la' | xargs rm -f ; 	\
stow --dir=$(STOWDIR) -D $(PACKAGE) || true ; 					\
rm -f $(STOWDIR)/$(PACKAGE) ;							\
ln -s $(PACKAGE)-$(VERSION) $(STOWDIR)/$(PACKAGE) ;				\
stow --dir=$(STOWDIR) $(PACKAGE)
endef
define stow_install
if [ -d $(STOWDIR) ]; then	\
	$(do_stow_install) ; 	\
fi
endef

define fixup_pc_files
find $(1) -type f -name '*.pc' | xargs --no-run-if-empty -n1 sed -i -e 's%^prefix=.*$$%prefix=$(2)%g'
endef

$(INSTALL_STAMP): $(CHECK_STAMP) $(EXTRA_INSTALLS)
	# "Stand alone" installation
	$(call do_install,,$(DESTDIR),$(PREFIX))
	# "Stand alone" installation without debugging symbols
	$(call do_install,-strip,$(DESTDIR),$(PREFIX))
	# Another copy for all-in-one tarball
	$(call do_install,,$(GINAC_DESTDIR),$(GINAC_PREFIX))
	$(call fixup_pc_files,$(GINAC_DESTDIR),$(GINAC_PREFIX))
	# Yet another copy for all-in-one tarball, without debugging symbols
	$(call do_install,-strip,$(GINAC_DESTDIR),$(GINAC_PREFIX))
	$(call fixup_pc_files,$(GINAC_DESTDIR).stripped,$(GINAC_PREFIX))
	# Install a copy into collection of woe32 libraries (managed by stow)
	$(stow_install)
	if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
	touch $@

$(BIN_DBG_TBZ): $(INSTALL_STAMP)
	mkdir -p $(dir $@)
	tar -cjf $@ -C $(DESTDIR) $(patsubst /%, %, $(PREFIX))

$(BIN_TBZ): $(INSTALL_STAMP)
	mkdir -p $(dir $@)
	tar -cjf $@ -C $(DESTDIR).stripped $(patsubst /%, %, $(PREFIX))

$(GPG_SIGN): %.asc: %
	gpg -a -b -s -u $(GPGKEY) -o $@ $<

$(MD5SUMS): %.md5: %
	md5sum $< > $@.tmp
	sed -i -e 's/^\([0-9a-f]\+\)\([ \t]\+\).*[/]\([^/]\+\)$$/\1\2\3/g' $@.tmp
	mv $@.tmp $@

CLEANFILES := $(INSTALL_STAMP) $(CHECK_STAMP) $(BUILD_STAMP) $(CONFIG_STAMP)
CLEANDIRS := $(BUILDDIR) $(DESTDIR) $(DESTDIR).stripped
ALLCLEANFILES := $(CLEANFILES) $(MD5SUMS) $(GPG_SIGN) $(BIN_TARBALLS) 
ALLCLEANDIRS := $(CLEANDIRS)

clean:
	-@echo [CLEAN] $(PACKAGE)
	-@rm -f $(CLEANFILES)
	-@rm -rf $(CLEANDIRS)

allclean:
	-@echo [ALLCLEAN] $(PACKAGE)
	-@rm -f $(ALLCLEANFILES)
	-@rm -rf $(ALLCLEANDIRS)

.PHONY: install check clean allclean
# disable parallel execution of rules in this file, but pass on -j ( and
# other flags) so package's own makefile can use parallel make 
.NOTPARALLEL:

