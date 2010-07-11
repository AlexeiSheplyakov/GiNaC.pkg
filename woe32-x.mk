#!/usr/bin/make -f

PACKAGES := gmp cln ginac
include versions.mk
CONFIGURES := cln/configure ginac/configure
ARCH := i586-mingw32msvc
MINGW_TARGET := $(HOME)/target/$(ARCH)
BIN_TARBALLS := $(foreach pkg, $(PACKAGES), upload/$(pkg)-$($(pkg)_VERSION)-$(ARCH).tar.bz2)
BIN_DBG_TARBALLS := $(BIN_TARBALLS:%.tar.bz2:%-dbg.tar.bz2)
ALL_IN_ONE_PREFIX := /opt/$(ARCH)/ginac
ALL_IN_ONE_TARBALL := upload/ginac-$(ginac_VERSION)-cln-$(cln_VERSION)-gmp-$(gmp_VERSION)-$(ARCH).tar.bz2 
ALL_IN_ONE_TARBALL_DBG := $(ALL_IN_ONE_TARBALL:%.tar.bz2=%-dbg.tar.bz2)
ALL_IN_ONE_TARBALLS := $(ALL_IN_ONE_TARBALL) $(ALL_IN_ONE_TARBALL_DBG)
ALL_BIN_TARBALLS := $(BIN_TARBALLS) $(BIN_DBG_TARBALLS) $(ALL_IN_ONE_TARBALLS)
$(info ALL_IN_ONE_TARBALLS = $(ALL_BIN_TARBALLS))
RTFM := $(addprefix upload/,index.html vargs.css)
MD5SUMS := $(ALL_BIN_TARBALLS:%=%.md5)

# FIXME: makeinfo fails due to wrong grep call in all locales except C
LC_ALL := C
export LC_ALL

all: upload

upload: $(ALL_BIN_TARBALLS) $(MD5SUMS) $(RTFM)

upload/index.html: doc/readme.html.x doc/readme.py
	if [ ! -d "$(dir $@)" ]; then mkdir -p "$(dir $@)"; fi
	( cd doc; ./readme.py $(ginac_VERSION) $(cln_VERSION) $(gmp_VERSION) ) > $@.tmp
	mv $@.tmp $@

upload/vargs.css: doc/vargs.css
	cp -a $< $@

$(CONFIGURES): %/configure:
	cd $(dir $@); autoreconf -iv

PACKAGES_STAMP := build-tree/stamps/packages.stamp

$(ALL_BIN_TARBALLS): $(PACKAGES_STAMP)

$(ALL_IN_ONE_TARBALL): $(PACKAGES_STAMP)
	tar -cjf $@ -C build-tree/inst/all.stripped $(patsubst /%,%,$(ALL_IN_ONE_PREFIX))

$(ALL_IN_ONE_TARBALL_DBG): $(PACKAGES_STAMP)
	tar -cjf $@ -C build-tree/inst/all $(patsubst /%,%,$(ALL_IN_ONE_PREFIX))

$(ALL_IN_ONE_TARBALLS:%=%.md5): %.md5: %
	md5sum $< > $@.tmp
	mv $@.tmp $@

$(PACKAGES_STAMP): $(CONFIGURES)
	stow --dir=$(MINGW_TARGET)/stow -D gmp || true
	$(MAKE) -C mk/gmp -f woe32-x.mk PACKAGE=gmp VERSION=$(gmp_VERSION)
	stow --dir=$(MINGW_TARGET)/stow -D cln || true
	$(MAKE) -C mk/cln -f woe32-x.mk PACKAGE=cln VERSION=$(cln_VERSION)
	stow --dir=$(MINGW_TARGET)/stow -D ginac || true
	$(MAKE) -C mk/ginac -f woe32-x.mk PACKAGE=ginac VERSION=$(ginac_VERSION)
	touch $@

clean:
	-@echo CLEAN; rm -rf build-tree

allclean:
	-@echo CLEAN; rm -rf build-tree

.PHONY: packages.stamp clean all upload

.NOTPARALLEL:

