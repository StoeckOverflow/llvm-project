#!/usr/bin/env python3
import argparse
import csv
import json
import os
import random
import re
import shlex
import statistics
import subprocess
import tempfile
import time
from pathlib import Path


TIMING_RE = re.compile(r"^\s*([0-9.]+) \(\s*[0-9.]+%\)\s+(.+?)\s*$")
TOTAL_RE = re.compile(r"Total Execution Time:\s+([0-9.]+) seconds")
BASELINE_PIPELINE = "builtin.module(func.func(convert-scf-to-cf,convert-arith-to-llvm),finalize-memref-to-llvm,convert-func-to-llvm,convert-cf-to-llvm,reconcile-unrealized-casts)"
DEPENDENT_PIPELINE = "builtin.module(func.func(convert-scf-to-cf,convert-arith-to-llvm),lower-dependent-memref-to-llvm,convert-func-to-llvm,convert-cf-to-llvm,reconcile-unrealized-casts)"


def repo_root() -> Path:
    return Path(__file__).resolve().parents[3]


def default_baseline_mlir_opt() -> Path:
    worktree_build = (repo_root().parent / "llvm-project-main" /
                      "build_mlir_baseline" / "bin" / "mlir-opt")
    if worktree_build.exists():
        return worktree_build
    return repo_root() / "build_mlir_baseline" / "bin" / "mlir-opt"


def default_dependent_mlir_opt() -> Path:
    return repo_root() / "build" / "bin" / "mlir-opt"


def parse_timing(report: str):
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
        "rest_ms": times.get("Rest", 0.0),
        "canonicalize_ms": times.get("CanonicalizerPass", 0.0),
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


def pipeline_for_route(route: str) -> str:
    base = BASELINE_PIPELINE if route.startswith("baseline_memref") else DEPENDENT_PIPELINE
    if route.endswith("_canonicalize"):
        return base[:-1] + ",canonicalize)"
    return base


def pipeline_for_row(row) -> str:
    # Structural workloads may supply the original experiment's exact pipeline.
    if row.get("pipeline"):
        base = row["pipeline"]
        if row["route"].endswith("_canonicalize"):
            return base[:-1] + ",canonicalize)"
        return base
    return pipeline_for_route(row["route"])


def mlir_opt_for_route(args, route: str) -> Path:
    if route.startswith("baseline_memref"):
        return args.baseline_mlir_opt
    return args.dependent_mlir_opt


def mlir_opt_cmd(mlir_opt: Path, input_path: Path, output_path: Path,
                 pipeline: str, *, generic: bool = False):
    cmd = [
        str(mlir_opt),
        str(input_path),
        f"-pass-pipeline={pipeline}",
        "-mlir-disable-threading",
    ]
    if generic:
        cmd.append("-mlir-print-op-generic")
    else:
        cmd += ["-mlir-timing", "-mlir-timing-display=list"]
    cmd += ["-o", str(output_path)]
    return cmd


