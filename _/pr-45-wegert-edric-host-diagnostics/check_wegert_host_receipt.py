#!/usr/bin/env python3
"""Validate staged Wegert Edric -> GLSL hosted-x86_64 diagnostic receipts."""

from __future__ import annotations

import argparse
import csv
import re
import sys
from pathlib import Path

STAGES = [
    ("host", "HOST_ENV"),
    ("handwritten_glsl", "WEGERT_GLSL_BASELINE"),
    ("host_c_fallback", "WEGERT_X86_C_FALLBACK"),
    ("edric_bootstrap", "EDRIC_BOOTSTRAP"),
    ("edric_compiler_api", "EDRIC_COMPILER_API"),
    ("glsles_backend_build", "GLSLES_BACKEND_BUILD"),
    ("wegert_idr_compile", "WEGERT_IDR_TO_GLSL"),
    ("generated_idr_glsl_validate", "GENERATED_IDR_GLSL_VALIDATE"),
    ("wegert_idric_compile", "WEGERT_IDRIC_TO_GLSL"),
    ("generated_idric_glsl_validate", "GENERATED_IDRIC_GLSL_VALIDATE"),
]

VALID_STATUS = {"PASS", "FAIL", "SKIP"}
SHA40 = re.compile(r"^[0-9a-f]{40}$")


class ReceiptError(Exception):
    pass


def read_tsv(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))


def validate_receipt(path: Path) -> dict[str, str]:
    rows = read_tsv(path)
    if [row.get("stage") for row in rows] != [stage for stage, _ in STAGES]:
        raise ReceiptError("receipt stage order/schema does not match Wegert host v1")

    status: dict[str, str] = {}
    for row, (stage, code) in zip(rows, STAGES):
        actual_status = row.get("status", "")
        if actual_status not in VALID_STATUS:
            raise ReceiptError(f"{stage}: invalid status {actual_status!r}")
        if row.get("code") != code:
            raise ReceiptError(f"{stage}: expected code {code}, found {row.get('code')}")
        witness = row.get("witness", "")
        if not witness.startswith("logs/") or not witness.endswith(".log"):
            raise ReceiptError(f"{stage}: witness must be a logs/*.log path")
        status[stage] = actual_status

    def require_skips_if_not_pass(prerequisite: str, downstream: list[str]) -> None:
        if status[prerequisite] == "PASS":
            return
        for stage in downstream:
            if status[stage] != "SKIP":
                raise ReceiptError(
                    f"{stage}: must be SKIP because {prerequisite} is {status[prerequisite]}"
                )

    require_skips_if_not_pass(
        "edric_bootstrap",
        [
            "edric_compiler_api",
            "glsles_backend_build",
            "wegert_idr_compile",
            "generated_idr_glsl_validate",
            "wegert_idric_compile",
            "generated_idric_glsl_validate",
        ],
    )
    require_skips_if_not_pass(
        "edric_compiler_api",
        [
            "glsles_backend_build",
            "wegert_idr_compile",
            "generated_idr_glsl_validate",
            "wegert_idric_compile",
            "generated_idric_glsl_validate",
        ],
    )
    require_skips_if_not_pass(
        "glsles_backend_build",
        [
            "wegert_idr_compile",
            "generated_idr_glsl_validate",
            "wegert_idric_compile",
            "generated_idric_glsl_validate",
        ],
    )
    require_skips_if_not_pass("wegert_idr_compile", ["generated_idr_glsl_validate"])
    require_skips_if_not_pass("wegert_idric_compile", ["generated_idric_glsl_validate"])

    # These three are deliberately independent baselines. A failure in one must
    # not force the Edric compiler chain to be skipped, because that would hide
    # useful evidence about an unrelated boundary.
    return status


