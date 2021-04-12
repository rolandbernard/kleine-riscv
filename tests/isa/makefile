
SRC_DIR      := .
SRC_DIR_USER := $(SRC_DIR)/rv32ui
SRC_DIR_PRIV := $(SRC_DIR)/rv32mi

BUILD_DIR := ./build

TESTS_USER := $(shell find $(SRC_DIR_USER) -type f -name '*.S')
# TESTS_PRIV := $(shell find $(SRC_DIR_PRIV) -type f -name '*.S')
TESTS      := $(TESTS_USER) $(TESTS_PRIV)

TEST_BINS  := $(patsubst $(SRC_DIR)/%.S, $(BUILD_DIR)/%, $(TESTS))

CC      := clang
OBJCOPY := llvm-objcopy

CFLAGS := --target=riscv32 -march=rv32i -ffreestanding -nostdlib -mno-relax
CFLAGS += -Wl,-Bstatic,-T,link.ld,--strip-debug -I$(SRC_DIR) -fuse-ld=lld

.SILENT:
.SECONDARY:
.SECONDEXPANSION:
.PHONY: all

all: $(TEST_BINS)

$(BUILD_DIR)/%: $(SRC_DIR)/%.S ./link.ld ./riscv_test.h $(MAKEFILE_LIST) | $$(dir $$@)
	@echo "Building $@"
	$(CC) $(CFLAGS) $< -o $@

%/:
	mkdir -p $@

