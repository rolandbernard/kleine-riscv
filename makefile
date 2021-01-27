
CXX=clang++
YOSYS=yosys

BUILD=build
RTL=$(BUILD)/rtl
BIN=$(BUILD)/test
SRC=src
TEST=tests

VRLS=$(shell find $(SRC) -type f -name '*.v')
RTLS=$(patsubst $(SRC)/%.v, $(RTL)/%.cpp, $(VRLS))

SIMS=$(shell find $(TEST) -type f -name '*.cpp')
TESTS=$(patsubst $(TEST)/%.cpp, $(BIN)/%, $(SIMS))
RUNTESTS=$(addprefix runtest.,$(TESTS))

test: $(RUNTESTS)

$(RTL)/%.cpp: $(SRC)/%.v
	@echo Building $@
	@mkdir -p $(shell dirname $@)
	@$(YOSYS) -g -q -b cxxrtl -o $@ $<

$(BIN)/%: $(TEST)/%.cpp $(RTL)/%.cpp
	@echo Building $@
	@mkdir -p $(shell dirname $@)
	@$(CXX) -g -I$(shell yosys-config --datdir)/include -I$(BUILD) -o $@ $<

runtest.$(BIN)/%: $(BIN)/%
	@echo "Running test $@"
	@$<
	
.PHONY: test build-tests
.SECONDARY:
