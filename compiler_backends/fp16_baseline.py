#!/usr/bin/env python3
"""Fail only when an established FP16/PowerVR observation regresses."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path
import sys

EXPECTED_FIELDS = ("metric", "expected_present")
OBSERVATION_FIELDS = ("backend", "metric", "readable", "present", "path", "needle")


def load_expected(path: Path) -> dict[str, str]:
    with path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        if reader.fieldnames != list(EXPECTED_FIELDS):
            raise ValueError(f"{path}: invalid expected-baseline header")
        expected: dict[str, str] = {}
        for line_number, row in enumerate(reader, start=2):
            metric = row["metric"]
            value = row["expected_present"]
            if not metric or value not in {"0", "1"}:
                raise ValueError(f"{path}:{line_number}: invalid baseline row")
            if metric in expected:
                raise ValueError(f"{path}:{line_number}: duplicate metric {metric!r}")
            expected[metric] = value
    return expected


def load_observations(path: Path) -> dict[str, dict[str, str]]:
    with path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        if reader.fieldnames != list(OBSERVATION_FIELDS):
            raise ValueError(f"{path}: invalid observation header")
        observations: dict[str, dict[str, str]] = {}
        for line_number, row in enumerate(reader, start=2):
            if row["backend"] != "idris-shader-backend":
                raise ValueError(f"{path}:{line_number}: unexpected backend {row['backend']!r}")
            metric = row["metric"]
            if metric in observations:
                raise ValueError(f"{path}:{line_number}: duplicate metric {metric!r}")
            observations[metric] = row
    return observations


def regressions(
    expected: dict[str, str], observations: dict[str, dict[str, str]]
) -> list[str]:
    failures: list[str] = []
    for metric, wanted in sorted(expected.items()):
        row = observations.get(metric)
        if row is None:
            failures.append(f"{metric}: missing observation")
            continue
        if row["readable"] != "1":
            failures.append(f"{metric}: source unreadable")
            continue
        if row["present"] != wanted:
            failures.append(
                f"{metric}: expected present={wanted}, observed present={row['present']}"
            )
    return failures


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--expected", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args(argv)

    try:
        expected = load_expected(args.expected)
        observations = load_observations(args.observations)
        failures = regressions(expected, observations)
    except (OSError, UnicodeError, ValueError) as error:
        print(f"FP16 baseline error: {error}", file=sys.stderr)
        return 2

    if failures:
        for failure in failures:
            print(f"FAIL  {failure}")
        return 1

    print(f"PASS  {len(expected)} established FP16/PowerVR observations")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
