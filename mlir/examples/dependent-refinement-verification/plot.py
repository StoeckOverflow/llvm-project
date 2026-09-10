#!/usr/bin/env python3
import argparse
import csv
from pathlib import Path

import matplotlib.pyplot as plt


COLORS = {"baseline_memref": "#666666", "memref": "#16805b"}
MARKERS = {"baseline_memref": "o", "memref": "s"}
LABELS = {"baseline_memref": "MLIR", "memref": "MLIR with value-dependent types"}


def read_rows(path: Path):
    with path.open(newline="") as f:
        rows = list(csv.DictReader(f))
    for row in rows:
        for key, value in list(row.items()):
            if key == "route" or value == "":
                continue
            try:
                row[key] = float(value)
            except ValueError:
                pass
    return rows


def plot(rows, x_key, y_key, ylabel, out: Path, stem: str):
    fig, ax = plt.subplots(figsize=(6.2, 3.8))
    for route in ["baseline_memref", "memref"]:
        subset = sorted([r for r in rows if r["route"] == route], key=lambda r: r[x_key])
        if not subset:
            continue
        ax.plot(
            [r[x_key] for r in subset],
            [r[y_key] for r in subset],
            marker=MARKERS[route],
            markersize=5,
            linewidth=1.6,
            color=COLORS[route],
            label=LABELS.get(route, route),
        )
    labels = {
        "rank": "contraction rank",
        "contraction_rank": "contraction rank",
        "max_carrier_rank": "program size [#tensor dimensions]",
        "logical_dim_refs": "logical dimension references",
        "refinement_value_refs": "refinement value references",
        "lines": "generated MLIR lines",
    }
    ax.set_xlabel(labels.get(x_key, x_key))
    ax.set_ylabel(ylabel)
    ax.grid(True, axis="y", alpha=0.28)
    ax.legend(frameon=False)
    fig.tight_layout()
    out.mkdir(parents=True, exist_ok=True)
    fig.savefig(out / f"{stem}.pdf")
    fig.savefig(out / f"{stem}.png", dpi=180)
    plt.close(fig)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", type=Path, required=True)
    ap.add_argument("--out", type=Path, required=True)
    args = ap.parse_args()
    rows = read_rows(args.input)
    rank_key = "max_carrier_rank" if "max_carrier_rank" in rows[0] else "rank"
    plot(rows, rank_key, "median_total_ms",
         "median MLIR lowering compile time [ms]", args.out,
         "mlir-lowering-compile-time-vs-dimensions")


if __name__ == "__main__":
    main()
