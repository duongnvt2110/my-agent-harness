#!/usr/bin/env python3
import argparse
import json
import pathlib


def analyze(path: pathlib.Path) -> dict:
    count = 0
    errors = 0
    latency_total = 0.0
    for line in path.read_text().splitlines():
        if not line.strip():
            continue
        row = json.loads(line)
        count += 1
        if int(row.get("status", 0)) >= 500 or row.get("level") == "error":
            errors += 1
        latency_total += float(row.get("latency_ms", 0))
    avg = round(latency_total / count, 2) if count else 0
    return {"count": count, "errors": errors, "avg_latency_ms": avg}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    parser.add_argument("--output", default="-")
    args = parser.parse_args()
    data = analyze(pathlib.Path(args.input))
    text = json.dumps(data, sort_keys=True) + "\n"
    if args.output == "-":
        print(text, end="")
    else:
        pathlib.Path(args.output).write_text(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
