#!/usr/bin/env python3
"""Resolve moving upstream refs into a reproducible source lock.

`fingerprint` identifies firmware-source/recipe inputs that can change the
resulting firmware. Build orchestration and provenance are recorded separately
so CI/tooling churn does not create a new firmware release by itself.
"""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import re
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any


def git_head(url: str, ref: str) -> str:
    if re.fullmatch(r"[0-9a-fA-F]{40}", ref):
        return ref.lower()
    output = subprocess.check_output(
        ["git", "ls-remote", "--exit-code", url, ref], text=True
    )
    matches = []
    for line in output.splitlines():
        sha, found_ref = line.split("\t", 1)
        if found_ref == ref:
            matches.append(sha)
    if len(matches) != 1:
        raise RuntimeError(f"Expected one match for {url} {ref}, got {len(matches)}")
    return matches[0]


def digest(payload: Any) -> str:
    canonical = json.dumps(payload, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(canonical.encode()).hexdigest()


def firmware_identity(
    version: str,
    projects: list[dict[str, str]],
    resources: dict[str, dict[str, str]],
    customization_sha256: str,
) -> dict[str, Any]:
    """Return only inputs that define the firmware release identity.

    The manifest repository HEAD, host build environment and git-repo tool are
    provenance. They are deliberately excluded: if the resolved firmware
    project commits, modem packages and local firmware recipe are unchanged,
    users should not receive another firmware release merely because build
    tooling moved.
    """
    modemfeed = resources.get("modemfeed")
    if not modemfeed:
        raise RuntimeError("The modemfeed resource is required")

    return {
        "friendlywrt_version": version,
        "projects": [
            {"path": project["path"], "commit": project["commit"]}
            for project in projects
        ],
        "modemfeed_commit": modemfeed["commit"],
        "customization_sha256": customization_sha256,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest-file", required=True)
    parser.add_argument("--manifest-url", required=True)
    parser.add_argument("--manifest-branch", required=True)
    parser.add_argument("--manifest-commit", required=True)
    parser.add_argument("--project-base-url", required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--customization-sha256", required=True)
    parser.add_argument("--provenance-sha256", required=True)
    parser.add_argument("--resource", action="append", default=[])
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    tree = ET.parse(args.manifest_file)
    root = tree.getroot()
    default = root.find("default")
    default_revision = default.get("revision") if default is not None else None
    default_remote = default.get("remote") if default is not None else None
    remote_revisions = {
        remote.get("name"): remote.get("revision") for remote in root.findall("remote")
    }

    projects = []
    for element in root.findall("project"):
        name = element.get("name")
        path = element.get("path") or name
        remote_name = element.get("remote") or default_remote
        revision = (
            element.get("revision")
            or remote_revisions.get(remote_name)
            or default_revision
        )
        if not name or not path or not revision:
            raise RuntimeError(f"Incomplete project entry in {args.manifest_file}")
        url = f"{args.project_base_url.rstrip('/')}/{name}.git"
        projects.append(
            {
                "name": name,
                "path": path,
                "url": url,
                "ref": revision,
                "commit": git_head(url, revision),
            }
        )
    projects.sort(key=lambda item: item["path"])

    resources = {}
    for value in args.resource:
        try:
            name, url, ref = value.split("|", 2)
        except ValueError as exc:
            raise RuntimeError(f"Invalid --resource value: {value}") from exc
        resources[name] = {
            "url": url,
            "ref": ref,
            "commit": git_head(url, ref),
        }

    identity = firmware_identity(
        args.version, projects, resources, args.customization_sha256
    )

    payload: dict[str, Any] = {
        "schema": 2,
        "friendlywrt_version": args.version,
        "manifest": {
            "url": args.manifest_url,
            "branch": args.manifest_branch,
            "file": Path(args.manifest_file).name,
            "commit": args.manifest_commit,
        },
        "projects": projects,
        "resources": dict(sorted(resources.items())),
        "customization_sha256": args.customization_sha256,
        "provenance_sha256": args.provenance_sha256,
        "firmware_identity": identity,
    }
    payload["fingerprint"] = digest(identity)

    provenance_payload = {
        key: value
        for key, value in payload.items()
        if key not in {"fingerprint", "provenance_fingerprint", "generated_at"}
    }
    payload["provenance_fingerprint"] = digest(provenance_payload)
    payload["generated_at"] = dt.datetime.now(dt.timezone.utc).replace(
        microsecond=0
    ).isoformat().replace("+00:00", "Z")

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
