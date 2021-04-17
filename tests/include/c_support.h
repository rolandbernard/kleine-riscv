
long long __muldi3(long long a, long long b) {
    if (a < 0) {
        return -((-a) * b);
    } else if (b == 0 || a == 0) {
        return 0;
    } else {
        long long ret = 0;
        while (b > 1) {
            if (b % 2 == 1) {
                ret += a;
            }
            a *= 2;
            b /= 2;
        }
        return ret + a;
    }
}

