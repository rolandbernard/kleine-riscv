
#include <cstdlib>
#include <cstdint>
#include <cassert>
#include <iostream>

using namespace std;

#define FUNC_ADD 0b000
#define FUNC_SUB 0b001
#define FUNC_SHR 0b010
#define FUNC_SHA 0b011
#define FUNC_SHL 0b100
#define FUNC_AND 0b101
#define FUNC_OR  0b110
#define FUNC_XOR 0b111

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
        if (func == FUNC_SHL || func == FUNC_SHR || func == FUNC_SHA) {
            in2 %= 32;
        }
        top.p_in1.set<uint32_t>(in1);
        top.p_in2.set<uint32_t>(in2);
        top.p_func.set<uint32_t>(func);

        top.step();

        uint32_t out = top.p_out.get<uint32_t>();
        
        switch (func) {
        case FUNC_ADD:
            assert(out == (in1 + in2));
            break;
        case FUNC_SUB:
            assert(out == (in1 - in2));
            break;
        case FUNC_SHL:
            assert(out == (in1 << in2));
            break;
        case FUNC_SHR:
            assert(out == (in1 >> in2));
            break;
        case FUNC_SHA:
            assert(out == (uint32_t)((int32_t)in1 >> in2));
            break;
        case FUNC_OR:
            assert(out == (in1 | in2));
            break;
        case FUNC_AND:
            assert(out == (in1 & in2));
            break;
        case FUNC_XOR:
            assert(out == (in1 ^ in2));
            break;
        default:
            break;
        }
    }

    return EXIT_SUCCESS;
}