def run_mlir_opt(mlir_opt: Path, input_path: Path, output_path: Path,
                 pipeline: str):
    cmd = mlir_opt_cmd(mlir_opt, input_path, output_path, pipeline)
    proc = subprocess.run(cmd, cwd=repo_root(), text=True,
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if proc.returncode != 0:
        raise RuntimeError(f"mlir-opt failed for {input_path}:\n{proc.stdout}")
    return parse_timing(proc.stdout)


def write_lowered_output(mlir_opt: Path, row, out: Path):
    route = row["route"]
    rank = row.get("max_carrier_rank", row["rank"])
    input_path = Path(row["path"])
    lowered_path = out / "lowered_kernels" / f"{route}-dimensions-{rank}.llvm.mlir"
    lowered_path.parent.mkdir(parents=True, exist_ok=True)
    cmd = mlir_opt_cmd(mlir_opt, input_path, lowered_path,
                       pipeline_for_row(row), generic=True)
    proc = subprocess.run(cmd, cwd=repo_root(), text=True,
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if proc.returncode != 0:
        raise RuntimeError(f"mlir-opt failed for {input_path}:\n{proc.stdout}")
    return lowered_path


def write_timing_output(mlir_opt: Path, row, out: Path):
    route = row["route"]
    rank = row.get("max_carrier_rank", row["rank"])
    input_path = Path(row["path"])
    timing_path = out / "mlir_timing_outputs" / f"{route}-dimensions-{rank}.txt"
    timing_path.parent.mkdir(parents=True, exist_ok=True)
    cmd = mlir_opt_cmd(mlir_opt, input_path, Path(os.devnull),
                       pipeline_for_row(row))
    proc = subprocess.run(cmd, cwd=repo_root(), text=True,
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if proc.returncode != 0:
        raise RuntimeError(f"mlir-opt failed for {input_path}:\n{proc.stdout}")
    timing_path.write_text(
        "$ " + " ".join(shlex.quote(arg) for arg in cmd) + "\n\n" + proc.stdout
    )
    return timing_path


def run_measured(args, row, repetition: int, out: Path):
    route = row["route"]
    mlir_opt = mlir_opt_for_route(args, route)
    metrics = run_mlir_opt(mlir_opt, Path(row["path"]), Path(os.devnull),
                           pipeline_for_row(row))
    return {
        **row,
        "repetition": repetition,
        "total_ms": f"{metrics['total_ms']:.6f}",
        "parser_ms": f"{metrics['parser_ms']:.6f}",
        "output_ms": f"{metrics['output_ms']:.6f}",
        "rest_ms": f"{metrics['rest_ms']:.6f}",
        "canonicalize_ms": f"{metrics['canonicalize_ms']:.6f}",
    }


def quantile(values, fraction: float):
    if not values:
        return 0.0
    ordered = sorted(values)
    index = (len(ordered) - 1) * fraction
    lower = int(index)
    upper = min(lower + 1, len(ordered) - 1)
    weight = index - lower
    return ordered[lower] * (1.0 - weight) + ordered[upper] * weight


def write_summary(rows, out: Path):
    grouped = {}
    for row in rows:
        key = (row["route"], row["rank"])
        grouped.setdefault(key, []).append(row)
    summary = []
    for (route, rank), group in sorted(grouped.items()):
        total_values = [float(r["total_ms"]) for r in group]
        parser_values = [float(r["parser_ms"]) for r in group]
        output_values = [float(r["output_ms"]) for r in group]
        rest_values = [float(r["rest_ms"]) for r in group]
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
            "median_total_ms": f"{statistics.median(total_values):.6f}",
            "mean_total_ms": f"{statistics.mean(total_values):.6f}",
            "min_total_ms": f"{min(total_values):.6f}",
            "p25_total_ms": f"{quantile(total_values, 0.25):.6f}",
            "p75_total_ms": f"{quantile(total_values, 0.75):.6f}",
            "max_total_ms": f"{max(total_values):.6f}",
            "stdev_total_ms": f"{statistics.stdev(total_values) if len(total_values) > 1 else 0.0:.6f}",
            "median_parser_ms": f"{statistics.median(parser_values):.6f}",
            "median_output_ms": f"{statistics.median(output_values):.6f}",
            "median_rest_ms": f"{statistics.median(rest_values):.6f}",
            "median_canonicalize_ms": f"{statistics.median(float(r['canonicalize_ms']) for r in group):.6f}",
        })
    path = out / "summary.csv"
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=summary[0].keys())
        writer.writeheader()
        writer.writerows(summary)


