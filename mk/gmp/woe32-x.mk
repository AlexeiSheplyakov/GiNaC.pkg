#!/usr/bin/make -f
# Compile GMP for woe32 on Linux (either x86-64 or x86-32) using MinGW
# Linux-hosted cross-compiler and wine (and libtool 2.2.x).

PACKAGE := gmp
VERSION := 5.0.1
CONFIGURE_ARGS := --enable-fat --enable-cxx

include ../woe32-x.mk

