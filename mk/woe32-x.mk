
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
BUILDDIR := $(shell pwd)/../../build/$(PACKAGE)-$(VERSION)
DESTDIR := $(shell pwd)/../../inst/$(PACKAGE)-$(VERSION)
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

config: config.stamp
build: build.stamp
check: check.stamp

config.stamp:
	set -e; unset CONFIG_SITE ; \
	mkdir -p $(BUILDDIR); cd $(BUILDDIR); \
	$(CONFIGURE)
	touch $@

build.stamp: config.stamp
	$(MAKE) -C $(BUILDDIR)
	$(MAKE) -C $(BUILDDIR) pdf
	touch $@

check.stamp: build.stamp
	$(MAKE) -C $(BUILDDIR) check
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

install.stamp: check.stamp $(EXTRA_INSTALLS)
	# "Stand alone" installation
	$(call do_install,,$(DESTDIR),$(PREFIX))
	# "Stand alone" installation without debugging symbols
	$(call do_install,-strip,$(DESTDIR),$(PREFIX))
	# Another copy for all-in-one tarball
	$(call do_install,,$(GINAC_DESTDIR),$(GINAC_PREFIX))
	# Yet another copy for all-in-one tarball, without debugging symbols
	$(call do_install,-strip,$(GINAC_DESTDIR),$(GINAC_PREFIX))
	# Install a copy into collection of woe32 libraries (managed by stow)
	$(stow_install)
	touch $@

$(BIN_DBG_TBZ): install.stamp
	tar -cjf $@ -C $(DESTDIR) $(patsubst /%, %, $(PREFIX))

$(BIN_TBZ): install.stamp
	tar -cjf $@ -C $(DESTDIR).stripped $(patsubst /%, %, $(PREFIX))

$(GPG_SIGN): %.asc: %
	gpg -a -b -s -u $(GPGKEY) -o $@ $<

$(MD5SUMS): %.md5: %
	md5sum $< > $@.tmp
	mv $@.tmp $@

CLEANFILES := $(addsuffix .stamp,install check build config) 
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
