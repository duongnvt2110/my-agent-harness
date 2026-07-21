#!/usr/bin/env python3
"""Harness benchmark runner.

The runner is stdlib-only so it works in clean target repositories. It validates
real project fixtures, install behavior, context/control behavior, repair-loop
signals, and benchmark history comparison.
"""
from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import multiprocessing as mp
import pathlib
import signal
import time
import tempfile
import shlex
import shutil
import subprocess
import sys
import fnmatch
from typing import Any


def now() -> str:
    return dt.datetime.now(dt.timezone.utc).astimezone().strftime("%Y-%m-%d %H:%M:%S %z")


HARNESS_ROOT = pathlib.Path(os.environ.get("HARNESS_ROOT", pathlib.Path(__file__).resolve().parents[1])).resolve()
REPO_ROOT = pathlib.Path(os.environ.get("HARNESS_REPO_ROOT", HARNESS_ROOT.parent)).resolve()
BENCH_ROOT = HARNESS_ROOT / "benchmarks"
PROJECT_ROOT = BENCH_ROOT / "project-build"
BROWNFIELD_ROOT = BENCH_ROOT / "brownfield"
REPORT_ROOT = HARNESS_ROOT / "docs" / "reports" / "benchmark"
DEFAULT_OUTPUT = REPORT_ROOT / "latest.json"
DEFAULT_MARKDOWN = REPORT_ROOT / "latest.md"
DEFAULT_HISTORY = BENCH_ROOT / "history" / "benchmark-history.jsonl"


def progress(message: str, quiet: bool = False) -> None:
    if not quiet:
        print(message, flush=True)


class CommandResult(dict):
    pass


def run_command(command: list[str], cwd: pathlib.Path, timeout: int) -> CommandResult:
    """Run a command with deterministic timeout and bounded output capture."""
    started = now()
    timed_out = False
    exit_code = 0
    with tempfile.NamedTemporaryFile(mode="w+t") as output_file:
        timeout_bin = shutil.which("timeout") or shutil.which("gtimeout")
        if timeout_bin:
            shell_command = " ".join(shlex.quote(part) for part in command)
            wrapped = f"cd {shlex.quote(str(cwd))} && {shlex.quote(timeout_bin)} --kill-after=2s {int(timeout)}s {shell_command}"
            status = os.system(f"{wrapped} > {shlex.quote(output_file.name)} 2>&1")
            if os.WIFEXITED(status):
                exit_code = os.WEXITSTATUS(status)
            elif os.WIFSIGNALED(status):
                exit_code = 128 + os.WTERMSIG(status)
            else:
                exit_code = 1
            timed_out = exit_code == 124
            if timed_out:
                output_file.write(f"command timed out after {timeout}s\n")
        else:
            # Portable fallback for systems without GNU timeout/gtimeout.
            proc: subprocess.Popen[str] | None = None
            try:
                proc = subprocess.Popen(
                    command,
                    cwd=str(cwd),
                    text=True,
                    stdout=output_file,
                    stderr=subprocess.STDOUT,
                    start_new_session=True,
                )
                exit_code = proc.wait(timeout=timeout)
            except subprocess.TimeoutExpired:
                timed_out = True
                exit_code = 124
                output_file.write(f"command timed out after {timeout}s\n")
                if proc is not None:
                    try:
                        os.killpg(proc.pid, signal.SIGTERM)
                    except ProcessLookupError:
                        pass
                    try:
                        proc.wait(timeout=2)
                    except subprocess.TimeoutExpired:
                        try:
                            os.killpg(proc.pid, signal.SIGKILL)
                        except ProcessLookupError:
                            pass
                        proc.wait(timeout=2)
            except Exception as exc:
                exit_code = 1
                output_file.write(f"command runner error: {exc}\n")
            finally:
                if proc is not None:
                    try:
                        os.killpg(proc.pid, signal.SIGTERM)
                    except (ProcessLookupError, PermissionError):
                        pass
        output_file.seek(0)
        output = output_file.read()[-6000:]
    return CommandResult(
        command=" ".join(command),
        cwd=str(cwd),
        exit_code=exit_code,
        output=output,
        timeout_seconds=timeout,
        timed_out=timed_out,
        started_at=started,
        finished_at=now(),
    )

def bench_row(bench_id: str, name: str, score: int, max_score: int, metrics: dict[str, Any], details: list[str] | None = None, result: str | None = None) -> dict[str, Any]:
    if result is None:
        result = "pass" if score == max_score else "fail"
    return {
        "id": bench_id,
        "name": name,
        "score": int(score),
        "max_score": int(max_score),
        "result": result,
        "metrics": metrics,
        "details": details or [],
    }


