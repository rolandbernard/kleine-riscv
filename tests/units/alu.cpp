
#include <cstdlib>
#include <cstdint>
#include <cassert>
#include <iostream>

using namespace std;

#define ALU_ADD_SUB 0b000
#define ALU_SLL     0b001
#define ALU_SLT     0b010
#define ALU_SLTU    0b011
#define ALU_XOR     0b100
#define ALU_SRL_SRA 0b101
#define ALU_OR      0b110
#define ALU_AND_CLR 0b111

#include "rtl/alu.cpp"

int main() {
    cxxrtl_design::p_alu top;

    bool prev_led = 0;

    top.step();
    for (int cycle = 0; cycle < 1000000; ++cycle) {

        uint32_t in1 = rand();
        uint32_t in2 = rand();
        if (rand() < RAND_MAX / 2) {
            in1 %= 100;
            in2 %= 100;
        } else {
            in1 <<= rand() % 16;
            in2 <<= rand() % 16;
        }
        uint32_t func = rand() & 0b111;
        uint32_t func_sel = rand() & 0b1;
        if (func == ALU_SLL || func == ALU_SRL_SRA) {
            in2 %= 32;
        }
        top.p_input__a.set<uint32_t>(in1);
        top.p_input__b.set<uint32_t>(in2);
        top.p_function__select.set<uint32_t>(func);
        top.p_function__modifier.set<uint32_t>(func_sel);

        top.step();

        uint32_t out = top.p_result.get<uint32_t>();
        
        switch (func) {
        case ALU_ADD_SUB:
            if (func_sel) {
                assert(out == (in1 - in2));
            } else {
                assert(out == (in1 + in2));
            }
            break;
        case ALU_SLL:
            assert(out == (in1 << in2));
            break;
        case ALU_SLT:
            assert(out == ((int32_t)in1 < (int32_t)in2 ? 1 : 0));
            break;
        case ALU_SLTU:
            assert(out == (in1 < in2 ? 1 : 0));
            break;
        case ALU_XOR:
            assert(out == (in1 ^ in2));
            break;
        case ALU_SRL_SRA:
            if (func_sel) {
                assert(out == (uint32_t)((int32_t)in1 >> in2));
            } else {
                assert(out == (in1 >> in2));
            }
            break;
        case ALU_OR:
            assert(out == (in1 | in2));
            break;
        case ALU_AND_CLR:
            if (func_sel) {
                assert(out == ((~in1) & in2));
            } else {
                assert(out == (in1 & in2));
            }
            break;
        default:
            break;
        }
    }

    return EXIT_SUCCESS;
}