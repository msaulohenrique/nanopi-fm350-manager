#!/usr/bin/env python3
"""Small dependency-free query helper for source-lock.json."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("lock")
    subparsers = parser.add_subparsers(dest="command", required=True)

    get_parser = subparsers.add_parser("get")
    get_parser.add_argument("key")

    resource_parser = subparsers.add_parser("resource")
    resource_parser.add_argument("name")
    resource_parser.add_argument("field")

    projects_parser = subparsers.add_parser("projects")
    projects_parser.add_argument("paths", nargs="*")

    args = parser.parse_args()
    data = json.loads(Path(args.lock).read_text(encoding="utf-8"))

    if args.command == "get":
        value = data
        for part in args.key.split("."):
            value = value[part]
        print(value)
    elif args.command == "resource":
        print(data["resources"][args.name][args.field])
    else:
        wanted = set(args.paths)
        for project in data["projects"]:
            if not wanted or project["path"] in wanted:
                print(
                    "\t".join(
                        [
                            project["path"],
                            project["url"],
                            project["ref"],
                            project["commit"],
                        ]
                    )
                )


if __name__ == "__main__":
    main()