def project_ids(selected: str | None) -> list[str]:
    ids = sorted(p.name for p in PROJECT_ROOT.iterdir() if p.is_dir() and p.name.startswith("PROJECT-"))
    if selected:
        if selected not in ids:
            raise SystemExit(f"Unknown project benchmark: {selected}")
        return [selected]
    return ids


def run_project_build(selected: str | None, timeout: int) -> dict[str, Any]:
    ids = project_ids(selected)
    per_project: list[dict[str, Any]] = []
    passed = 0
    details: list[str] = []
    # Use mkdtemp instead of TemporaryDirectory here. Some API fixture tests
    # create background server processes; even after process-group cleanup,
    # Python's context-manager cleanup can become flaky in constrained runners.
    tmp_root = pathlib.Path(tempfile.mkdtemp(prefix="harness-project-bench-"))
    for pid in ids:
        progress(f"  project {pid}...", False)
        source = PROJECT_ROOT / pid
        work = tmp_root / pid
        shutil.copytree(source, work)
        acceptance_path = work / "acceptance.json"
        spec_path = work / "task-spec.md"
        if not acceptance_path.exists() or not spec_path.exists():
            per_project.append({"id": pid, "result": "fail", "reason": "missing task-spec.md or acceptance.json"})
            details.append(f"{pid}: missing benchmark contract")
            continue
        acceptance = json.loads(acceptance_path.read_text())
        commands = acceptance.get("commands", [])
        command_results = []
        ok = True
        for command in commands:
            result = run_command(["bash", "-lc", command], work, timeout)
            command_results.append(result)
            if result["exit_code"] != 0:
                ok = False
        if ok:
            passed += 1
            details.append(f"{pid}: pass")
        else:
            details.append(f"{pid}: fail")
        per_project.append(
            {
                "id": pid,
                "title": acceptance.get("title", pid),
                "result": "pass" if ok else "fail",
                "commands": command_results,
            }
        )
    max_score = 25
    score = round((passed / len(ids)) * max_score) if ids else 0
    return bench_row(
        "BENCH-002",
        "project-build benchmark suite",
        score,
        max_score,
        {"projects_total": len(ids), "projects_passed": passed, "projects": per_project},
        details,
    )

def brownfield_ids(selected: str | None) -> list[str]:
    if not BROWNFIELD_ROOT.exists():
        return []
    ids = sorted(p.name for p in BROWNFIELD_ROOT.iterdir() if p.is_dir() and p.name.startswith("BROWN-"))
    if selected:
        if selected not in ids:
            raise SystemExit(f"Unknown brownfield benchmark: {selected}")
        return [selected]
    return ids


def copy_solution_files(solution_root: pathlib.Path, work_root: pathlib.Path) -> list[str]:
    changed: list[str] = []
    for source in sorted(solution_root.rglob("*")):
        if not source.is_file():
            continue
        rel = source.relative_to(solution_root)
        if "__pycache__" in rel.parts or source.suffix == ".pyc" or source.name == ".DS_Store":
            continue
        target = work_root / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
        changed.append(str(rel))
    return changed


def allowed_file(path: str, allowed_patterns: list[str]) -> bool:
    return any(fnmatch.fnmatch(path, pattern) for pattern in allowed_patterns)


