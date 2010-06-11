#!/usr/bin/make -f

# Compile CLN for woe32 on Linux (either x86-64 or x86-32) using MinGW
# Linux-hosted cross-compiler and wine (and libtool 2.2.x).

PACKAGE := cln
VERSION := 1.3.1
CONFIGURE_ARGS :=
CONFIGURE_ENV =

include ../woe32-x.mk

