
#include <cstdlib>
#include <cstdint>
#include <cassert>
#include <iostream>

using namespace std;

#define FUNC_SHIFT_LEFT 0
#define FUNC_SHIFT_RIGHT 1
#define FUNC_SHIFT_ARITH 2
#define FUNC_ADD 3
#define FUNC_SUB 4
#define FUNC_OR 5
#define FUNC_AND 6
#define FUNC_XOR 7
#define FUNC_CMP_EQ 8
#define FUNC_CMP_NE 9
#define FUNC_CMP_GT 10
#define FUNC_CMP_GE 11
#define FUNC_CMP_LT 12
#define FUNC_CMP_LE 13

#include "rtl/alu.cpp"

int main() {
    cxxrtl_design::p_alu top;

    bool prev_led = 0;

    top.step();
    for (int cycle = 0; cycle < 1000000; ++cycle) {

        uint32_t in1 = rand();
        uint32_t in2 = rand();
        uint32_t func = rand() % 14;
        if (func == FUNC_SHIFT_LEFT || func == FUNC_SHIFT_RIGHT || func == FUNC_SHIFT_ARITH) {
            in2 %= 32;
        }
        top.p_in1.set<uint32_t>(in1);
        top.p_in2.set<uint32_t>(in2);
        top.p_func.set<uint32_t>(func);

        top.step();

        uint32_t out = top.p_out.get<uint32_t>();

        switch (func) {
        case FUNC_SHIFT_LEFT:
            assert(out == (in1 << in2));
            break;
        case FUNC_SHIFT_RIGHT:
            assert(out == (in1 >> in2));
            break;
        case FUNC_SHIFT_ARITH:
            assert(out == (uint32_t)((int32_t)in1 >> in2));
            break;
        case FUNC_ADD:
            assert(out == (in1 + in2));
            break;
        case FUNC_SUB:
            assert(out == (in1 - in2));
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
        case FUNC_CMP_EQ:
            assert(out == (in1 == in2 ? 1 : 0));
            break;
        case FUNC_CMP_NE:
            assert(out == (in1 != in2 ? 1 : 0));
            break;
        case FUNC_CMP_GT:
            assert(out == (in1 > in2 ? 1 : 0));
            break;
        case FUNC_CMP_GE:
            assert(out == (in1 >= in2 ? 1 : 0));
            break;
        case FUNC_CMP_LT:
            assert(out == (in1 < in2 ? 1 : 0));
            break;
        case FUNC_CMP_LE:
            assert(out == (in1 <= in2 ? 1 : 0));
            break;
        default:
            break;
        }
    }

    return EXIT_SUCCESS;
}