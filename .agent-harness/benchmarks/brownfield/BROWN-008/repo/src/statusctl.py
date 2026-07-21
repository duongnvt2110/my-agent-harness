#!/usr/bin/env python3
import argparse

def collect_status(name: str) -> dict:
    return {"name": name, "status": "ok", "replicas": 3}

def main(argv=None) -> int:
    parser = argparse.ArgumentParser(prog="statusctl")
    parser.add_argument("name")
    args = parser.parse_args(argv)
    row = collect_status(args.name)
    print(f"{row['name']} {row['status']} replicas={row['replicas']}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
