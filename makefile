
# == Directories
SRC_DIR   := src
BUILD_DIR := build
TEST_DIR  := tests
ISA_DIR   := $(TEST_DIR)/isa
UNITS_DIR := $(TEST_DIR)/units
# ==

# == Files
UNIT_SRC   := $(shell find $(UNITS_DIR) -type f -name '*.cpp')
UNIT_TESTS := $(patsubst $(UNITS_DIR)/%.cpp, $(BUILD_DIR)/V%, $(UNIT_SRC))
ISA_SRC    := $(shell find $(ISA_DIR) -type f -name '*.S')
ISA_BIN    := $(patsubst $(ISA_DIR)/%.S, $(ISA_DIR)/build/%.bin, $(ISA_SRC))
ISA_TESTS  := $(ISA_BIN:.bin=.hex)
# ==

# == Runing goals
RUNTESTS  := $(addprefix RUNTEST.,$(UNIT_TESTS) $(ISA_TESTS))
# ==

# == Verilator config
VERILATOR := verilator
VERIFLAGS := $(addprefix -I,$(shell find $(SRC_DIR) -type d)) -Wall -Mdir $(BUILD_DIR)
# ==

.SILENT:
.SECONDARY:
.SECONDEXPANSION:
.PHONY: test build-tests RUNTEST.$(BUILD_DIR)/% RUNTEST.$(ISA_DIR)/build/%

test: $(RUNTESTS)

$(BUILD_DIR)/V%: $(SRC_DIR)/units/%.v $(UNITS_DIR)/%.cpp | $$(dir $$@)
	@echo Building $@
	$(VERILATOR) $(VERIFLAGS) --cc --exe --build $^

$(BUILD_DIR)/V%: $(SRC_DIR)/%.v $(TEST_DIR)/core/%.cpp | $$(dir $$@)
	@echo Building $@
	$(VERILATOR) $(VERIFLAGS) --cc --exe --build $^

%/:
	mkdir -p $@

$(ISA_DIR)/build/%.bin: $(ISA_SRC)
	$(MAKE) -C tests/isa

$(ISA_DIR)/build/%.hex: $(ISA_DIR)/build/%.bin
	@echo Building $@
	hexdump -e '4/4 "%08x " "\n"' $< > $@

RUNTEST.$(BUILD_DIR)/%: $(BUILD_DIR)/%
	@echo "Running test $(notdir $<)"
	$<

RUNTEST.$(ISA_DIR)/build/%: $(ISA_DIR)/build/% | $(BUILD_DIR)/Vcore
	@echo "Running test $(notdir $<)"
	$(BUILD_DIR)/Vcore $<