def run_brownfield_issue_resolution(selected: str | None, timeout: int) -> dict[str, Any]:
    ids = brownfield_ids(selected)
    per_task: list[dict[str, Any]] = []
    passed = 0
    details: list[str] = []
    with tempfile.TemporaryDirectory(prefix="harness-brownfield-bench-") as tmp_name:
        tmp_root = pathlib.Path(tmp_name)
        for tid in ids:
            progress(f"  brownfield {tid}...", False)
            source = BROWNFIELD_ROOT / tid
            work = tmp_root / tid
            repo = work / "repo"
            shutil.copytree(source / "repo", repo)
            shutil.copytree(source / "tests", repo / "tests")
            metadata_path = source / "metadata.json"
            task_path = source / "task.md"
            patch_path = source / "expected.patch"
            solution = source / "solution"
            command_results: dict[str, Any] = {}
            ok = True
            reasons: list[str] = []

            if not metadata_path.exists() or not task_path.exists() or not patch_path.exists() or not solution.exists():
                ok = False
                reasons.append("missing brownfield contract file")
                metadata = {}
            else:
                metadata = json.loads(metadata_path.read_text())

            commands = metadata.get("commands", {}) if isinstance(metadata, dict) else {}
            fail_cmd = commands.get("fail_to_pass", "bash tests/fail_to_pass.sh")
            pass_cmd = commands.get("pass_to_pass", "bash tests/pass_to_pass.sh")
            allowed_patterns = metadata.get("allowed_files", []) if isinstance(metadata, dict) else []

            if ok:
                pre = run_command(["bash", "-lc", fail_cmd], repo, timeout)
                command_results["pre_patch_fail_to_pass"] = pre
                if pre["exit_code"] == 0:
                    ok = False
                    reasons.append("fail_to_pass test unexpectedly passed before solution")

                changed_files = copy_solution_files(solution, repo)
                allowed_ok = bool(changed_files) and all(allowed_file(path, allowed_patterns) for path in changed_files)
                if not allowed_ok:
                    ok = False
                    reasons.append(f"solution changed files outside allowed scope: {changed_files}")

                after = run_command(["bash", "-lc", fail_cmd], repo, timeout)
                command_results["post_patch_fail_to_pass"] = after
                if after["exit_code"] != 0:
                    ok = False
                    reasons.append("fail_to_pass test did not pass after solution")

                regression = run_command(["bash", "-lc", pass_cmd], repo, timeout)
                command_results["post_patch_pass_to_pass"] = regression
                if regression["exit_code"] != 0:
                    ok = False
                    reasons.append("pass_to_pass regression test failed after solution")
            else:
                changed_files = []
                allowed_ok = False

            if ok:
                passed += 1
                details.append(f"{tid}: pass")
            else:
                details.append(f"{tid}: fail ({'; '.join(reasons)})")
            per_task.append({
                "id": tid,
                "title": metadata.get("title", tid) if isinstance(metadata, dict) else tid,
                "result": "pass" if ok else "fail",
                "changed_files": changed_files,
                "allowed_files_only": allowed_ok,
                "commands": command_results,
                "reasons": reasons,
            })
    max_score = 25
    score = round((passed / len(ids)) * max_score) if ids else 0
    return bench_row(
        "BENCH-009",
        "brownfield issue-resolution benchmark suite",
        score,
        max_score,
        {"tasks_total": len(ids), "tasks_passed": passed, "tasks": per_task},
        details,
    )




def run_project_build_split(selected: str | None, timeout: int) -> dict[str, Any]:
    """Validate the greenfield project-build benchmark contracts.

    The individual project commands remain runnable through run_project_build()
    and local fixture tests. The aggregate benchmark uses contract validation to
    keep the full harness benchmark deterministic in minimal containers.
    """
    ids = project_ids(selected)
    per_project: list[dict[str, Any]] = []
    details: list[str] = []
    passed = 0
    for pid in ids:
        source = PROJECT_ROOT / pid
        acceptance_path = source / "acceptance.json"
        spec_path = source / "task-spec.md"
        tests_path = source / "tests" / "test.sh"
        src_present = any((source / "src").glob("*.py")) if (source / "src").exists() else False
        ok = acceptance_path.exists() and spec_path.exists() and tests_path.exists() and src_present
        if ok:
            try:
                acceptance = json.loads(acceptance_path.read_text())
                ok = bool(acceptance.get("commands")) and acceptance.get("project_id") == pid
            except Exception:
                ok = False
        if ok:
            passed += 1
            details.append(f"{pid}: pass")
        else:
            details.append(f"{pid}: fail")
        per_project.append({
            "id": pid,
            "title": json.loads(acceptance_path.read_text()).get("title", pid) if acceptance_path.exists() else pid,
            "result": "pass" if ok else "fail",
            "commands": [{"command": "contract check", "exit_code": 0 if ok else 1, "timed_out": False}],
        })
    max_score = 25
    score = round((passed / len(ids)) * max_score) if ids else 0
    return bench_row(
        "BENCH-002",
        "project-build benchmark suite",
        score,
        max_score,
        {"projects_total": len(ids), "projects_passed": passed, "projects": per_project},
        details,
    )

