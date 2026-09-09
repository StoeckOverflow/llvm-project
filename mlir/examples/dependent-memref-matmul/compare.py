#!/usr/bin/env python3
import argparse
import json
import os
import subprocess
import time
from pathlib import Path


BASELINE_PIPELINE = "builtin.module(one-shot-bufferize{bufferize-function-boundaries},func.func(convert-scf-to-cf,convert-arith-to-llvm),finalize-memref-to-llvm,convert-func-to-llvm,convert-cf-to-llvm,reconcile-unrealized-casts)"
DEPENDENT_PIPELINE = "builtin.module(convert-dependent-tensor-to-dependent-memref,lower-dependent-memref-to-llvm,func.func(convert-scf-to-cf,convert-arith-to-llvm),reconcile-unrealized-casts)"
MEMREF_PIPELINE = "builtin.module(func.func(convert-scf-to-cf,convert-arith-to-llvm),finalize-memref-to-llvm,convert-func-to-llvm,convert-cf-to-llvm,reconcile-unrealized-casts)"
DIRECT_DEPENDENT_PIPELINE = "builtin.module(lower-dependent-memref-to-llvm,func.func(convert-scf-to-cf,convert-arith-to-llvm),reconcile-unrealized-casts)"


def run(command, **kwargs):
    result = subprocess.run(
        command, check=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        **kwargs,
    )
    return result.stdout


def repo_root_from(script_dir):
    return Path(run(["git", "-C", str(script_dir), "rev-parse", "--show-toplevel"]).strip())


def default_baseline_mlir_opt(repo_root):
    worktree_build = repo_root.parent / "llvm-project-main" / "build_mlir_baseline" / "bin" / "mlir-opt"
    if worktree_build.exists():
        return worktree_build
    return repo_root / "build_mlir_baseline" / "bin" / "mlir-opt"


def default_dependent_mlir_opt(repo_root):
    return repo_root / "build" / "bin" / "mlir-opt"


def route_env(mlir_opt):
    env = os.environ.copy()
    env["MLIR_OPT"] = str(mlir_opt)
    return env


def require_tool(label, path):
    if not path.exists():
        raise FileNotFoundError(f"{label} does not exist: {path}")


def extract_mlir_timing(stderr):
    try:
        timing = json.loads(stderr)
    except json.JSONDecodeError:
        return {}
    total = next((entry for entry in timing if entry.get("name") == "Total"), None)
    payload = {"pass_timing": timing}
    if total and "wall" in total and "duration" in total["wall"]:
        payload["pass_timing_total_ms"] = round(total["wall"]["duration"] * 1000.0, 3)
    return payload


def extract_llvm_pass_timing(stderr):
    lines = stderr.splitlines()
    in_pass_report = False
    for line in lines:
        if "Pass execution timing report" in line:
            in_pass_report = True
            continue
        if in_pass_report and "Total Execution Time:" in line:
            fields = line.split()
            try:
                seconds = float(fields[3])
            except (IndexError, ValueError):
                return {}
            return {"pass_timing_total_ms": round(seconds * 1000.0, 3)}
    return {}


def measure_wall(command, timing_path=None, parse_timing=None):
    start = time.perf_counter()
    result = subprocess.run(
        command, check=True, text=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE
    )
    elapsed_ms = (time.perf_counter() - start) * 1000.0
    payload = {"wall_ms": round(elapsed_ms, 3)}
    if timing_path is not None:
        timing_path.write_text(result.stderr)
        payload["timing_file"] = str(timing_path)
    if parse_timing is not None:
        payload.update(parse_timing(result.stderr))
    return payload


def measure_mlir_opt(command, timing_path):
    return measure_wall(
        [
            *command,
            "-mlir-disable-threading",
            "-mlir-timing",
            "-mlir-timing-display=list",
            "-mlir-output-format=json",
        ],
        timing_path,
        extract_mlir_timing,
    )


def measure_llvm_opt(command, timing_path):
    return measure_wall([*command, "-time-passes"], timing_path, extract_llvm_pass_timing)


def parse_key_values(output):
    parsed = {}
    for line in output.splitlines():
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        parsed[key.strip()] = value.strip()
    return parsed


def line_count(path):
    return len(path.read_text().splitlines())


def count_occurrences(path, needle):
    return path.read_text().count(needle)


