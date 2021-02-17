
CXX=clang++
YOSYS=yosys

BUILD=build
RTL=$(BUILD)/rtl
BIN=$(BUILD)/test
SRC=src
UTEST=tests/units

VRLS=$(shell find $(SRC) -type f -name '*.v')
RTLS=$(patsubst $(SRC)/%.v, $(RTL)/%.cpp, $(VRLS))

SIMS=$(shell find $(UTEST) -type f -name '*.cpp')
UTESTS=$(patsubst $(UTEST)/%.cpp, $(BIN)/%, $(SIMS))
RUNTESTS=$(addprefix RUNTEST.,$(UTESTS))
	
.SECONDARY:
.PHONY: test build-tests RUNTEST.$(BIN)/%

test: $(RUNTESTS)

$(RTL)/%.cpp: $(SRC)/units/%.v
	@echo Building $@
	@mkdir -p $(shell dirname $@)
	@$(YOSYS) -g -q -b cxxrtl -o $@ $<

$(BIN)/%: $(UTEST)/%.cpp $(RTL)/%.cpp
	@echo Building $@
	@mkdir -p $(shell dirname $@)
	@$(CXX) -g -I$(shell yosys-config --datdir)/include -I$(BUILD) -o $@ $<

RUNTEST.$(BIN)/%: $(BIN)/%
	@echo "Running test $(notdir $<)"
	@$<

