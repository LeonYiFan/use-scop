#!/usr/bin/env python3
"""Validate pinned route metadata, or check exports against current main."""
import argparse
from pathlib import Path
import re
import subprocess

import yaml


def validate(router, description, namespace, *, latest=False):
    metadata = dict(re.findall(r"^(Version|Date):\s*(\S+)", description, re.M))
    baseline = router["baseline"]
    if not latest:
        for field in ("version", "date"):
            if metadata.get(field.title()) != str(baseline[field]):
                raise ValueError(f"Pinned DESCRIPTION {field} does not match baseline")
    exports = set(re.findall(r"^export\([\"']?([\w.]+)[\"']?\)", namespace, re.M))
    routed = set()
    for domain in router["domains"].values():
        tasks = set()
        for route in domain["routes"]:
            if route["task"] in tasks or not route.get("use"):
                raise ValueError(f"Duplicate or empty route: {route['task']}")
            tasks.add(route["task"])
            for call in route["use"]:
                if not re.fullmatch(r"scop::[\w.]+", call):
                    raise ValueError(f"Invalid route: {call}")
                routed.add(call.split("::")[1])
    missing = routed - exports
    if missing:
        raise ValueError(f"Unexported routes: {', '.join(sorted(missing))}")
    if not latest:
        excluded = {entry["name"] for entry in router.get("known_unexported", [])}
        excluded.update(router.get("removed_from_routes", []))
        if excluded & exports:
            raise ValueError(f"Incorrect unexported metadata: {sorted(excluded & exports)}")
    return len(routed), metadata


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--latest", action="store_true")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    router = yaml.safe_load((root / "task_router.yaml").read_text(encoding="utf-8"))
    commit = router["baseline"]["main_commit"]
    if not re.fullmatch(r"[0-9a-f]{40}", commit):
        raise ValueError("baseline.main_commit must be a full Git commit")
    ref = "main" if args.latest else commit
    base = f"https://raw.githubusercontent.com/mengxu98/scop/{ref}"
    def fetch(name):
        return subprocess.check_output(
            ["curl", "-fsSL", "--retry", "2", "--max-time", "60", f"{base}/{name}"],
            text=True, encoding="utf-8",
        )
    count, metadata = validate(router, fetch("DESCRIPTION"), fetch("NAMESPACE"), latest=args.latest)
    print(f"PASS: {count} routed exports at {ref}; DESCRIPTION {metadata}")


if __name__ == "__main__":
    main()
