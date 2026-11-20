#include <cstdio>
#include <cstdlib>
#include <vector>
#include "fenwick.h"

static uint16_t keys[MAXOPS];
static uint8_t kinds[MAXOPS];
static int32_t vals[MAXOPS];
static int32_t res[MAXOPS];

int main(int argc, char **argv) {
    const char *path = argc > 1 ? argv[1] : "trace.bin";
    FILE *f = fopen(path, "rb");
    if (!f) { printf("cannot open %s\n", path); return 1; }
    int n = 0;
    unsigned char r[8];
    while (n < MAXOPS && fread(r, 1, 8, f) == 8) {
        keys[n] = (uint16_t)(r[0] | (r[1] << 8));
        kinds[n] = r[2];
        vals[n] = (int32_t)(r[4] | (r[5] << 8) | (r[6] << 16) | ((uint32_t)r[7] << 24));
        n++;
    }
    fclose(f);

    fenwick_top(keys, kinds, vals, res, n);

    std::vector<int32_t> t(N, 0);
    long bad = 0, queries = 0;
    for (int i = 0; i < n; i++) {
        uint32_t v = keys[i];
        int32_t want;
        if (kinds[i] == 2) {
            for (; v != 0 && v < N; v += v & (~v + 1)) t[v] += vals[i];
            want = vals[i];
        } else {
            int32_t acc = 0;
            for (; v != 0; v &= v - 1) acc += t[v];
            want = acc;
            queries++;
        }
        if (res[i] != want) bad++;
    }
    printf("RESULT variant=%d ops=%d queries=%ld mismatches=%ld\n", VARIANT, n, queries, bad);
    FILE *o = fopen("tb_result.txt", "w");
    if (o) { fprintf(o, "variant=%d ops=%d queries=%ld mismatches=%ld\n", VARIANT, n, queries, bad); fclose(o); }
    return 0;
}
