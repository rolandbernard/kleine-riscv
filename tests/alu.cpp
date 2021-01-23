
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
    for (int cycle = 0; cycle < 100; ++cycle) {

        uint32_t in1 = rand();
        uint32_t in2 = rand();
        uint32_t func = rand() % 14;

        top.p_in1.set<unsigned>(in1);
        top.p_in2.set<unsigned>(in2);
        top.p_func.set<unsigned>(func);

        top.step();
        
        cout << top.p_out.get<unsigned>() << endl;

    }

    return EXIT_SUCCESS;
}