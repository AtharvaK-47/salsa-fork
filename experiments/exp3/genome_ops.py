import gzip
import os
import re
import sys
from collections import Counter

if sys.argv[1] == "extract":
    import tarfile
    ids_path, archive, out = sys.argv[2:5]
    keep = {line.split()[-1] for line in open(ids_path) if line.strip()}
    found = 0
    with tarfile.open(archive, "r|gz") as tar, open(out, "w") as f:
        for m in tar:
            if not (m.isfile() and m.name.endswith((".fastq", ".fq")) and "fastq_pass" in m.name):
                continue
            lines = tar.extractfile(m).read().decode("ascii", "replace").splitlines()
            for i in range(0, len(lines) - 3, 4):
                if not lines[i].startswith("@"):
                    continue
                rid = lines[i][1:].split()[0]
                if rid in keep:
                    f.write("\n".join(lines[i:i + 4]) + "\n")
                    found += 1
    print(f"extracted {found:,} of {len(keep):,} selected reads")
    sys.exit(0)

IDS, BARCODES, PAF, BED, OUT = sys.argv[1:6]
SPAN = 1 << 15
TICK = 60.0
MIN_SHARE = 0.01

order = []
for line in open(IDS):
    p = line.split()
    if p:
        order.append((float(p[0]), p[1]) if len(p) > 1 else (None, p[0]))

bc = {}
if os.path.isdir(BARCODES):
    for root, _, files in os.walk(BARCODES):
        for name in files:
            if not name.endswith((".fastq", ".fq", ".fastq.gz", ".fq.gz")):
                continue
            path = os.path.join(root, name)
            m = re.search(r"(barcode\d+|unclassified)", os.path.relpath(path, BARCODES))
            opener = gzip.open if name.endswith(".gz") else open
            with opener(path, "rt") as f:
                for i, line in enumerate(f):
                    if i % 4:
                        continue
                    head = line[1:].split()
                    if not head:
                        continue
                    tag = next((t.split("=", 1)[1] for t in head[1:] if t.startswith("barcode=")), None)
                    b = tag or (m.group(1) if m else None)
                    if b and b != "unclassified":
                        bc[head[0]] = b
else:
    with open(BARCODES) as f:
        head = f.readline().rstrip("\n").split("\t")
        ri = head.index("read_id")
        bi = head.index("barcode_arrangement") if "barcode_arrangement" in head else head.index("barcode")
        for line in f:
            p = line.rstrip("\n").split("\t")
            if p[bi] != "unclassified":
                bc[p[ri]] = p[bi]

aln = {}
with open(PAF) as f:
    for line in f:
        p = line.split("\t")
        if "tp:A:P" not in p[12:]:
            continue
        if p[0] not in aln:
            aln[p[0]] = (int(p[7]), int(p[8]))

left, right = {}, {}
for line in open(BED):
    p = line.split("\t")
    n, side = int(p[3].split("_")[1]), p[3].split("_")[2]
    s, e = int(p[1]), int(p[2])
    if side == "LEFT":
        left[n] = max(left.get(n, 0), e)
    else:
        right[n] = min(right.get(n, 1 << 30), s)
amps = sorted(left)
insert = {n: (left[n], right[n]) for n in amps}
unique = {}
for i, n in enumerate(amps):
    s, e = insert[n]
    if i > 0: s = max(s, insert[amps[i - 1]][1])
    if i + 1 < len(amps): e = min(e, insert[amps[i + 1]][0])
    unique[n] = (s, e)

def amplicon(ts, te):
    best, ov = None, 0
    for n in amps:
        s, e = insert[n]
        o = min(te, e) - max(ts, s)
        if o > ov: best, ov = n, o
    return best

kept = [(t, r) for t, r in order if r in bc and r in aln and amplicon(*aln[r]) is not None and aln[r][1] + 1 < SPAN]
counts = Counter(bc[r] for _, r in kept)
total = sum(counts.values())
samples = [b for b, c in counts.most_common() if c >= MIN_SHARE * total]
rank = {b: i for i, b in enumerate(samples)}
kept = [(t, r) for t, r in kept if bc[r] in rank]

ops = bytearray()
def op(kind, s, key):
    global ops
    if key:
        ops += bytes((kind, s)) + key.to_bytes(2, "little")

timed = all(t is not None for t, _ in kept)
next_tick = (kept[0][0] + TICK) if timed and kept else None
ticks = 0
for t, r in kept:
    while timed and t >= next_tick:
        for s in range(len(samples)):
            for n in amps:
                us, ue = unique[n]
                op(0, s, ue)
                op(0, s, us)
        next_tick += TICK
        ticks += 1
    ts, te = aln[r]
    s = rank[bc[r]]
    if not timed:
        us, ue = unique[amplicon(ts, te)]
        op(2, s, ts + 1); op(2, s, te + 1); op(0, s, ue); op(0, s, us)
    else:
        op(2, s, ts + 1); op(2, s, te + 1)
open(OUT, "wb").write(bytes(ops))

if timed and order:
    t0 = order[0][0]
    keptset = {r for _, r in kept}
    sel, rep, why = Counter(), Counter(), {}
    for t, r in order:
        m = int((t - t0) // TICK)
        sel[m] += 1
        if r in keptset:
            rep[m] += 1
        else:
            reason = "unbarcoded" if r not in bc else "unaligned" if r not in aln else "no amplicon or rare barcode"
            why.setdefault(m, Counter())[reason] += 1
    with open("genome_rate.tsv", "w") as f:
        f.write("minute\tselected\treplayed\tunbarcoded\tunaligned\tother\n")
        for m in range(max(sel) + 1):
            w = why.get(m, Counter())
            f.write(f"{m}\t{sel[m]}\t{rep[m]}\t{w['unbarcoded']}\t{w['unaligned']}\t{w['no amplicon or rare barcode']}\n")

dropped = [f"{b} ({c})" for b, c in counts.most_common() if b not in rank]
open("genome_meta.txt", "w").write(f"{len(samples)}\n{samples[0].split('_')[-1]}\n")
print(f"reads selected {len(order):,}, barcoded {sum(r in bc for _, r in order):,}, aligned {sum(r in aln for _, r in order):,}, replayed {len(kept):,}")
print(f"samples {len(samples)} (barcodes with at least {MIN_SHARE:.0%} of reads), busiest {samples[0]} ({counts[samples[0]]:,} reads)")
if dropped: print("dropped as misassignments:", ", ".join(dropped))
print(f"query ticks {ticks} (every {TICK:g} s, {len(samples)} samples x {len(amps)} amplicons), operations {len(ops) // 4:,}")
