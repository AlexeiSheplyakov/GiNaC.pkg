#!/usr/bin/make -f

PACKAGES := gmp cln ginac
gmp_VERSION := 4.3.1
cln_VERSION := 1.3.1
ginac_VERSION := 1.5.5
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
MD5SUMS := $(ALL_BIN_TARBALLS:%=%.md5)

all: upload

upload: $(ALL_BIN_TARBALLS) $(MD5SUMS)
	cp -a README.html upload/index.html
	cp -a vargs.css upload

$(CONFIGURES): %/configure:
	cd $(dir $@); autoreconf -iv

$(ALL_BIN_TARBALLS): packages.stamp

$(ALL_IN_ONE_TARBALL): packages.stamp
	tar -cjf $@ -C inst/all.stripped $(patsubst /%,%,$(ALL_IN_ONE_PREFIX))

$(ALL_IN_ONE_TARBALL_DBG): packages.stamp
	tar -cjf $@ -C inst/all $(patsubst /%,%,$(ALL_IN_ONE_PREFIX))

$(ALL_IN_ONE_TARBALLS:%=%.md5): %.md5: %
	md5sum $< > $@.tmp
	mv $@.tmp $@

packages.stamp: $(CONFIGURES)
	stow --dir=$(MINGW_TARGET)/stow -D gmp || true
	$(MAKE) -C mk/gmp -f woe32-x.mk
	stow --dir=$(MINGW_TARGET)/stow -D cln || true
	$(MAKE) -C mk/cln -f woe32-x.mk
	stow --dir=$(MINGW_TARGET)/stow -D ginac || true
	$(MAKE) -C mk/ginac -f woe32-x.mk
	touch $@

CLEANFILES := packages.stamp
CLEANDIRS := inst build

clean:
	-@echo CLEAN stamps; rm -f $(CLEANFILES)
	-@echo CLEAN ginac; $(MAKE) -C mk/ginac -f woe32-x.mk clean
	-@echo CLEAN cln; $(MAKE) -C mk/cln -f woe32-x.mk clean
	-@echo CLEAN gmp; $(MAKE) -C mk/gmp -f woe32-x.mk clean

allclean:
	-@echo CLEAN stamps; rm -f $(CLEANFILES)
	-@echo CLEAN inst; rm -rf $(CLEANDIRS)
	-@echo ALLCLEAN ginac; $(MAKE) -C mk/ginac -f woe32-x.mk allclean
	-@echo ALLCLEAN cln; $(MAKE) -C mk/cln -f woe32-x.mk allclean
	-@echo ALLCLEAN gmp; $(MAKE) -C mk/gmp -f woe32-x.mk allclean

.PHONY: packages.stamp clean all upload

.NOTPARALLEL:

