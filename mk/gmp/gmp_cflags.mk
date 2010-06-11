
# Compiler(s), linker, etc. flags required for GMP cross compilation.
LDFLAGS += -no-undefined

# Sometimes we need to compile and run binaries during the build
HOST_CC := $(shell pwd)/hostcc-gcc
export HOST_CC

