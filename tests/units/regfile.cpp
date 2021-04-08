
#include <cstdlib>
#include <cstdint>
#include <cassert>
#include <iostream>

using namespace std;

#include "Vregfile.h"

int main() {
    Vregfile top;

    bool prev_led = 0;

    uint32_t regs[32];
    regs[0] = 0;
    bool valid[32];
    valid[0] = true;
    for (int i = 1; i < 32; i++) {
        valid[i] = false;
        regs[i] = 0;
    }

    top.eval();
    for (int cycle = 0; cycle < 10000000; ++cycle) {
        top.clk = 0;
        top.eval();

        uint32_t rs1 = rand() % 32;
        uint32_t rs2 = rand() % 32;
        uint32_t rd = rand() % 32;
        uint32_t rd_value = rand();

        top.rs1_address = rs1;
        top.rs2_address = rs2;
        top.rd_address = rd;
        top.rd_data = rd_value;
        
        top.eval();
        
        uint32_t rs1_out = top.rs1_data;
        uint32_t rs2_out = top.rs2_data;

        // The read should "happen" before the reads
        if (rd != 0) {
            valid[rd] = true;
            regs[rd] = rd_value;
        }
        if (valid[rs1]) {
            assert(rs1_out == regs[rs1]);
        }
        if (valid[rs2]) {
            assert(rs2_out == regs[rs2]);
        }

        top.clk = 1;
        top.eval();
    }

    return EXIT_SUCCESS;
}
