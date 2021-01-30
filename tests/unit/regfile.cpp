
#include <cstdlib>
#include <cstdint>
#include <cassert>
#include <iostream>

using namespace std;

#include "rtl/regfile.cpp"

int main() {
    cxxrtl_design::p_regfile top;

    bool prev_led = 0;

    uint32_t regs[32];
    regs[0] = 0;
    bool valid[32];
    valid[0] = true;
    for (int i = 1; i < 32; i++) {
        valid[i] = false;
        regs[i] = 0;
    }

    top.step();
    for (int cycle = 0; cycle < 1000000; ++cycle) {

        top.p_clk.set<bool>(false);
        top.step();

        uint32_t rs1 = rand() % 32;
        uint32_t rs2 = rand() % 32;
        uint32_t rd = rand() % 32;
        uint32_t rd_value = rand();

        top.p_rs1__sel.set<uint32_t>(rs1);
        top.p_rs2__sel.set<uint32_t>(rs2);
        top.p_rd__sel.set<uint32_t>(rd);
        top.p_rd__data.set<uint32_t>(rd_value);

        top.p_clk.set<bool>(true);
        top.step();

        uint32_t rs1_out = top.p_rs1__out.get<uint32_t>();
        uint32_t rs2_out = top.p_rs2__out.get<uint32_t>();

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
    }

    return EXIT_SUCCESS;
}
