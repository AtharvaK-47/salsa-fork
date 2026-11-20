#include "fenwick.h"

void fenwick_top(const uint16_t keys[MAXOPS], const uint8_t kinds[MAXOPS], const int32_t vals[MAXOPS],
                 int32_t res[MAXOPS], int n) {
    static int32_t tree[N];
#if VARIANT == 1 || VARIANT == 3
#pragma HLS ARRAY_PARTITION variable=tree type=cyclic factor=16 dim=1
#elif VARIANT == 2
#pragma HLS ARRAY_PARTITION variable=tree type=block factor=16 dim=1
#endif
#if VARIANT == 3
#pragma HLS DEPENDENCE variable=tree type=inter dependent=false
#endif

ops:
    for (int i = 0; i < n; i++) {
#pragma HLS PIPELINE II=1
#pragma HLS LOOP_TRIPCOUNT min=1 max=100000
        uint32_t v = keys[i];
        int32_t d = vals[i];
        int32_t acc = 0;
        if (kinds[i] == 2) {
        up:
            for (int l = 0; l <= LOGN; l++) {
#pragma HLS UNROLL
                if (v != 0 && v < N) {
                    tree[v] += d;
                    v += v & (~v + 1);
                }
            }
            res[i] = d;
        } else {
        down:
            for (int l = 0; l <= LOGN; l++) {
#pragma HLS UNROLL
                if (v != 0) {
                    acc += tree[v];
                    v &= v - 1;
                }
            }
            res[i] = acc;
        }
    }
}
