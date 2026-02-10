# Common build rules included by main Makefile

SHELL := /bin/bash
RM := rm -f
MKDIR := mkdir -p

# Compiler detection
ifeq ($(origin CC),default)
    CC := gcc
endif

# Common flags
COMMON_CFLAGS := -Wall -Wextra -pedantic
DEBUG_CFLAGS := $(COMMON_CFLAGS) -g -DDEBUG -O0
RELEASE_CFLAGS := $(COMMON_CFLAGS) -O2 -DNDEBUG

# Platform detection
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    PLATFORM := linux
    LDFLAGS += -lpthread
endif
ifeq ($(UNAME_S),Darwin)
    PLATFORM := macos
    LDFLAGS += -framework CoreFoundation
endif

# Generic compile rule
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Clean generated files
clean-objs:
	$(RM) $(OBJECTS)