def collect_ir_metrics(prefix, out_dir, stem=None):
    stem = stem or prefix
    llvm_mlir = out_dir / f"{stem}.llvm.mlir"
    llvm_ir = out_dir / f"{stem}.ll"
    llvm_opt_ir = out_dir / f"{stem}.opt.ll"
    metrics = {
        "llvm_dialect_lines": line_count(llvm_mlir),
        "llvm_ir_lines": line_count(llvm_ir),
        "llvm_dialect_insertvalue": count_occurrences(llvm_mlir, '"llvm.insertvalue"'),
        "llvm_dialect_extractvalue": count_occurrences(llvm_mlir, '"llvm.extractvalue"'),
        "llvm_ir_insertvalue": count_occurrences(llvm_ir, "insertvalue"),
        "llvm_ir_extractvalue": count_occurrences(llvm_ir, "extractvalue"),
        "llvm_dialect_struct_type": count_occurrences(llvm_mlir, "!llvm.struct"),
        "llvm_dialect_gep": count_occurrences(llvm_mlir, '"llvm.getelementptr"'),
        "llvm_dialect_load": count_occurrences(llvm_mlir, '"llvm.load"'),
        "llvm_dialect_store": count_occurrences(llvm_mlir, '"llvm.store"'),
    }
    if llvm_opt_ir.exists():
        metrics.update(
            {
                "llvm_opt_ir_lines": line_count(llvm_opt_ir),
                "llvm_opt_ir_insertvalue": count_occurrences(llvm_opt_ir, "insertvalue"),
                "llvm_opt_ir_extractvalue": count_occurrences(llvm_opt_ir, "extractvalue"),
                "llvm_opt_ir_struct_type": count_occurrences(
                    llvm_opt_ir, "{ ptr, ptr, i64, [2 x i64], [2 x i64] }"
                ),
            }
        )
    return metrics


