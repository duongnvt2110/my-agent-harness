#!/usr/bin/env python3
import argparse
import json
from pathlib import Path

def render(current: dict) -> str:
    summary = current.get("summary", {})
    lines = [
        "# Benchmark Report",
        "",
        f"total_score: {summary.get('total_score', 0)}",
        f"max_score: {summary.get('max_score', 0)}",
        f"result: {summary.get('result', 'unknown')}",
        "",
    ]
    return "\n".join(lines)

def main(argv=None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("current")
    parser.add_argument("output")
    args = parser.parse_args(argv)
    current = json.loads(Path(args.current).read_text())
    Path(args.output).write_text(render(current))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
