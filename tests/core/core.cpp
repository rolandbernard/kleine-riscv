
#include <fstream>
#include <iostream>
#include <stdint.h>
#include <stdio.h>
#include <string>
#include <unordered_map>

#include "Vcore.h"

struct MagicMemory {
    std::unordered_map<uint32_t, uint32_t> data;

    void handleRequest(Vcore &core) {
        if (core.ext_valid) {
            if (core.ext_write_strobe == 0) {
                if (data.find(core.ext_address) != data.end()) {
                    core.ext_read_data = data[core.ext_address];
                } else {
                    core.ext_read_data = 0;
                }
            } else {
                if (0x10000000 == core.ext_address) {
                    if (core.ext_write_data == 1) {
                        exit(EXIT_SUCCESS);
                    } else {
                        std::cerr << "Failed test case #" << core.ext_write_data << std::endl;
                        exit(EXIT_FAILURE);
                    }
                } else {
                    uint32_t new_data = data[core.ext_address];
                    for (int i = 0; i < 4; i++) {
                        if (core.ext_write_strobe & (1 << i)) {
                            new_data &= ~(0xff << (8 * i));
                            new_data |= (0xff << (8 * i)) & core.ext_write_data;
                        }
                    }
                    data[core.ext_address] = new_data;
                }
            }
            core.ext_ready = true;
        } else {
            core.ext_ready = false;
        }
    }

    void delayRequest(Vcore &core) {
        core.ext_ready = false;
    }

    bool loadFromFile(std::string filename) {
        std::ifstream file(filename);
        if (file.is_open()) {
            uint32_t value;
            for (uint32_t i = 0; file >> std::hex >> value; i += 4) {
                data[i] = value;
            }
            return true;
        } else {
            return false;
        }
    }
};

#define CYCLE_MAXIMUM 100000

int main(int argc, char** argv) {
    // TODO: add direct .elf loading
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " [FILE]" << std::endl;
    } else {
        MagicMemory memory;
        Vcore core;
        memory.loadFromFile(std::string(argv[1]));
        core.reset = 1;
        core.clk = 0;
        core.eval();
        core.clk = 1;
        core.eval();
        core.clk = 0;
        core.reset = 0;
        core.eval();
        memory.handleRequest(core);
        for (int i = 0; i < CYCLE_MAXIMUM; i++) {
            core.eval();
            core.clk = 1;
            core.eval();
            core.clk = 0;
            core.eval();
            memory.handleRequest(core);
        }
        std::cerr << "Terminated after " << CYCLE_MAXIMUM << " cycles" << std::endl;
    }
    return EXIT_FAILURE;
}

