
#include <cstdlib>
#include <cstdint>
#include <cassert>
#include <iostream>

using namespace std;

#define FUNC_ADD 0
#define FUNC_SUB 1
#define FUNC_SHL 2
#define FUNC_SHR 3
#define FUNC_SHA 4
#define FUNC_OR  5
#define FUNC_AND 6
#define FUNC_XOR 7
#define FUNC_EQ  8
#define FUNC_NE  9
#define FUNC_LT  10
#define FUNC_GE  11
#define FUNC_LTU 12
#define FUNC_GEU 13

#include "rtl/alu.cpp"

int main() {
    cxxrtl_design::p_alu top;

    bool prev_led = 0;

    top.step();
    for (int cycle = 0; cycle < 1000000; ++cycle) {

        uint32_t in1 = rand() << (rand() % 31);
        uint32_t in2 = rand();
        if (rand() < RAND_MAX / 2) {
            in1 %= 100;
            in2 %= 100;
        }
        uint32_t func = rand() % 14;
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
        case FUNC_EQ:
            assert(out == (in1 == in2 ? 1 : 0));
            break;
        case FUNC_NE:
            assert(out == (in1 != in2 ? 1 : 0));
            break;
        case FUNC_LT:
            assert(out == ((int32_t)in1 < (int32_t)in2 ? 1 : 0));
            break;
        case FUNC_GE:
            assert(out == ((int32_t)in1 >= (int32_t)in2 ? 1 : 0));
            break;
        case FUNC_LTU:
            assert(out == (in1 < in2 ? 1 : 0));
            break;
        case FUNC_GEU:
            assert(out == (in1 >= in2 ? 1 : 0));
            break;
        default:
            break;
        }
    }

    return EXIT_SUCCESS;
}