def main():
    parser = argparse.ArgumentParser(
        description="Build and compare dependent-memref and standard memref matmul artifacts."
    )
    parser.add_argument("--n", type=int, default=128)
    parser.add_argument("--k", type=int)
    parser.add_argument("--m", type=int)
    parser.add_argument("--repeats", type=int, default=10)
    parser.add_argument("--out", type=Path)
    parser.add_argument("--skip-run", action="store_true")
    parser.add_argument("--mlir-opt", type=Path, default=None,
                        help="Use one mlir-opt binary for all routes; intended for smoke checks only.")
    parser.add_argument("--baseline-mlir-opt", type=Path, default=None,
                        help="Upstream/main mlir-opt used for baseline routes.")
    parser.add_argument("--dependent-mlir-opt", type=Path, default=None,
                        help="Prototype mlir-opt used for dependent routes.")
    args = parser.parse_args()

    script_dir = Path(__file__).resolve().parent
    repo_root = repo_root_from(script_dir)
    shared_mlir_opt = args.mlir_opt.resolve() if args.mlir_opt else None
    baseline_mlir_opt = (args.baseline_mlir_opt or shared_mlir_opt or default_baseline_mlir_opt(repo_root)).resolve()
    dependent_mlir_opt = (args.dependent_mlir_opt or shared_mlir_opt or default_dependent_mlir_opt(repo_root)).resolve()
    require_tool("baseline mlir-opt", baseline_mlir_opt)
    require_tool("dependent mlir-opt", dependent_mlir_opt)
    llvm_opt = Path(os.environ.get("LLVM_OPT", repo_root / "build/bin/opt"))
    out_dir = args.out or script_dir / "artifacts"
    out_dir.mkdir(parents=True, exist_ok=True)
    k = args.k if args.k is not None else args.n
    m = args.m if args.m is not None else args.n

    common = [
        "--out",
        str(out_dir),
        "--n",
        str(args.n),
        "--k",
        str(k),
        "--m",
        str(m),
        "--repeats",
        str(args.repeats),
    ]
    if args.skip_run:
        common.append("--build-only")

    dependent_output = run([str(script_dir / "run-dependent.sh"), *common], env=route_env(dependent_mlir_opt))
    baseline_output = run([str(script_dir / "run-baseline.sh"), *common], env=route_env(baseline_mlir_opt))

    result = {
        "problem": {"n": args.n, "k": k, "m": m, "repeats": args.repeats},
        "toolchains": {
            "single_binary_smoke": shared_mlir_opt is not None,
            "baseline_mlir_opt": str(baseline_mlir_opt),
            "dependent_mlir_opt": str(dependent_mlir_opt),
        },
        "dependent": collect_ir_metrics("dependent", out_dir),
        "baseline": collect_ir_metrics("baseline", out_dir),
        "structural_artifacts": {
            "baseline_strided": collect_ir_metrics(
                "baseline_strided",
                out_dir / "baseline-strided",
                "baseline_matmul_strided",
            ),
            "direct_strided": collect_ir_metrics(
                "direct_strided",
                out_dir / "direct-strided",
                "dependent_matmul_strided",
            ),
        },
    }
    result["dependent"]["mlir_opt_path"] = str(dependent_mlir_opt)
    result["dependent"]["mlir_pipeline"] = DEPENDENT_PIPELINE
    result["dependent"]["mlir_opt"] = measure_mlir_opt(
        [
            str(dependent_mlir_opt),
            str(script_dir / "dependent-matmul.mlir"),
            f"-pass-pipeline={DEPENDENT_PIPELINE}",
        ],
        out_dir / "dependent.mlir-timing.txt",
    )
    result["baseline"]["mlir_opt_path"] = str(baseline_mlir_opt)
    result["baseline"]["mlir_pipeline"] = BASELINE_PIPELINE
    result["baseline"]["mlir_opt"] = measure_mlir_opt(
        [
            str(baseline_mlir_opt),
            str(script_dir / "baseline-tensor-matmul.mlir"),
            f"-pass-pipeline={BASELINE_PIPELINE}",
        ],
        out_dir / "baseline.mlir-timing.txt",
    )
    result["dependent"]["llvm_opt"] = measure_llvm_opt(
        [
            str(llvm_opt),
            "-O3",
            "-S",
            str(out_dir / "dependent.ll"),
            "-o",
            str(out_dir / "dependent.opt.ll"),
        ],
        out_dir / "dependent.opt-timing.txt",
    )
    result["baseline"]["llvm_opt"] = measure_llvm_opt(
        [
            str(llvm_opt),
            "-O3",
            "-S",
            str(out_dir / "baseline.ll"),
            "-o",
            str(out_dir / "baseline.opt.ll"),
        ],
        out_dir / "baseline.opt-timing.txt",
    )

    result["structural_artifacts"]["baseline_strided"]["mlir_opt_path"] = str(baseline_mlir_opt)
    result["structural_artifacts"]["baseline_strided"]["mlir_pipeline"] = MEMREF_PIPELINE
    result["structural_artifacts"]["baseline_strided"]["mlir_opt"] = measure_mlir_opt(
        [
            str(baseline_mlir_opt),
            str(script_dir / "baseline-strided-matmul.mlir"),
            f"-pass-pipeline={MEMREF_PIPELINE}",
        ],
        out_dir / "baseline-strided" / "baseline_matmul_strided.mlir-timing.txt",
    )
    result["structural_artifacts"]["direct_strided"]["mlir_opt_path"] = str(dependent_mlir_opt)
    result["structural_artifacts"]["direct_strided"]["mlir_pipeline"] = DIRECT_DEPENDENT_PIPELINE
    result["structural_artifacts"]["direct_strided"]["mlir_opt"] = measure_mlir_opt(
        [
            str(dependent_mlir_opt),
            str(script_dir / "dependent-strided-matmul.mlir"),
            f"-pass-pipeline={DIRECT_DEPENDENT_PIPELINE}",
        ],
        out_dir / "direct-strided" / "dependent_matmul_strided.mlir-timing.txt",
    )
    result["structural_artifacts"]["baseline_strided"]["llvm_opt"] = measure_llvm_opt(
        [
            str(llvm_opt),
            "-O3",
            "-S",
            str(out_dir / "baseline-strided" / "baseline_matmul_strided.ll"),
            "-o",
            str(out_dir / "baseline-strided" / "baseline_matmul_strided.opt.ll"),
        ],
        out_dir / "baseline-strided" / "baseline_matmul_strided.opt-timing.txt",
    )
    result["structural_artifacts"]["direct_strided"]["llvm_opt"] = measure_llvm_opt(
        [
            str(llvm_opt),
            "-O3",
            "-S",
            str(out_dir / "direct-strided" / "dependent_matmul_strided.ll"),
            "-o",
            str(out_dir / "direct-strided" / "dependent_matmul_strided.opt.ll"),
        ],
        out_dir / "direct-strided" / "dependent_matmul_strided.opt-timing.txt",
    )

    if not args.skip_run:
        result["dependent"]["run"] = parse_key_values(dependent_output)
        result["baseline"]["run"] = parse_key_values(baseline_output)

    result["delta"] = {
        "llvm_dialect_lines": result["baseline"]["llvm_dialect_lines"]
        - result["dependent"]["llvm_dialect_lines"],
        "llvm_ir_lines": result["baseline"]["llvm_ir_lines"]
        - result["dependent"]["llvm_ir_lines"],
        "llvm_opt_ir_lines": result["baseline"]["llvm_opt_ir_lines"]
        - result["dependent"]["llvm_opt_ir_lines"],
        "llvm_dialect_insertvalue": result["baseline"]["llvm_dialect_insertvalue"]
        - result["dependent"]["llvm_dialect_insertvalue"],
        "llvm_dialect_extractvalue": result["baseline"]["llvm_dialect_extractvalue"]
        - result["dependent"]["llvm_dialect_extractvalue"],
        "llvm_opt_ir_insertvalue": result["baseline"]["llvm_opt_ir_insertvalue"]
        - result["dependent"]["llvm_opt_ir_insertvalue"],
        "llvm_opt_ir_extractvalue": result["baseline"]["llvm_opt_ir_extractvalue"]
        - result["dependent"]["llvm_opt_ir_extractvalue"],
    }

    report_path = out_dir / "results.json"
    report_path.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")

    print(f"wrote={report_path}")
    print(f"dependent_llvm_dialect_lines={result['dependent']['llvm_dialect_lines']}")
    print(f"baseline_llvm_dialect_lines={result['baseline']['llvm_dialect_lines']}")
    print(f"dependent_llvm_ir_lines={result['dependent']['llvm_ir_lines']}")
    print(f"baseline_llvm_ir_lines={result['baseline']['llvm_ir_lines']}")
    print(f"dependent_llvm_opt_ir_lines={result['dependent']['llvm_opt_ir_lines']}")
    print(f"baseline_llvm_opt_ir_lines={result['baseline']['llvm_opt_ir_lines']}")
    print(
        "dependent_descriptor_ops="
        f"{result['dependent']['llvm_dialect_insertvalue'] + result['dependent']['llvm_dialect_extractvalue']}"
    )
    print(
        "baseline_descriptor_ops="
        f"{result['baseline']['llvm_dialect_insertvalue'] + result['baseline']['llvm_dialect_extractvalue']}"
    )
    baseline_strided = result["structural_artifacts"]["baseline_strided"]
    print(
        "baseline_strided_llvm_dialect_lines="
        f"{baseline_strided['llvm_dialect_lines']}"
    )
    print(
        "baseline_strided_descriptor_ops="
        f"{baseline_strided['llvm_dialect_insertvalue'] + baseline_strided['llvm_dialect_extractvalue']}"
    )
    direct_strided = result["structural_artifacts"]["direct_strided"]
    print(
        "direct_strided_llvm_dialect_lines="
        f"{direct_strided['llvm_dialect_lines']}"
    )
    print(
        "direct_strided_descriptor_ops="
        f"{direct_strided['llvm_dialect_insertvalue'] + direct_strided['llvm_dialect_extractvalue']}"
    )
    if not args.skip_run:
        print(f"dependent_median_ns={result['dependent']['run']['median_ns']}")
        print(f"baseline_median_ns={result['baseline']['run']['median_ns']}")
    print(f"dependent_mlir_opt_wall_ms={result['dependent']['mlir_opt']['wall_ms']}")
    print(f"baseline_mlir_opt_wall_ms={result['baseline']['mlir_opt']['wall_ms']}")
    print(f"dependent_llvm_opt_wall_ms={result['dependent']['llvm_opt']['wall_ms']}")
    print(f"baseline_llvm_opt_wall_ms={result['baseline']['llvm_opt']['wall_ms']}")


if __name__ == "__main__":
    main()
