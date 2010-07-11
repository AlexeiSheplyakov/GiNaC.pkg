#!/usr/bin/make -f

# Compile GiNaC for woe32 on Linux (either x86-64 or x86-32) using MinGW
# Linux-hosted cross-compiler and wine (and libtool 2.2.x).

CONFIGURE_ARGS :=
CONFIGURE_ENV = env CLN_LIBS="$(CLN_LIBS)" CLN_CFLAGS="$(CLN_CFLAGS)"

include ../woe32-x.mk

