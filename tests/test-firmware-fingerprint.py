#!/usr/bin/env python3
"""Regression tests for firmware release identity semantics."""

from __future__ import annotations

import importlib.util
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "resolve_lock", ROOT / "scripts" / "resolve-lock.py"
)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class FirmwareFingerprintTests(unittest.TestCase):
    def setUp(self) -> None:
        self.projects = [
            {
                "name": "friendlywrt",
                "path": "friendlywrt",
                "url": "https://example.invalid/friendlywrt.git",
                "ref": "refs/heads/openwrt-25.12",
                "commit": "1" * 40,
            },
            {
                "name": "kernel-rockchip",
                "path": "kernel",
                "url": "https://example.invalid/kernel.git",
                "ref": "refs/heads/linux-6.1",
                "commit": "2" * 40,
            },
        ]
        self.resources = {
            "modemfeed": {
                "url": "https://example.invalid/modemfeed.git",
                "ref": "refs/heads/master",
                "commit": "3" * 40,
            },
            "build_env": {
                "url": "https://example.invalid/build-env.git",
                "ref": "refs/heads/master",
                "commit": "4" * 40,
            },
            "repo_tool": {
                "url": "https://example.invalid/git-repo.git",
                "ref": "refs/heads/stable",
                "commit": "5" * 40,
            },
        }

    def identity(self, projects=None, resources=None, customization="a" * 64):
        return MODULE.firmware_identity(
            "25.12",
            projects or self.projects,
            resources or self.resources,
            customization,
        )

    def test_build_tool_changes_do_not_change_firmware_identity(self) -> None:
        before = MODULE.digest(self.identity())
        resources = {name: dict(value) for name, value in self.resources.items()}
        resources["build_env"]["commit"] = "6" * 40
        resources["repo_tool"]["commit"] = "7" * 40
        after = MODULE.digest(self.identity(resources=resources))
        self.assertEqual(before, after)

    def test_project_url_or_ref_changes_do_not_change_identity_at_same_commit(self) -> None:
        before = MODULE.digest(self.identity())
        projects = [dict(project) for project in self.projects]
        projects[0]["url"] = "https://mirror.invalid/friendlywrt.git"
        projects[0]["ref"] = "refs/tags/equivalent-source"
        after = MODULE.digest(self.identity(projects=projects))
        self.assertEqual(before, after)

    def test_effective_project_commit_changes_identity(self) -> None:
        before = MODULE.digest(self.identity())
        projects = [dict(project) for project in self.projects]
        projects[1]["commit"] = "8" * 40
        after = MODULE.digest(self.identity(projects=projects))
        self.assertNotEqual(before, after)

    def test_modemfeed_commit_changes_identity(self) -> None:
        before = MODULE.digest(self.identity())
        resources = {name: dict(value) for name, value in self.resources.items()}
        resources["modemfeed"]["commit"] = "9" * 40
        after = MODULE.digest(self.identity(resources=resources))
        self.assertNotEqual(before, after)

    def test_local_firmware_recipe_changes_identity(self) -> None:
        before = MODULE.digest(self.identity())
        after = MODULE.digest(self.identity(customization="b" * 64))
        self.assertNotEqual(before, after)


if __name__ == "__main__":
    unittest.main()
