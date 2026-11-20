#ifndef FENWICK_H
#define FENWICK_H

#include <stdint.h>

#define LOGN 16
#define N (1 << LOGN)
#define MAXOPS 100000

#ifndef VARIANT
#define VARIANT 0
#endif

void fenwick_top(const uint16_t keys[MAXOPS], const uint8_t kinds[MAXOPS], const int32_t vals[MAXOPS],
                 int32_t res[MAXOPS], int n);

#endif