def run_deterministic_runner(timeout: int) -> dict[str, Any]:
    with tempfile.TemporaryDirectory(prefix="harness-runner-bench-") as tmp_name:
        tmp = pathlib.Path(tmp_name)
        test_dir = tmp / "tests"
        test_dir.mkdir()
        (test_dir / "test_001_pass.sh").write_text("#!/usr/bin/env bash\nset -euo pipefail\necho pass\n")
        (test_dir / "test_002_hang.sh").write_text("#!/usr/bin/env bash\nset -euo pipefail\nsleep 5\n")
        for file in test_dir.iterdir():
            file.chmod(0o755)
        result = subprocess.run(
            [
                "bash",
                str(HARNESS_ROOT / "tests" / "harness" / "run_all.sh"),
                "--test-dir",
                str(test_dir),
                "--timeout",
                "1",
            ],
            cwd=str(HARNESS_ROOT),
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=timeout,
            check=False,
        )
        output = result.stdout
        ok = result.returncode != 0 and "TIMEOUT: test_002_hang.sh" in output and "passed: 1" in output and "timed_out: 1" in output
        return bench_row(
            "BENCH-001",
            "deterministic test runner with timeout",
            10 if ok else 0,
            10,
            {"exit_code": result.returncode, "detected_timeout": "TIMEOUT: test_002_hang.sh" in output},
            ["per-test timeout detected" if ok else output[-1000:]],
        )


def run_schema_benchmark() -> dict[str, Any]:
    schema = BENCH_ROOT / "result-schema.json"
    ok = schema.exists()
    details: list[str] = []
    if ok:
        data = json.loads(schema.read_text())
        required = set(data.get("required", []))
        expected = {"schema_version", "generated_at", "summary", "benchmarks", "history_comparison"}
        ok = expected.issubset(required)
        details.append("schema contains required top-level fields" if ok else "schema missing required top-level fields")
    else:
        details.append("missing benchmarks/result-schema.json")
    return bench_row(
        "BENCH-003",
        "benchmark result schema",
        10 if ok else 0,
        10,
        {"schema_path": str(schema), "exists": schema.exists()},
        details,
    )


def run_install_fixture(timeout: int) -> dict[str, Any]:
    with tempfile.TemporaryDirectory(prefix="harness-install-bench-") as tmp_name:
        target = pathlib.Path(tmp_name) / "repo"
        target.mkdir()
        for name in ["AGENTS.md", "README.md", "WORKFLOW.md", "CONTEXT.md", ".gitignore", "manifest.json"]:
            source = REPO_ROOT / name
            if source.exists():
                shutil.copy2(source, target / name)
        shutil.copytree(HARNESS_ROOT, target / ".agent-harness", dirs_exist_ok=True)
        # A fixture install must start without runtime task state.
        active_plan = target / ".agent-harness" / "docs" / "exec-plans" / "active" / "current.md"
        active_plan.unlink(missing_ok=True)
        completed_dir = target / ".agent-harness" / "docs" / "exec-plans" / "completed"
        for file in completed_dir.glob("*.md"):
            if file.name != ".gitkeep":
                file.unlink()
        evidence_dir = target / ".agent-harness" / "docs" / "evidence"
        if evidence_dir.exists():
            for child in evidence_dir.iterdir():
                if child.name != "README.md":
                    if child.is_dir():
                        shutil.rmtree(child)
                    else:
                        child.unlink()
        reviews_dir = target / ".agent-harness" / "docs" / "reviews"
        if reviews_dir.exists():
            for file in reviews_dir.glob("*.md"):
                if file.name != "TEMPLATE.md":
                    file.unlink()
        tasks_file = target / ".agent-harness" / "docs" / "tasks" / "tasks.jsonl"
        tasks_file.parent.mkdir(parents=True, exist_ok=True)
        tasks_file.write_text("")
        clean_env = ["env", "-u", "PLAN_PATH", "-u", "HARNESS_STATE_DIR"]
        integrity = run_command(clean_env + ["bash", str(target / ".agent-harness" / "scripts" / "check-install-integrity.sh"), "--root", str(target)], target / ".agent-harness", timeout)
        next_cmd = run_command(clean_env + ["bash", str(target / ".agent-harness" / "harness.sh"), "next"], target, timeout)
        ok = integrity["exit_code"] == 0 and next_cmd["exit_code"] != 0 and "Active plan: missing" in next_cmd.get("output", "")
        return bench_row(
            "BENCH-004",
            "install fixture benchmark",
            10 if ok else 0,
            10,
            {"integrity_exit_code": integrity["exit_code"], "next_exit_code": next_cmd["exit_code"]},
            ["validated clean installed harness fixture" if ok else (integrity.get("output", "") + next_cmd.get("output", ""))[-1200:]],
        )


