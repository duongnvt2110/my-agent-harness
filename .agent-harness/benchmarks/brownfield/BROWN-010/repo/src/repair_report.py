#!/usr/bin/env python3
import argparse
import json
from pathlib import Path

def summarize(run: dict) -> str:
    summary = run.get("summary", {})
    return "\n".join([
        "# Repair Report",
        "",
        f"task_id: {run.get('task_id', 'unknown')}",
        f"result: {summary.get('result', 'unknown')}",
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
