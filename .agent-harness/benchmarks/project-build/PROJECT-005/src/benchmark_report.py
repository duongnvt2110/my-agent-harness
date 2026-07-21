#!/usr/bin/env python3
import argparse
import json
import pathlib


def render(data: dict) -> str:
    summary = data.get("summary", {})
    lines = [
        "# Benchmark Report",
        "",
        f"total_score: {summary.get('total_score', 0)}",
        f"max_score: {summary.get('max_score', 0)}",
        f"result: {summary.get('result', 'unknown')}",
        "",
        "| ID | Result | Score |",
        "|---|---|---:|",
    ]
    for row in data.get("benchmarks", []):
        lines.append(f"| {row['id']} | {row['result']} | {row['score']}/{row['max_score']} |")
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    parser.add_argument("output")
    args = parser.parse_args()
    data = json.loads(pathlib.Path(args.input).read_text())
    pathlib.Path(args.output).write_text(render(data))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