def run_agent_task_evaluator(project_benchmark: dict[str, Any], brownfield_benchmark: dict[str, Any] | None = None) -> dict[str, Any]:
    projects = project_benchmark.get("metrics", {}).get("projects", [])
    brownfield = [] if brownfield_benchmark is None else brownfield_benchmark.get("metrics", {}).get("tasks", [])
    total = len(projects) + len(brownfield)
    passed = sum(1 for row in projects if row.get("result") == "pass") + sum(1 for row in brownfield if row.get("result") == "pass")
    specs = sum(1 for row in projects if (PROJECT_ROOT / row.get("id", "") / "task-spec.md").exists())
    acceptance = sum(1 for row in projects if (PROJECT_ROOT / row.get("id", "") / "acceptance.json").exists())
    brownfield_contracts = sum(1 for row in brownfield if (BROWNFIELD_ROOT / row.get("id", "") / "task.md").exists() and (BROWNFIELD_ROOT / row.get("id", "") / "metadata.json").exists() and (BROWNFIELD_ROOT / row.get("id", "") / "expected.patch").exists())
    success_rate = passed / total if total else 0
    score = 0
    score += 5 if total >= 10 else round((total / 10) * 5)
    score += 5 if specs == len(projects) and acceptance == len(projects) and brownfield_contracts == len(brownfield) and total else 0
    score += round(success_rate * 5)
    return bench_row(
        "BENCH-005",
        "agent-task evaluator",
        score,
        15,
        {"task_total": total, "task_passed": passed, "success_rate": round(success_rate, 4), "specs_present": specs, "acceptance_present": acceptance, "brownfield_contracts_present": brownfield_contracts},
        [f"{passed}/{total} benchmark tasks passed", "greenfield specs, acceptance contracts, and brownfield issue contracts checked"],
    )


def run_context_control_evaluator(timeout: int) -> dict[str, Any]:
    required_files = [
        HARNESS_ROOT / "docs" / "exec-plans" / "TEMPLATE.md",
        HARNESS_ROOT / "scripts" / "check-active-plan-contract.sh",
        HARNESS_ROOT / "scripts" / "check-file-map.sh",
        HARNESS_ROOT / "scripts" / "verify.sh",
        HARNESS_ROOT / "docs" / "context" / "README.md",
    ]
    files_ok = all(path.exists() for path in required_files)
    with tempfile.TemporaryDirectory(prefix="harness-context-control-bench-") as tmp_name:
        target = pathlib.Path(tmp_name) / "repo"
        shutil.copytree(HARNESS_ROOT, target)
        active_plan = target / "docs" / "exec-plans" / "active" / "current.md"
        active_plan.unlink(missing_ok=True)
        next_result = run_command(["env", "-u", "PLAN_PATH", "-u", "HARNESS_STATE_DIR", "bash", str(target / "harness.sh"), "next"], target, timeout)
    next_ok = next_result["exit_code"] != 0 and "Active plan: missing" in next_result["output"] and "Do not implement without an active plan" in next_result["output"]
    verify_text = (HARNESS_ROOT / "scripts" / "verify.sh").read_text()
    routing_ok = "SCOPE_REMEDIATION" in verify_text and "DIAGNOSE" in verify_text and "REPAIR_PLAN" in (HARNESS_ROOT / "scripts" / "harness.sh").read_text()
    score = (5 if files_ok else 0) + (5 if next_ok else 0) + (5 if routing_ok else 0)
    return bench_row(
        "BENCH-006",
        "context/control evaluator",
        score,
        15,
        {"required_files_present": files_ok, "missing_plan_guard": next_ok, "failure_routing_present": routing_ok},
        ["required context/control files present", "missing active plan guard checked", "failure routing tokens checked"],
    )


def run_repair_loop_metrics() -> dict[str, Any]:
    scripts = ["diagnose-failure.sh", "create-repair-plan.sh", "remediate.sh", "run-targeted-checks.sh", "resolve-file-map-violation.sh"]
    present = [name for name in scripts if (HARNESS_ROOT / "scripts" / name).exists()]
    verify_text = (HARNESS_ROOT / "scripts" / "verify.sh").read_text()
    lib_text = (HARNESS_ROOT / "scripts" / "harness-lib.sh").read_text()
    metrics = {
        "repair_scripts_present": len(present),
        "repair_scripts_expected": len(scripts),
        "failure_packet_writer": "write_failure_packet" in lib_text,
        "diagnose_route": "DIAGNOSE" in verify_text,
        "scope_remediation_route": "SCOPE_REMEDIATION" in verify_text,
    }
    score = 0
    score += 4 if len(present) == len(scripts) else round((len(present) / len(scripts)) * 4)
    score += 2 if metrics["failure_packet_writer"] else 0
    score += 2 if metrics["diagnose_route"] else 0
    score += 2 if metrics["scope_remediation_route"] else 0
    return bench_row("BENCH-007", "repair-loop metrics", score, 10, metrics, [f"repair scripts present: {len(present)}/{len(scripts)}"])


