#include <cstdlib>
#include <cstdint>
#include <cassert>
#include <iostream>

using namespace std;

#include "Vcmp.h"

int main() {
    Vcmp top;

    bool prev_led = 0;

    top.eval();
    for (int cycle = 0; cycle < 10000000; ++cycle) {

        uint32_t in1 = rand();
        uint32_t in2 = rand();
        if (rand() < RAND_MAX / 2) {
            in1 %= 100;
            in2 %= 100;
        } else {
            in1 <<= rand() % 16;
            in2 <<= rand() % 16;
        }
        bool less = rand() < RAND_MAX / 2;
        bool usign = rand() < RAND_MAX / 2;
        bool negate = rand() < RAND_MAX / 2;
        top.input_a = in1;
        top.input_b = in2;

        top.function_select = (less << 2) | (usign << 1) | (negate);

        top.eval();

        bool out = top.result;

        bool expected;
        switch ((less << 2) | (usign << 1) | (negate)) {
        case 0b000:
            assert(out == (in1 == in2));
            break;
        case 0b001:
            assert(out == !(in1 == in2));
            break;
        case 0b010:
            assert(out == ((int32_t)in1 == (int32_t)in2));
            break;
        case 0b011:
            assert(out == !((int32_t)in1 == (int32_t)in2));
            break;
        case 0b100:
            assert(out == ((int32_t)in1 < (int32_t)in2));
            break;
        case 0b101:
            assert(out == !((int32_t)in1 < (int32_t)in2));
            break;
        case 0b110:
            assert(out == (in1 < in2));
            break;
        case 0b111:
            assert(out == !(in1 < in2));
            break;
        default:
            break;
        }
    }

    return EXIT_SUCCESS;
}
