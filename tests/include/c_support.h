
typedef unsigned long long uditype;

uditype __muldi3(uditype a, uditype b) {
    if (b == 0 || a == 0) {
        return 0;
    } else {
        uditype ret = 0;
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

