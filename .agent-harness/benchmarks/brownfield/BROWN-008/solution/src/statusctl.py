#!/usr/bin/env python3
import argparse
import json

def collect_status(name: str) -> dict:
    return {"name": name, "status": "ok", "replicas": 3}

def main(argv=None) -> int:
    parser = argparse.ArgumentParser(prog="statusctl")
    parser.add_argument("name")
    parser.add_argument("--json", action="store_true", help="print machine-readable JSON")
    args = parser.parse_args(argv)
    row = collect_status(args.name)
    if args.json:
        print(json.dumps(row, sort_keys=True))
    else:
        print(f"{row['name']} {row['status']} replicas={row['replicas']}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
