
# Define rules to build and install extra targets

EXTRA_INSTALLS := $(BUILDDIR)/pi.exe
$(BUILDDIR)/pi.exe: $(SRCDIR)/examples/pi.cc $(CHECK_STAMP)
	$(CXX) -I$(SRCDIR)/include -I$(BUILDDIR)/include -o $@ $< -L$(BUILDDIR)/src/.libs -lcln

define do_extra_install
install -m755 $(BUILDDIR)/pi.exe $(2)$(if $(1),.stripped,)$(3)/bin ; \
$(if $(1),$(STRIP) $(2).stripped$(3)/bin/pi.exe,:)
endef

