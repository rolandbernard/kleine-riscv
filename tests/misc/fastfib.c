
#include "c_test.h"

long long iterative(int n) {
    long long a = 0;
    long long b = 1;
    for (int i = 0; i < n; i++) {
        long long t = a;
        a = b;
        b = t + b;
    }
    return a;
}

void main() {
    ASSERT(2, iterative(75) == 2111485077978050LL);
}

