#!/usr/bin/env python3
import argparse
import csv
import re
import statistics
import subprocess
from pathlib import Path


TIMING_RE = re.compile(r"^\s*([0-9.]+) \(\s*[0-9.]+%\)\s+(.+?)\s*$")
TOTAL_RE = re.compile(r"Total Execution Time:\s+([0-9.]+) seconds")
PASS_NAMES = {
    "tensor": "VerifyDependentTensorRefinementsPass",
    "memref": "VerifyDependentMemRefRefinementsPass",
}


def repo_root() -> Path:
    return Path(__file__).resolve().parents[3]


def parse_timing(report: str, pass_name: str):
    times = {}
    total = None
    for line in report.splitlines():
        m = TOTAL_RE.search(line)
        if m:
            total = float(m.group(1)) * 1000.0
            continue
        m = TIMING_RE.match(line)
        if not m:
            continue
        seconds = float(m.group(1))
        name = m.group(2).strip()
        times[name] = seconds * 1000.0
    return {
        "total_ms": total if total is not None else times.get("Total", 0.0),
        "parser_ms": times.get("Parser", 0.0),
        "output_ms": times.get("Output", 0.0),
        "pass_ms": times.get(pass_name, 0.0),
        "rest_ms": times.get("Rest", 0.0),
    }


def read_manifest(path: Path):
    with path.open(newline="") as f:
        rows = list(csv.DictReader(f))
    integer_columns = [
        "contraction_rank",
        "rank",
        "a_rank",
        "b_rank",
        "c_rank",
        "max_carrier_rank",
        "kernels",
        "lines",
        "refinement_sites",
        "logical_dim_refs",
        "refinement_value_refs",
    ]
    for row in rows:
        for column in integer_columns:
            if column in row:
                row[column] = int(row[column])
        row["path"] = str(Path(row["path"]))
    return rows


def run_one(mlir_opt: Path, row, repetition: int, out: Path):
    route = row["route"]
    pass_name = PASS_NAMES[route]
    input_path = Path(row["path"])
    timing_path = out / "timing" / f"{route}-rank-{row['rank']}-rep-{repetition}.txt"
    verified_path = out / "verified" / f"{route}-rank-{row['rank']}-rep-{repetition}.mlir"
    timing_path.parent.mkdir(parents=True, exist_ok=True)
    verified_path.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        str(mlir_opt),
        str(input_path),
        f"-{pass_name.replace('VerifyDependentTensorRefinementsPass', 'verify-dependent-tensor-refinements').replace('VerifyDependentMemRefRefinementsPass', 'verify-dependent-memref-refinements')}",
        "-mlir-disable-threading",
        "-mlir-timing",
        "-mlir-timing-display=list",
        "-o",
        str(verified_path),
    ]
    proc = subprocess.run(cmd, cwd=repo_root(), text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    timing_path.write_text(proc.stdout)
    if proc.returncode != 0:
        raise RuntimeError(f"mlir-opt failed for {input_path}:\n{proc.stdout}")
    metrics = parse_timing(proc.stdout, pass_name)
    return {
        **row,
        "repetition": repetition,
        **{k: f"{v:.6f}" for k, v in metrics.items()},
        "timing_path": str(timing_path),
        "verified_path": str(verified_path),
    }


def write_summary(rows, out: Path):
    grouped = {}
    for row in rows:
        key = (row["route"], row["rank"])
        grouped.setdefault(key, []).append(row)
    summary = []
    for (route, rank), group in sorted(grouped.items()):
        pass_values = [float(r["pass_ms"]) for r in group]
        total_values = [float(r["total_ms"]) for r in group]
        base = group[0]
        summary.append({
            "route": route,
            "contraction_rank": base.get("contraction_rank", rank),
            "rank": rank,
            "a_rank": base.get("a_rank", ""),
            "b_rank": base.get("b_rank", ""),
            "c_rank": base.get("c_rank", ""),
            "max_carrier_rank": base.get("max_carrier_rank", ""),
            "kernels": base["kernels"],
            "lines": base["lines"],
            "refinement_sites": base.get("refinement_sites", base.get("refinements", "")),
            "logical_dim_refs": base["logical_dim_refs"],
            "refinement_value_refs": base.get("refinement_value_refs", base["logical_dim_refs"]),
            "repetitions": len(group),
            "median_pass_ms": f"{statistics.median(pass_values):.6f}",
            "mean_pass_ms": f"{statistics.mean(pass_values):.6f}",
            "median_total_ms": f"{statistics.median(total_values):.6f}",
            "mean_total_ms": f"{statistics.mean(total_values):.6f}",
        })
    path = out / "summary.csv"
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=summary[0].keys())
        writer.writeheader()
        writer.writerows(summary)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--generated", type=Path, default=Path("artifacts/generated"))
    ap.add_argument("--out", type=Path, default=Path("artifacts/runs/latest"))
    ap.add_argument("--mlir-opt", type=Path, default=repo_root() / "build/bin/mlir-opt")
    ap.add_argument("--repetitions", type=int, default=10)
    args = ap.parse_args()

    manifest = args.generated / "manifest.csv"
    rows = read_manifest(manifest)
    args.out.mkdir(parents=True, exist_ok=True)
    all_rows = []
    for row in rows:
        for rep in range(args.repetitions):
            print(f"{row['route']} contraction_rank={row.get('contraction_rank', row['rank'])} repetition={rep + 1}/{args.repetitions}")
            all_rows.append(run_one(args.mlir_opt, row, rep, args.out))
    results_path = args.out / "results.csv"
    with results_path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=all_rows[0].keys())
        writer.writeheader()
        writer.writerows(all_rows)
    write_summary(all_rows, args.out)
    print(f"wrote {results_path}")


if __name__ == "__main__":
    main()