def run_llvm_end_to_end(args, rows):
    """Measure complete subprocess routes, including intermediate file I/O.

    These are wall-clock measurements, not MLIR's internal timer. Retain one
    complete set of IR artifacts and the exact commands for each route.
    """
    commands = []
    def measure(row, directory, retain=False):
        lowered = directory / "lowered.mlir"
        translated = directory / "translated.ll"
        optimized = directory / "optimized.ll" if retain else Path(os.devnull)
        pipeline = pipeline_for_row(row)
        stages = [
            [str(mlir_opt_for_route(args, row["route"])), row["path"],
             f"-pass-pipeline={pipeline}", "-mlir-disable-threading",
             "-o", str(lowered)],
            [str(args.llvm_bin / "mlir-translate"), "--mlir-to-llvmir",
             str(lowered), "-o", str(translated)],
            [str(args.llvm_bin / "opt"), "-passes=default<O3>", "-S",
             str(translated), "-o", str(optimized)],
        ]
        elapsed = []
        start = time.perf_counter()
        for cmd in stages:
            stage_start = time.perf_counter()
            subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL,
                           stderr=subprocess.PIPE)
            elapsed.append((time.perf_counter() - stage_start) * 1000)
        total = (time.perf_counter() - start) * 1000
        if retain:
            commands.extend(stages)
            cmd = [str(args.llvm_bin / "llc"), "-O=3", str(optimized),
                   "-o", str(directory / "optimized.s")]
            subprocess.run(cmd, check=True, stderr=subprocess.PIPE)
            commands.append(cmd)
        return dict(total_wall_ms=total, mlir_wall_ms=elapsed[0],
                    translate_wall_ms=elapsed[1], opt_wall_ms=elapsed[2])

    rng = random.Random(args.seed)
    results = []
    with tempfile.TemporaryDirectory(dir=args.out) as temporary:
        directory = Path(temporary)
        warmups = rows * args.warmups
        rng.shuffle(warmups)
        for row in warmups:
            measure(row, directory)
        jobs = [(row, rep) for row in rows for rep in range(args.repetitions)]
        rng.shuffle(jobs)
        for index, (row, rep) in enumerate(jobs, 1):
            results.append({**row, "repetition": rep, **measure(row, directory)})
            if index % 100 == 0 or index == len(jobs):
                print(f"LLVM end-to-end measurement {index}/{len(jobs)}", flush=True)
    for row in rows:
        directory = args.out / "llvm" / f"{row['route']}-rank-{row['rank']}"
        directory.mkdir(parents=True, exist_ok=True)
        measure(row, directory, retain=True)
    (args.out / "llvm_commands.json").write_text(json.dumps(commands, indent=2) + "\n")
    with (args.out / "llvm_results.csv").open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=results[0].keys())
        writer.writeheader()
        writer.writerows(results)
    summary = []
    for row in rows:
        group = [r for r in results if (r["route"], r["rank"]) ==
                 (row["route"], row["rank"])]
        values = [r["total_wall_ms"] for r in group]
        summary.append({"route": row["route"], "rank": row["rank"],
                        "repetitions": len(group),
                        **{f"median_{k}": statistics.median(r[k] for r in group)
                           for k in ("total_wall_ms", "mlir_wall_ms",
                                     "translate_wall_ms", "opt_wall_ms")},
                        "p25_total_wall_ms": quantile(values, 0.25),
                        "p75_total_wall_ms": quantile(values, 0.75)})
    with (args.out / "llvm_summary.csv").open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=summary[0].keys())
        writer.writeheader()
        writer.writerows(summary)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--generated", type=Path, default=Path("artifacts/runs/latest/generated_kernels"))
    ap.add_argument("--out", type=Path, default=Path("artifacts/runs/latest"))
    ap.add_argument("--mlir-opt", type=Path, default=None,
                    help="Use one mlir-opt binary for both routes.")
    ap.add_argument("--baseline-mlir-opt", type=Path, default=None,
                    help="Upstream/main mlir-opt used for baseline_memref.")
    ap.add_argument("--dependent-mlir-opt", type=Path, default=None,
                    help="Prototype mlir-opt used for dependent memref.")
    ap.add_argument("--repetitions", type=int, default=1000)
    ap.add_argument("--warmups", type=int, default=50)
    ap.add_argument("--include-canonicalization", action="store_true",
                    help="Also measure each route with final canonicalization.")
    ap.add_argument("--ranks", type=int, nargs="+",
                    help="Select contraction ranks from the existing manifest.")
    ap.add_argument("--llvm-end-to-end", action="store_true",
                    help="Measure subprocess wall time through LLVM O3 instead.")
    ap.add_argument("--llvm-bin", type=Path, default=repo_root() / "build/bin")
    ap.add_argument("--seed", type=int, default=0)
    args = ap.parse_args()
    args.generated = args.generated.resolve()
    args.out = args.out.resolve()
    args.llvm_bin = args.llvm_bin.resolve()
    if args.repetitions < 1 or args.warmups < 0:
        ap.error("repetitions must be positive and warmups nonnegative")
    shared_mlir_opt = args.mlir_opt.resolve() if args.mlir_opt else None
    args.baseline_mlir_opt = (
        args.baseline_mlir_opt or shared_mlir_opt or default_baseline_mlir_opt()
    ).resolve()
    args.dependent_mlir_opt = (
        args.dependent_mlir_opt or shared_mlir_opt or default_dependent_mlir_opt()
    ).resolve()
    for label, path in [
        ("baseline mlir-opt", args.baseline_mlir_opt),
        ("dependent mlir-opt", args.dependent_mlir_opt),
    ]:
        if not path.exists():
            raise FileNotFoundError(f"{label} does not exist: {path}")

    rows = read_manifest(args.generated / "manifest.csv")
    if args.ranks:
        rows = [row for row in rows if row["rank"] in args.ranks]
    if not rows:
        ap.error("no workloads selected")
    if args.include_canonicalization:
        rows += [{**row, "route": row["route"] + "_canonicalize"} for row in rows]
    args.out.mkdir(parents=True, exist_ok=True)
    run_config = {
        "measurement": "subprocess_wall_through_llvm_O3" if args.llvm_end_to_end else "mlir_internal",
        "llvm_bin": str(args.llvm_bin),
        "ranks": args.ranks,
        "pipelines": {row["route"]: pipeline_for_row(row) for row in rows},
        "single_binary_smoke": shared_mlir_opt is not None,
        "baseline_mlir_opt": str(args.baseline_mlir_opt),
        "dependent_mlir_opt": str(args.dependent_mlir_opt),
        "baseline_pipeline": BASELINE_PIPELINE,
        "dependent_pipeline": DEPENDENT_PIPELINE,
        "generated": str(args.generated),
        "repetitions": args.repetitions,
        "warmups": args.warmups,
        "seed": args.seed,
    }
    (args.out / "run_config.json").write_text(
        json.dumps(run_config, indent=2, sort_keys=True) + "\n"
    )
    if shared_mlir_opt is not None:
        print("warning: --mlir-opt uses one binary for both routes; use split flags for paper runs")

    if args.llvm_end_to_end:
        run_llvm_end_to_end(args, rows)
        return

    rng = random.Random(args.seed)
    warmup_jobs = rows * args.warmups
    rng.shuffle(warmup_jobs)
    for index, row in enumerate(warmup_jobs, 1):
        if index == 1 or index % 100 == 0 or index == len(warmup_jobs):
            print(f"warmup {index}/{len(warmup_jobs)}")
        run_mlir_opt(mlir_opt_for_route(args, row["route"]), Path(row["path"]),
                     Path(os.devnull), pipeline_for_row(row))

    jobs = [(row, rep) for row in rows for rep in range(args.repetitions)]
    rng.shuffle(jobs)
    all_rows = []
    for index, (row, rep) in enumerate(jobs, 1):
        if index == 1 or index % 250 == 0 or index == len(jobs):
            print(f"measurement {index}/{len(jobs)}")
        all_rows.append(run_measured(args, row, rep, args.out))

    for row in rows:
        route_mlir_opt = mlir_opt_for_route(args, row["route"])
        write_lowered_output(route_mlir_opt, row, args.out)
        write_timing_output(route_mlir_opt, row, args.out)

    results_path = args.out / "results.csv"
    with results_path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=all_rows[0].keys())
        writer.writeheader()
        writer.writerows(all_rows)
    write_summary(all_rows, args.out)
    print(f"wrote {results_path}")


if __name__ == "__main__":
    main()