def validate_components(path: Path) -> None:
    rows = read_tsv(path)
    expected = {
        "wegert": "isomorphismes/wegert",
        "idric": "isomorphisms/Idric",
        "shader_backend": "isomorphisms/idris-shader-backend",
    }
    found: dict[str, str] = {}
    for row in rows:
        component = row.get("component", "")
        if component in found:
            raise ReceiptError(f"duplicate component row: {component}")
        repository = row.get("repository", "")
        revision = row.get("revision", "")
        if component not in expected:
            raise ReceiptError(f"unknown component row: {component}")
        if repository != expected[component]:
            raise ReceiptError(
                f"{component}: expected repository {expected[component]}, found {repository}"
            )
        if not SHA40.fullmatch(revision):
            raise ReceiptError(f"{component}: revision is not a full 40-hex commit")
        found[component] = revision
    if set(found) != set(expected):
        missing = sorted(set(expected) - set(found))
        raise ReceiptError(f"missing component rows: {', '.join(missing)}")


def validate_diagnosis(path: Path, status: dict[str, str]) -> None:
    text = path.read_text(encoding="utf-8")
    values: dict[str, str] = {}
    for line in text.splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            values[key.strip()] = value.strip()

    precision = values.get("float_precision")
    if precision not in {"default", "highp", "mediump"}:
        raise ReceiptError(f"invalid or missing float_precision: {precision!r}")

    failures = sum(1 for value in status.values() if value == "FAIL")
    if values.get("failures") != str(failures):
        raise ReceiptError(
            f"diagnosis failure count {values.get('failures')!r} does not match receipt {failures}"
        )

    first_fail = next((stage for stage, _ in STAGES if status[stage] == "FAIL"), "none")
    if values.get("first_failure") != first_fail:
        raise ReceiptError(
            f"diagnosis first_failure {values.get('first_failure')!r} does not match {first_fail}"
        )

    all_pass = all(status[stage] == "PASS" for stage, _ in STAGES)
    classification = values.get("classification", "")
    if all_pass and classification != "HOST_EDRIC_GLSL_PATH_PASS":
        raise ReceiptError("all-pass receipt must classify as HOST_EDRIC_GLSL_PATH_PASS")
    if not all_pass and classification == "HOST_EDRIC_GLSL_PATH_PASS":
        raise ReceiptError("non-passing receipt cannot classify as HOST_EDRIC_GLSL_PATH_PASS")

    if "ICK boundary: NOT_USED" not in text:
        raise ReceiptError("diagnosis must keep ICK explicitly outside the hosted tuple")


def validate(receipt: Path, diagnosis: Path, components: Path) -> None:
    status = validate_receipt(receipt)
    validate_diagnosis(diagnosis, status)
    validate_components(components)


def run_self_test(directory: Path) -> None:
    cases = [
        ("pass", True),
        ("bootstrap-fail", True),
        ("bad-dependent-stage", False),
    ]
    for name, should_pass in cases:
        root = directory / name
        try:
            validate(root / "receipt.tsv", root / "diagnosis.txt", root / "components.tsv")
        except (OSError, ReceiptError) as error:
            if should_pass:
                raise ReceiptError(f"self-test {name} unexpectedly failed: {error}") from error
        else:
            if not should_pass:
                raise ReceiptError(f"self-test {name} unexpectedly passed")
    print("Wegert host diagnostic self-test: PASS")


def main() -> int:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)

    verify = sub.add_parser("verify")
    verify.add_argument("receipt", type=Path)
    verify.add_argument("diagnosis", type=Path)
    verify.add_argument("components", type=Path)

    self_test = sub.add_parser("self-test")
    self_test.add_argument("directory", type=Path)

    args = parser.parse_args()
    try:
        if args.command == "verify":
            validate(args.receipt, args.diagnosis, args.components)
            print("Wegert host diagnostic receipt: PASS")
        else:
            run_self_test(args.directory)
    except (OSError, ReceiptError) as error:
        print(f"Wegert host diagnostic receipt: FAIL: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
