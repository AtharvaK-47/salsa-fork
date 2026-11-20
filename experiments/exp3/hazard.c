#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <zlib.h>

#define N 65536
#define HALF 32768
#define LAG 2
#define WIN 250
#define MARK 5000

typedef struct {
  int64_t *visible;
  int64_t cyc, nops, wstart, wops;
  FILE *out, *pos;
} Pipe;

static void open_pipe(Pipe *p, size_t nodes, const char *out, const char *pos) {
  p->visible = calloc(nodes, sizeof(int64_t));
  p->cyc = -1;
  p->nops = p->wstart = p->wops = 0;
  p->out = fopen(out, "w");
  p->pos = pos ? fopen(pos, "w") : NULL;
}

static void tick(Pipe *p, int64_t ready, int64_t at) {
  if (p->pos && p->nops % MARK == 0)
    fprintf(p->pos, "%lld\n", (long long)at);
  p->cyc = ready;
  p->nops++;
  p->wops++;
  if (p->wops == WIN) {
    fprintf(p->out, "W %.6f\n", (double)WIN / (double)(p->cyc + 1 - p->wstart));
    p->wstart = p->cyc + 1;
    p->wops = 0;
  }
}

static void issue_genome(Pipe *p, int kind, unsigned sample, unsigned key,
                         int64_t at) {
  int64_t ready = p->cyc + 1, *vis = p->visible + (size_t)sample * N;
  if (kind == 0) {
    for (unsigned v = key; v; v &= v - 1) {
      if (vis[v] > ready)
        ready = vis[v];
      if (vis[v + HALF] > ready)
        ready = vis[v + HALF];
    }
  } else
    for (unsigned v = key; v && v < HALF; v += v & (~v + 1)) {
      if (vis[v] > ready)
        ready = vis[v];
      if (vis[v + HALF] > ready)
        ready = vis[v + HALF];
    }
  if (kind == 2)
    for (unsigned v = key; v && v < HALF; v += v & (~v + 1))
      vis[v] = vis[v + HALF] = ready + LAG;
  tick(p, ready, at);
}

static double finish(Pipe *p) {
  fprintf(p->out, "TOTAL ops %lld cycles %lld throughput %.4f ops/cycle\n",
          (long long)p->nops, (long long)(p->cyc + 1),
          (double)p->nops / (double)(p->cyc + 1));
  fclose(p->out);
  if (p->pos)
    fclose(p->pos);
  free(p->visible);
  return (double)(p->cyc + 1) / (double)p->nops;
}

static unsigned char *slurp(const char *path, size_t *len) {
  gzFile f = gzopen(path, "rb");
  if (!f) {
    fprintf(stderr, "cannot open %s\n", path);
    exit(1);
  }
  size_t cap = 1 << 26, n = 0;
  unsigned char *b = malloc(cap);
  int r;
  while ((r = gzread(f, b + n, (unsigned)(cap - n))) > 0) {
    n += r;
    if (n == cap)
      b = realloc(b, cap *= 2);
  }
  gzclose(f);
  *len = n;
  return b;
}

static int genome(const char *path) {
  size_t len;
  unsigned char *d = slurp(path, &len);
  size_t n = len / 4;
  unsigned samples = 0;
  for (size_t i = 0; i < n; i++)
    if (d[4 * i + 1] + 1u > samples)
      samples = d[4 * i + 1] + 1u;
  Pipe all, one;
  open_pipe(&all, (size_t)samples * N, "genome_stall.txt", NULL);
  open_pipe(&one, N, "genome_focus_stall.txt", "genome_focus_pos.txt");
  for (size_t i = 0; i < n; i++) {
    const unsigned char *r = d + 4 * i;
    unsigned kind = r[0], s = r[1], key = r[2] | (r[3] << 8);
    issue_genome(&all, kind, s, key, (int64_t)i);
    if (s == 0)
      issue_genome(&one, kind, 0, key, (int64_t)i);
  }
  long long na = all.nops, no = one.nops;
  double ca = finish(&all), co = finish(&one);
  printf("All %u samples:       %lld operations, %.4f cycles per operation\n",
         samples, na, ca);
  printf("Busiest sample alone: %lld operations, %.4f cycles per operation\n",
         no, co);
  return 0;
}

int main(int argc, char **argv) {
  return genome(argc > 1 ? argv[1] : "genome.ops");
}
