import glob
import os
import re
import xml.etree.ElementTree as ET

HERE = os.path.dirname(os.path.abspath(__file__))
NAMES = ["plain", "cyclic16", "block16", "cyclic16_depfalse"]
WORKLOADS = ["itch", "genome"]

def first(pattern):
    hits = sorted(glob.glob(pattern, recursive=True))
    return hits[0] if hits else None

def synth(sol):
    x = first(os.path.join(sol, "syn", "report", "csynth.xml"))
    if not x:
        return {}
    root = ET.parse(x).getroot()
    out = {}
    clk = root.find(".//EstimatedClockPeriod")
    if clk is not None:
        out["clock_ns"] = float(clk.text)
    for loop in root.iter():
        if loop.tag.lower().startswith("ops") or loop.attrib.get("name", "").lower().startswith("ops"):
            ii = loop.find(".//PipelineII")
            if ii is not None and ii.text and ii.text.strip().isdigit():
                out["ii"] = int(ii.text)
                break
    for tag in ("BRAM_18K", "URAM", "DSP", "FF", "LUT"):
        e = root.find(f".//AreaEstimates/Resources/{tag}")
        if e is not None:
            out[tag.lower()] = e.text
    if "ii" not in out:
        rpt = first(os.path.join(sol, "syn", "report", "*csynth.rpt"))
        if rpt:
            for line in open(rpt):
                if re.search(r"\bops\b", line) and "|" in line:
                    cells = [c.strip() for c in line.split("|")]
                    nums = [c for c in cells if c.isdigit()]
                    if len(nums) >= 3:
                        out["ii_rpt_row"] = " ".join(cells)
    return out

def cosim(sol):
    rpt = first(os.path.join(sol, "sim", "report", "*cosim.rpt"))
    if not rpt:
        return {}
    for line in open(rpt):
        if "Verilog" in line or "VHDL" in line:
            nums = [c.strip() for c in line.split("|") if c.strip()]
            vals = [int(c) for c in nums if c.isdigit()]
            if vals:
                return {"status": nums[1] if len(nums) > 1 else "", "latency": vals[1] if len(vals) > 2 else vals[0]}
    return {}

def tb(sol, where):
    f = first(os.path.join(sol, where, "**", "tb_result.txt"))
    if not f:
        return None
    m = re.search(r"ops=(\d+).*mismatches=(\d+)", open(f).read())
    return (int(m.group(1)), int(m.group(2))) if m else None

rows = []
for name in NAMES:
    for w in WORKLOADS:
        sol = os.path.join(HERE, "proj", f"{name}_{w}", "sol")
        if not os.path.isdir(sol):
            continue
        s, c = synth(sol), cosim(sol)
        cs, co = tb(sol, "csim"), tb(sol, "sim")
        ops = (co or cs or (0, 0))[0]
        cpo = c["latency"] / ops if c.get("latency") and ops else None
        rows.append(dict(variant=name, workload=w, ii=s.get("ii", "?"), clock_ns=s.get("clock_ns", "?"),
                         ops=ops, cosim_cycles=c.get("latency", "?"),
                         cycles_per_op=f"{cpo:.3f}" if cpo else "?",
                         csim_mismatches=cs[1] if cs else "?", cosim_mismatches=co[1] if co else "?",
                         bram18k=s.get("bram_18k", "?"), lut=s.get("lut", "?"), ff=s.get("ff", "?")))

cols = ["variant", "workload", "ii", "clock_ns", "ops", "cosim_cycles", "cycles_per_op",
        "csim_mismatches", "cosim_mismatches", "bram18k", "lut", "ff"]
with open(os.path.join(HERE, "results.csv"), "w") as f:
    f.write(",".join(cols) + "\n")
    for r in rows:
        f.write(",".join(str(r[c]) for c in cols) + "\n")
width = [max(len(c), *(len(str(r[c])) for r in rows)) for c in cols] if rows else [len(c) for c in cols]
print("  ".join(c.ljust(w) for c, w in zip(cols, width)))
for r in rows:
    print("  ".join(str(r[c]).ljust(w) for c, w in zip(cols, width)))
print("wrote results.csv")