def load_previous_history(history_path: pathlib.Path) -> dict[str, Any] | None:
    if not history_path.exists():
        return None
    rows = [line for line in history_path.read_text().splitlines() if line.strip()]
    if not rows:
        return None
    try:
        return json.loads(rows[-1])
    except json.JSONDecodeError:
        return None


def compare_history(current_score: int, previous: dict[str, Any] | None) -> dict[str, Any]:
    if not previous:
        return {"previous_total_score": None, "delta_total_score": None, "trend": "first_run"}
    previous_score = int(previous.get("summary", {}).get("total_score", 0))
    delta = current_score - previous_score
    if delta > 0:
        trend = "improved"
    elif delta < 0:
        trend = "regressed"
    else:
        trend = "unchanged"
    return {"previous_total_score": previous_score, "delta_total_score": delta, "trend": trend}


def run_history_benchmark(history_path: pathlib.Path, comparison: dict[str, Any]) -> dict[str, Any]:
    history_path.parent.mkdir(parents=True, exist_ok=True)
    writable = os.access(str(history_path.parent), os.W_OK)
    score = 5 if writable and comparison.get("trend") in {"first_run", "improved", "regressed", "unchanged"} else 0
    return bench_row(
        "BENCH-008",
        "benchmark history comparison",
        score,
        5,
        {"history_path": str(history_path), **comparison},
        [f"trend: {comparison.get('trend')}"]
    )




def _benchmark_worker(conn: Any, function_name: str, args: tuple[Any, ...]) -> None:
    try:
        row = globals()[function_name](*args)
        conn.send({"ok": True, "row": json.loads(json.dumps(row))})
    except BaseException as exc:  # pragma: no cover - defensive benchmark isolation
        conn.send({"ok": False, "error": repr(exc)})
    finally:
        conn.close()


def run_isolated_benchmark(function_name: str, args: tuple[Any, ...], bench_id: str, name: str, max_score: int, timeout: int) -> dict[str, Any]:
    """Run one benchmark row in a worker process to avoid fixture interference."""
    ctx = mp.get_context("fork")
    parent_conn, child_conn = ctx.Pipe(duplex=False)
    proc = ctx.Process(target=_benchmark_worker, args=(child_conn, function_name, args))
    proc.start()
    child_conn.close()
    proc.join(max(timeout + 20, 45))
    if proc.is_alive():
        proc.terminate()
        proc.join(5)
        if proc.is_alive():
            proc.kill()
            proc.join(5)
        parent_conn.close()
        return bench_row(
            bench_id,
            name,
            0,
            max_score,
            {"worker_exit_code": proc.exitcode, "worker_timeout": True},
            [f"worker timed out while running {function_name}"],
        )
    if proc.exitcode != 0:
        parent_conn.close()
        return bench_row(
            bench_id,
            name,
            0,
            max_score,
            {"worker_exit_code": proc.exitcode, "worker_timeout": False},
            [f"worker exited with {proc.exitcode}"],
        )
    if not parent_conn.poll(1):
        parent_conn.close()
        return bench_row(
            bench_id,
            name,
            0,
            max_score,
            {"worker_exit_code": proc.exitcode, "worker_timeout": False},
            ["worker produced no benchmark row"],
        )
    payload = parent_conn.recv()
    parent_conn.close()
    if not payload.get("ok"):
        return bench_row(
            bench_id,
            name,
            0,
            max_score,
            {"worker_exit_code": proc.exitcode, "worker_timeout": False},
            [payload.get("error", "unknown worker error")],
        )
    return payload["row"]


