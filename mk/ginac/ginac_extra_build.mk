
define do_extra_install
readline_dll=`readlink -m $(MINGW_TARGET)/bin/readline5.dll` ; \
cp -a $$readline_dll $(2)$(3)/bin
endef

