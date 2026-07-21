#!/usr/bin/env python3
import argparse
import json
from pathlib import Path

def repair_metrics(run: dict) -> dict:
    attempts = run.get("repair_attempts", [])
    last_failure = attempts[-1].get("failure_reason") if attempts else None
    return {
        "repair_attempts": len(attempts),
        "last_failure_reason": last_failure,
        "final_status": run.get("final_status", run.get("summary", {}).get("result", "unknown")),
    }

def summarize(run: dict) -> str:
    summary = run.get("summary", {})
    metrics = repair_metrics(run)
    return "\n".join([
        "# Repair Report",
        "",
        f"task_id: {run.get('task_id', 'unknown')}",
        f"result: {summary.get('result', 'unknown')}",
        f"repair_attempts: {metrics['repair_attempts']}",
        f"last_failure_reason: {metrics['last_failure_reason']}",
        f"final_status: {metrics['final_status']}",
        "",
    ])

def main(argv=None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    parser.add_argument("output")
    args = parser.parse_args(argv)
    Path(args.output).write_text(summarize(json.loads(Path(args.input).read_text())))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