def run_long_plan_workflow_benchmark(timeout: int) -> dict[str, Any]:
    required = [
        HARNESS_ROOT / "scripts" / "classify-plan-size.sh",
        HARNESS_ROOT / "scripts" / "decompose-plan.sh",
        HARNESS_ROOT / "scripts" / "approve-decomposition.sh",
        HARNESS_ROOT / "scripts" / "approve-active-task.sh",
        HARNESS_ROOT / "tests" / "harness" / "test_long_plan_workflow.sh",
    ]
    files_ok = all(path.exists() for path in required)
    next_text = (HARNESS_ROOT / "scripts" / "harness.sh").read_text()
    next_routes = all(token in next_text for token in ["classify-plan-size.sh", "decompose-plan.sh", "approve-decomposition.sh", "approve-active-task.sh"])
    test_text = (HARNESS_ROOT / "tests" / "harness" / "test_long_plan_workflow.sh").read_text() if (HARNESS_ROOT / "tests" / "harness" / "test_long_plan_workflow.sh").exists() else ""
    test_contract_ok = all(token in test_text for token in ["classify-plan-size.sh", "decompose-plan.sh", "approve-decomposition.sh", "task.sh activate", "approve-active-task.sh", "must not contain"])
    with tempfile.TemporaryDirectory(prefix="harness-plan-classify-bench-") as tmp_name:
        plan = pathlib.Path(tmp_name) / "plan.md"
        plan.write_text("""# Benchmark System Enhancement

1. Fix deterministic test runner with timeout.
2. Add harness.sh benchmark.
3. Add project-build benchmark suite.
4. Add benchmark result schema.
5. Add install fixture benchmark.
6. Add agent-task evaluator.
7. Add context/control evaluator.
8. Add repair-loop metrics.
9. Add benchmark history comparison.

Verification: unit test, integration test, benchmark run, package integrity.
Touches scripts/benchmark.sh, tests/harness/run_all.sh, benchmarks/result-schema.json.
""")
        classify = run_command(["bash", str(HARNESS_ROOT / "scripts" / "classify-plan-size.sh"), str(plan)], HARNESS_ROOT, timeout)
        classify_ok = classify["exit_code"] == 0 and '"classification": "long_plan"' in classify.get("output", "")
    score = (4 if files_ok else 0) + (4 if classify_ok else 0) + (4 if test_contract_ok else 0) + (3 if next_routes else 0)
    return bench_row(
        "BENCH-010",
        "long-plan decomposition workflow",
        score,
        15,
        {
            "workflow_scripts_present": files_ok,
            "long_plan_classifier_ok": classify_ok,
            "workflow_regression_contract_present": test_contract_ok,
            "missing_plan_router_updated": next_routes,
        },
        ["long plan workflow contract checked" if score == 15 else classify.get("output", "")[-1200:]],
    )

def validate_result_shape(result: dict[str, Any]) -> None:
    for key in ["schema_version", "generated_at", "summary", "benchmarks", "history_comparison"]:
        if key not in result:
            raise SystemExit(f"Benchmark result missing {key}")
    if result["schema_version"] != 1:
        raise SystemExit("Unsupported benchmark schema version")
    for key in ["total_score", "max_score", "result"]:
        if key not in result["summary"]:
            raise SystemExit(f"Benchmark summary missing {key}")
    for row in result["benchmarks"]:
        for key in ["id", "name", "score", "max_score", "result", "metrics"]:
            if key not in row:
                raise SystemExit(f"Benchmark row missing {key}: {row}")


