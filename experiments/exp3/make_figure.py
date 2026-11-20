import os
import numpy as np

G, WIN = 40, 250
YMIN, YMAX = 0.95, 1.8
HERE = os.path.dirname(os.path.abspath(__file__))
ITCH = os.environ.get("ITCH_RUNS", os.path.join(HERE, "..", "exp2", "runs"))
ZOOM = os.environ.get("ZOOM", "8.2,8.7")
WORDS = "zero one two three four five six seven eight nine ten eleven twelve".split()

def curve(stall, pos=None):
    w = np.array([1.0 / float(l.split()[1]) for l in open(stall) if l.startswith("W ")])
    rows = []
    for g in range(len(w) // G):
        c = w[g * G:(g + 1) * G]
        rows.append([(g + 0.5) * G * WIN / 1e6, np.median(c), np.percentile(c, 10), np.percentile(c, 90)])
    d = np.array(rows)
    if pos is not None:
        p = np.loadtxt(pos, dtype=np.int64, ndmin=1)
        d[:, 0] = p[np.minimum(2 * np.arange(len(d)) + 1, len(p) - 1)] / 1e6
    return d

def clip(d, a, b):
    out = [r for r in d if a <= r[0] <= b]
    for edge in (a, b):
        j = np.searchsorted(d[:, 0], edge)
        if 0 < j < len(d):
            f = (edge - d[j - 1, 0]) / (d[j, 0] - d[j - 1, 0])
            out.append(d[j - 1] + f * (d[j] - d[j - 1]))
    out = np.array(out)
    return out[np.argsort(out[:, 0])]

def table(d):
    return "x med lo hi\n" + "\n".join(f"{x:.4f} {m:.4f} {l:.4f} {h:.4f}" for x, m, l, h in d) + "\n}"

def series(d, tag, band, line):
    return (f"  \\addplot[draw=none, name path={tag}lo, forget plot] table[x=x, y=lo]{{\n{table(d)};\n"
            f"  \\addplot[draw=none, name path={tag}hi, forget plot] table[x=x, y=hi]{{\n{table(d)};\n"
            f"  \\addplot[{band}, fill opacity=0.35, draw=none, forget plot] fill between[of={tag}lo and {tag}hi];\n"
            f"  \\addplot[{line}, forget plot] table[x=x, y=med]{{\n{table(d)};\n")

def ref(a, b):
    return f"  \\draw[black!60, line width=0.6pt, loosely dashed] (axis cs:{a:g},1) -- (axis cs:{b:g},1);\n"

STYLE = r"""scale only axis, height=0.205\textwidth, axis lines=box, axis line style={black, line width=0.5pt}, tick align=inside, tick style={black!70},
  grid=both, minor y tick num=1,
  major grid style={black!40, dotted, line width=0.5pt}, minor grid style={black!18, dotted, line width=0.4pt},
  tick label style={font=\scriptsize}, label style={font=\footnotesize}, title style={font=\footnotesize},
  scaled x ticks=false, xticklabel style={/pgf/number format/fixed},
  ymin=""" + f"{YMIN}, ymax={YMAX}" + r""", ytick={1.0,1.2,1.4,1.6,1.8},
  legend style={font=\scriptsize, draw=black!60, fill=white, fill opacity=0.9, text opacity=1, legend cell align=left,
    at={(0.98,0.97)}, anchor=north east, legend columns=2, column sep=4pt}"""
SOLID, DASH = "black, line width=1.0pt", "black!60, line width=1.0pt, densely dashed"
BAND_A, BAND_F = "fill=black!18", "fill=black!10"

ns = int(open("genome_meta.txt").read().split()[0])
nw = WORDS[ns] if ns < len(WORDS) else str(ns)
GA = curve("genome_stall.txt")
GF = curve("genome_focus_stall.txt", "genome_focus_pos.txt")
gmax = np.ceil(max(GA[-1, 0], GF[-1, 0]) * 5) / 5
z0, z1 = (float(v) for v in ZOOM.split(","))
xend = max(GA[-1, 0], GF[-1, 0])
if not (0 <= z0 < z1 <= xend):
    z0, z1 = round(0.6 * xend, 3), round(0.9 * xend, 3)
    print(f"zoom window outside the data; using {z0:g}-{z1:g} M instead")

itch = all(os.path.exists(os.path.join(ITCH, f)) for f in ("itch_stall_l2.txt", "itch_qqq_stall.txt", "itch_qqq_pos.txt"))
parts = []
if itch:
    IA = curve(os.path.join(ITCH, "itch_stall_l2.txt"))
    IQ = curve(os.path.join(ITCH, "itch_qqq_stall.txt"), os.path.join(ITCH, "itch_qqq_pos.txt"))
    imax = np.ceil(max(IA[-1, 0], IQ[-1, 0]) * 4) / 4
    parts.append(r"""\begin{tikzpicture}
\begin{axis}[width=0.27\textwidth, """ + STYLE + r""", minor x tick num=1,
  xmin=0, xmax=""" + f"{imax:g}" + r""", xlabel={Operations (Millions)}, ylabel={Cycles per Operation}, ylabel style={yshift=-2pt},
  title={(a) NASDAQ ITCH order flow}]
""" + ref(0, imax) + series(IA, "ia", BAND_A, SOLID) + series(IQ, "iq", BAND_F, DASH) + r"""  \addlegendimage{""" + SOLID + r"""}\addlegendentry{All 8 symbols}
  \addlegendimage{""" + DASH + r"""}\addlegendentry{QQQ}
\end{axis}
\end{tikzpicture}\hspace{0.035\textwidth}%
""")
lb = "b" if itch else "a"
lc = "c" if itch else "b"
ylab = "yticklabels={}" if itch else r"ylabel={Cycles per Operation}, ylabel style={yshift=-2pt}"
parts.append(r"""\begin{tikzpicture}
\begin{axis}[name=gb, width=""" + ("0.43" if itch else "0.6") + r"""\textwidth, """ + STYLE + r""", minor x tick num=1, """ + ylab + r""",
  xmin=0, xmax=""" + f"{gmax:g}" + r""", xlabel={Operations (Millions)}, title={(""" + lb + r""") Genome coverage}, legend style={at={(0.02,0.97)}, anchor=north west}]
""" + ref(0, gmax) + series(GA, "ga", BAND_A, SOLID) + series(GF, "gf", BAND_F, DASH) + r"""  \addlegendimage{""" + SOLID + r"""}\addlegendentry{All """ + f"{ns}" + r""" samples}
  \addlegendimage{""" + DASH + r"""}\addlegendentry{Busiest sample}
  \draw[black, line width=0.8pt] (axis cs:""" + f"{z0:g},{YMIN}) rectangle (axis cs:{z1:g},1.6);" + r"""
  \coordinate (gbr) at (rel axis cs:1,0);
  \node[font=\scriptsize, fill=white, inner sep=1pt, anchor=south] at (axis cs:""" + f"{(z0 + z1) / 2:g},1.6) {{({lc})}};" + r"""
\end{axis}
\coordinate (gcpos) at ([xshift=0.016\textwidth]gbr);
\begin{axis}[name=gc, at={(gcpos)}, anchor=south west, width=""" + ("0.15" if itch else "0.22") + r"""\textwidth, """ + STYLE + r""", yticklabels={},
  xmin=""" + f"{z0:g}, xmax={z1:g}, xtick={{{z0:g},{(z0 + z1) / 2:g},{z1:g}}}" + r""", minor x tick num=1,
  xlabel={Operations (Millions)}, title={(""" + lc + r""") Burst in (""" + lb + r""")}]
""" + ref(z0, z1) + series(clip(GA, z0, z1), "za", BAND_A, SOLID) + series(clip(GF, z0, z1), "zf", BAND_F, DASH) + r"""\end{axis}
\end{tikzpicture}
""")

if itch:
    panels = "(a)~NASDAQ ITCH order flow, (b)~genome coverage, and (c)~the burst boxed in (b), magnified"
else:
    panels = "(a)~genome coverage, and (b)~the burst boxed in (a), magnified"
cap = ("Cycles per operation (CPO) of a pipeline that stalls on read-after-write hazards, on " + panels + ". "
       f"Lines are medians over groups of {G * WIN:,} operations, and grey bands span their 10th to 90th percentiles; "
       "the grey line at 1 marks one cycle per operation, the CPO without stalls. All panels share one vertical scale.")

tex = ("\\usepgfplotslibrary{fillbetween}\n\\begin{figure*}[!t]\n\\centering\n" + "".join(parts) + "\\caption{" + cap + "}\n\\label{fig:rw_throughput}\n\\end{figure*}\n")
open("rw_hazards_fig.tex", "w").write(tex)
print("wrote rw_hazards_fig.tex" + ("" if itch else f" (genome panels only: no ITCH results in {ITCH})"))
