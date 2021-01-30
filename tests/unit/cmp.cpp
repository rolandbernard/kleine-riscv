#include <cstdlib>
#include <cstdint>
#include <cassert>
#include <iostream>

using namespace std;

#include "rtl/cmp.cpp"

int main() {
    cxxrtl_design::p_cmp top;

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
        bool less = rand() < RAND_MAX / 2;
        bool sign = rand() < RAND_MAX / 2;
        bool negate = rand() < RAND_MAX / 2;
        top.p_in1.set<uint32_t>(in1);
        top.p_in2.set<uint32_t>(in2);

        top.p_less.set<bool>(less);
        top.p_sign.set<bool>(sign);
        top.p_negate.set<bool>(negate);

        top.step();

        bool out = top.p_out.get<bool>();

        bool expected;
        switch ((less << 2) | (sign << 1) | (negate)) {
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
            assert(out == (in1 < in2));
            break;
        case 0b101:
            assert(out == !(in1 < in2));
            break;
        case 0b110:
            assert(out == ((int32_t)in1 < (int32_t)in2));
            break;
        case 0b111:
            assert(out == !((int32_t)in1 < (int32_t)in2));
            break;
        default:
            break;
        }
    }

    return EXIT_SUCCESS;
}