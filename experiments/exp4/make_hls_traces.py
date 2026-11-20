import gzip
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ITCH = os.environ.get("ITCH_OPS", os.path.join(HERE, "..", "exp2", "runs", "itch_ops.bin.gz"))
GENOME = os.environ.get("GENOME_OPS", os.path.join(HERE, "..", "exp3", "runs", "genome.ops"))
NOPS = int(os.environ.get("NOPS", "100000"))
OUT = os.path.join(HERE, "traces")

def rec(key, kind, val):
    return struct.pack("<HBxi", key, kind, val)

def itch():
    raw = gzip.open(ITCH, "rb").read() if ITCH.endswith(".gz") else open(ITCH, "rb").read()
    assert raw[:8] == b"SALSAOPS", "not an itch_ops stream"
    n, ml = struct.unpack_from("<QI", raw, 12)
    o = 24 + ml
    ops, keys, vals = raw[o:o + n], o + n, o + 3 * n
    vol = [[0] * 4096 for _ in range(16)]
    best = [0] * 16
    out = bytearray()
    count = 0
    for i in range(n):
        if count >= NOPS:
            break
        if ops[i] != 2:
            continue
        key = struct.unpack_from("<H", raw, keys + 2 * i)[0]
        d = struct.unpack_from("<i", raw, vals + 4 * i)[0]
        a, l = key >> 12, key & 4095
        vol[a][l] += d
        b = best[a]
        if vol[a][l] > 0 and (b == 0 or (l < b if a & 1 else l > b)):
            best[a] = l
        elif l == b and vol[a][l] <= 0:
            rng = range(1, 4096) if a & 1 else range(4095, 0, -1)
            best[a] = next((x for x in rng if vol[a][x] > 0), 0)
        qk = a * 4096 + best[a] if best[a] else key
        out += rec(key, 2, d)
        out += rec(qk, 0, 0)
        count += 2
    return out[:8 * NOPS]

def genome():
    raw = open(GENOME, "rb").read()
    out = bytearray()
    parity = 0
    for i in range(0, len(raw) - 3, 4):
        kind, s, key = raw[i], raw[i + 1], raw[i + 2] | (raw[i + 3] << 8)
        if s != 0:
            continue
        if kind == 2:
            out += rec(key, 2, 1 if parity == 0 else -1)
            parity ^= 1
        else:
            out += rec(key, 0, 0)
        if len(out) >= 8 * NOPS:
            break
    return out

os.makedirs(OUT, exist_ok=True)
for name, fn, src in (("itch", itch, ITCH), ("genome", genome, GENOME)):
    if not os.path.exists(src):
        print(f"skipping {name}: {src} not found", file=sys.stderr)
        continue
    data = fn()
    open(os.path.join(OUT, f"{name}.bin"), "wb").write(data)
    print(f"{name}: {len(data) // 8:,} operations -> traces/{name}.bin")