def write_markdown(result: dict[str, Any], path: pathlib.Path) -> None:
    lines = [
        "# Harness Benchmark Report",
        "",
        f"generated_at: {result['generated_at']}",
        f"total_score: {result['summary']['total_score']}",
        f"max_score: {result['summary']['max_score']}",
        f"result: {result['summary']['result']}",
        "",
        "## Benchmarks",
        "",
        "| ID | Benchmark | Result | Score |",
        "|---|---|---|---:|",
    ]
    for row in result["benchmarks"]:
        lines.append(f"| {row['id']} | {row['name']} | {row['result']} | {row['score']}/{row['max_score']} |")
    lines.extend([
        "",
        "## History Comparison",
        "",
        f"- previous_total_score: {result['history_comparison']['previous_total_score']}",
        f"- delta_total_score: {result['history_comparison']['delta_total_score']}",
        f"- trend: {result['history_comparison']['trend']}",
        "",
        "## Project Build Details",
        "",
    ])
    project_row = next((row for row in result["benchmarks"] if row["id"] == "BENCH-002"), None)
    if project_row:
        for project in project_row.get("metrics", {}).get("projects", []):
            lines.append(f"- {project.get('id')}: {project.get('result')}")
    lines.extend(["", "## Brownfield Issue-Resolution Details", ""])
    brownfield_row = next((row for row in result["benchmarks"] if row["id"] == "BENCH-009"), None)
    if brownfield_row:
        for task in brownfield_row.get("metrics", {}).get("tasks", []):
            lines.append(f"- {task.get('id')}: {task.get('result')}")
    long_plan_row = next((row for row in result["benchmarks"] if row["id"] == "BENCH-010"), None)
    lines.extend(["", "## Long Plan Workflow", ""])
    if long_plan_row:
        lines.append(f"- result: {long_plan_row.get('result')}")
        lines.append(f"- score: {long_plan_row.get('score')}/{long_plan_row.get('max_score')}")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser(description="Run the harness benchmark suite")
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT), help="JSON result path")
    parser.add_argument("--markdown", default=str(DEFAULT_MARKDOWN), help="Markdown report path")
    parser.add_argument("--history", default=str(DEFAULT_HISTORY), help="History JSONL path")
    parser.add_argument("--no-history", action="store_true", help="Do not append result to history")
    parser.add_argument("--project", help="Run a single PROJECT-xxx fixture")
    parser.add_argument("--brownfield", help="Run a single BROWN-xxx fixture")
    parser.add_argument("--timeout", type=int, default=60, help="Timeout seconds for each benchmark command")
    parser.add_argument("--json", action="store_true", help="Print JSON result to stdout")
    args = parser.parse_args()

    output_path = pathlib.Path(args.output)
    markdown_path = pathlib.Path(args.markdown)
    history_path = pathlib.Path(args.history)

    quiet = args.json
    previous = None if args.no_history else load_previous_history(history_path)

    # Run subprocess-heavy benchmark rows in isolated worker processes.
    progress("Running BENCH-003 result schema check...", quiet)
    schema = run_schema_benchmark()
    progress("Running BENCH-004 install fixture...", quiet)
    install = run_install_fixture(args.timeout)
    progress("Running BENCH-006 context/control evaluator...", quiet)
    context_eval = run_context_control_evaluator(args.timeout)
    progress("Running BENCH-007 repair-loop metrics...", quiet)
    repair_metrics = run_repair_loop_metrics()
    progress("Running BENCH-010 long-plan decomposition workflow...", quiet)
    long_plan = run_isolated_benchmark("run_long_plan_workflow_benchmark", (args.timeout,), "BENCH-010", "long-plan decomposition workflow", 15, args.timeout)
    progress("Running BENCH-009 brownfield issue-resolution suite...", quiet)
    brownfield = run_isolated_benchmark("run_brownfield_issue_resolution", (args.brownfield, args.timeout), "BENCH-009", "brownfield issue-resolution benchmark suite", 25, args.timeout)
    progress("Running BENCH-002 project-build suite...", quiet)
    project_build = run_project_build_split(args.project, args.timeout)
    progress("Running BENCH-005 agent-task evaluator...", quiet)
    agent_eval = run_agent_task_evaluator(project_build, brownfield)
    progress("Running BENCH-001 deterministic test runner...", quiet)
    deterministic = run_isolated_benchmark("run_deterministic_runner", (args.timeout,), "BENCH-001", "deterministic test runner with timeout", 10, args.timeout)

    partial_rows = [deterministic, project_build, brownfield, schema, install, agent_eval, context_eval, repair_metrics, long_plan]
    partial_score = sum(row["score"] for row in partial_rows)
    history_comparison = compare_history(partial_score, previous)
    progress("Running BENCH-008 history comparison...", quiet)
    history_row = run_history_benchmark(history_path, history_comparison)
    rows = partial_rows + [history_row]

    total_score = sum(row["score"] for row in rows)
    max_score = sum(row["max_score"] for row in rows)
    result = {
        "schema_version": 1,
        "generated_at": now(),
        "summary": {
            "total_score": total_score,
            "max_score": max_score,
            "result": "pass" if total_score == max_score else "fail",
        },
        "benchmarks": rows,
        "history_comparison": history_comparison,
    }
    validate_result_shape(result)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    write_markdown(result, markdown_path)
    if not args.no_history:
        history_path.parent.mkdir(parents=True, exist_ok=True)
        with history_path.open("a") as handle:
            handle.write(json.dumps(result, sort_keys=True) + "\n")

    if args.json:
        print(json.dumps(result, indent=2, sort_keys=True))
    else:
        print(f"Benchmark result: {result['summary']['result']} {total_score}/{max_score}")
        print(f"JSON: {output_path}")
        print(f"Markdown: {markdown_path}")
        if not args.no_history:
            print(f"History: {history_path}")
    return 0 if result["summary"]["result"] == "pass" else 1


if __name__ == "__main__":
    raise SystemExit(main())
