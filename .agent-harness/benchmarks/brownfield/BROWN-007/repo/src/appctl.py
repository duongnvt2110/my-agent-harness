#!/usr/bin/env python3
import argparse

def main(argv=None) -> int:
    parser = argparse.ArgumentParser(prog="appctl")
    sub = parser.add_subparsers(dest="command")
    deploy = sub.add_parser("deploy")
    deploy_sub = deploy.add_subparsers(dest="resource")
    service = deploy_sub.add_parser("service")
    service.add_argument("name")
    service.add_argument("--env")
    args = parser.parse_args(argv)
    if args.command == "deploy" and args.resource == "service":
        print(f"deploying service={args.name} env={args.env}")
        return 0
    parser.print_help()
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
