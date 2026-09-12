#!/usr/bin/env python3
"""Deterministic, non-gating observations of compiler-backend source surfaces."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path
import sys

MATRIX_FIELDS = ("backend", "metric", "path", "needle")
OUTPUT_FIELDS = ("backend", "metric", "readable", "present", "path", "needle")


def load_matrix(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        if reader.fieldnames != list(MATRIX_FIELDS):
            raise ValueError(
                f"{path}: expected TSV header {list(MATRIX_FIELDS)!r}, "
                f"received {reader.fieldnames!r}"
            )
        rows: list[dict[str, str]] = []
        seen: set[tuple[str, str]] = set()
        for line_number, row in enumerate(reader, start=2):
            if any(not row[field] for field in MATRIX_FIELDS):
                raise ValueError(f"{path}:{line_number}: empty required field")
            key = (row["backend"], row["metric"])
            if key in seen:
                raise ValueError(
                    f"{path}:{line_number}: duplicate backend/metric {key!r}"
                )
            seen.add(key)
            rows.append({field: row[field] for field in MATRIX_FIELDS})
    return sorted(rows, key=lambda row: (row["backend"], row["metric"]))


def parse_roots(values: list[str]) -> dict[str, Path]:
    roots: dict[str, Path] = {}
    for value in values:
        if "=" not in value:
            raise ValueError(f"--root must be BACKEND=PATH, received {value!r}")
        backend, raw_path = value.split("=", 1)
        if not backend or not raw_path:
            raise ValueError(f"--root must be BACKEND=PATH, received {value!r}")
        if backend in roots:
            raise ValueError(f"duplicate --root for {backend!r}")
        roots[backend] = Path(raw_path)
    return roots


def observe(
    rows: list[dict[str, str]], roots: dict[str, Path]
) -> list[dict[str, str]]:
    observations: list[dict[str, str]] = []
    for row in rows:
        backend = row["backend"]
        if backend not in roots:
            raise ValueError(f"matrix backend {backend!r} has no --root")
        source = roots[backend] / row["path"]
        try:
            text = source.read_text(encoding="utf-8")
        except (OSError, UnicodeError):
            readable = "0"
            present = "0"
        else:
            readable = "1"
            present = "1" if row["needle"] in text else "0"
        observations.append(
            {
                "backend": backend,
                "metric": row["metric"],
                "readable": readable,
                "present": present,
                "path": row["path"],
                "needle": row["needle"],
            }
        )
    return observations


def write_tsv(observations: list[dict[str, str]], handle) -> None:
    writer = csv.DictWriter(
        handle, fieldnames=OUTPUT_FIELDS, delimiter="\t", lineterminator="\n"
    )
    writer.writeheader()
    writer.writerows(observations)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument("--matrix", type=Path, required=True)
    parser.add_argument(
        "--root",
        action="append",
        default=[],
        metavar="BACKEND=PATH",
        help="checkout root for one backend; repeat for each backend",
    )
    parser.add_argument(
        "--output",
        default="-",
        help="output TSV path, or - for stdout",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        rows = load_matrix(args.matrix)
        roots = parse_roots(args.root)
        observations = observe(rows, roots)
    except ValueError as error:
        print(f"probe configuration error: {error}", file=sys.stderr)
        return 2

    if args.output == "-":
        write_tsv(observations, sys.stdout)
    else:
        with Path(args.output).open("w", encoding="utf-8", newline="") as handle:
            write_tsv(observations, handle)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
