# kleine-riscv

This is a small RISC-V core written in synthesizable Verilog that supports the RV32I unprivileged ISA and parts of the privileged ISA, namely M-mode.
This is only the RISC-V core and does not include any other peripherals.

## Files in this Repository

* The Verilog source of the core can be found inside the `src` directory. The top module is the `core` module inside `src/core.v`.
* In the `sim` directory you find a small simulator that when compiled using Verilator is used for testing.
* Inside the `tests/units` directory are 3 tests for testing the `alu`, `cmp` and `regfile` modules. These tests are no longer really necessary and were only used in the beginning to verify these units on their own. (This is my first Verilog project and these tests verified my first modules.)
* Inside the `tests/isa` directory are the main tests testing the functionality of the core. Most of them are modified versions of the tests in [riscv-tests](https://github.com/riscv/riscv-tests).
  * The tests inside `tests/isa/rv32ui` test the unprivileged ISA.
  * The tests inside `tests/isa/rv32mi` test the privileged ISA.
* The makefile contains the `test` and `sim` targets. If you want to run all the test, run `make` or `make test`. If you only want to build the simulator run `make sim`.

## Architecture

This core is currently not really optimized in any way. It is designed mainly with simplicity in mind. There is currently no instruction and no data cache, which means that the speed of the core will depend significantly on the memory latency and speed.
The core uses the *classic* five-stage RISC pipeline (FETCH, DECODE, EXECUTE, MEMORY, WRITEBACK). It also implements bypassing from the WRITEBACK and, when possible, from the MEMORY stages. All pipeline stages have their own file inside `src/pipeline` and are connected together inside the `src/pipeline/pipeline.v` module.

## Simulator

The simulator is only very simple. It allows you to set the amount of available memory, the memory latency and the maximum number of cycles to execute (this is used in the test to prevent infinite loops) and initialize the memory using ELF executable files. The simulator will also write every byte written to the address `0x10000000` to stderr (this is a placeholder for a real UART device).
