
CXX=clang++
YOSYS=yosys

BUILD=build
RTL=$(BUILD)/rtl
BIN=$(BUILD)/test
SRC=src
UTEST=tests/unit

VRLS=$(shell find $(SRC) -type f -name '*.v')
RTLS=$(patsubst $(SRC)/%.v, $(RTL)/%.cpp, $(VRLS))

SIMS=$(shell find $(UTEST) -type f -name '*.cpp')
UTESTS=$(patsubst $(UTEST)/%.cpp, $(BIN)/%, $(SIMS))
RUNTESTS=$(addprefix runtest.,$(UTESTS))

test: $(RUNTESTS)

$(RTL)/%.cpp: $(SRC)/%.v
	@echo Building $@
	@mkdir -p $(shell dirname $@)
	@$(YOSYS) -g -q -b cxxrtl -o $@ $<

$(BIN)/%: $(UTEST)/%.cpp $(RTL)/%.cpp
	@echo Building $@
	@mkdir -p $(shell dirname $@)
	@$(CXX) -g -I$(shell yosys-config --datdir)/include -I$(BUILD) -o $@ $<

runtest.$(BIN)/%: $(BIN)/%
	@echo "Running test $(notdir $<)"
	@$<
	
.PHONY: test build-tests
.SECONDARY:
