#!/usr/bin/env python3
"""Verify shader-codegen regression receipts."""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path

SHA = re.compile(r"^[0-9a-f]{40}$")
STATUSES = {"PASS", "SKIP", "FAIL"}
PRECISIONS = {"lowp", "mediump", "highp"}
INACTIVE_POLICIES = {"GUARDED_EXPANDED", "BOUNDED_LOOP", "EAGER"}


class ReceiptError(ValueError):
    pass


@dataclass(frozen=True)
class Stage:
    name: str
    status: str
    reason: str


@dataclass(frozen=True)
class Receipt:
    fields: dict[str, str]
    stages: dict[str, Stage]


def parse(text: str) -> Receipt:
    lines = [line for line in text.splitlines() if line and not line.startswith("#")]
    if not lines or lines[0] != "SHADER_CODEGEN_RECEIPT\t1":
        raise ReceiptError("SCR001 invalid receipt header")

    fields: dict[str, str] = {}
    stages: dict[str, Stage] = {}
    for line in lines[1:]:
        columns = line.split("\t")
        if columns[0] == "stage":
            if len(columns) not in (3, 4):
                raise ReceiptError("SCR002 malformed stage record")
            name, status = columns[1], columns[2]
            reason = columns[3] if len(columns) == 4 else ""
            if not name or name in stages:
                raise ReceiptError("SCR003 duplicate or empty stage")
            if status not in STATUSES:
                raise ReceiptError("SCR004 invalid stage status")
            if status == "SKIP" and not reason:
                raise ReceiptError("SCR005 skipped stage requires a reason")
            if status == "PASS" and reason:
                raise ReceiptError("SCR006 passing stage must not carry an excuse")
            stages[name] = Stage(name, status, reason)
            continue

        if len(columns) != 2 or not columns[0] or columns[0] in fields:
            raise ReceiptError("SCR007 malformed or duplicate field")
        fields[columns[0]] = columns[1]

    return Receipt(fields, stages)


def require_field(receipt: Receipt, name: str) -> str:
    value = receipt.fields.get(name, "")
    if not value:
        raise ReceiptError(f"SCR010 missing {name}")
    return value


def require_int(receipt: Receipt, name: str) -> int:
    raw = require_field(receipt, name)
    try:
        value = int(raw)
    except ValueError as error:
        raise ReceiptError(f"SCR011 {name} is not an integer") from error
    if value < 0:
        raise ReceiptError(f"SCR012 {name} is negative")
    return value


def require_pass(receipt: Receipt, name: str) -> None:
    stage = receipt.stages.get(name)
    if stage is None:
        raise ReceiptError(f"SCR020 missing required stage {name}")
    if stage.status != "PASS":
        raise ReceiptError(f"SCR021 required stage {name} is {stage.status}")


def verify_hardware_chain(receipt: Receipt) -> None:
    chain = (
        "driver_load",
        "gpu_execution",
        "framebuffer_capture",
        "vendor_device_receipt",
    )
    for index, name in enumerate(chain):
        stage = receipt.stages.get(name)
        if stage is None:
            raise ReceiptError(f"SCR030 missing hardware evidence stage {name}")
        if stage.status == "PASS":
            for prerequisite in chain[:index]:
                require_pass(receipt, prerequisite)

    interaction = receipt.stages.get("interaction_response")
    if interaction is None:
        raise ReceiptError("SCR031 missing interaction_response stage")
    if interaction.status == "PASS":
        require_pass(receipt, "gpu_execution")


def verify_analytic_continuation(receipt: Receipt) -> None:
    capacity = require_int(receipt, "logical_factor_capacity")
    per_factor = require_int(receipt, "expensive_ops_per_factor")
    eager_ops = require_int(receipt, "eager_expensive_ops")
    require_int(receipt, "static_atan_calls")
    require_int(receipt, "static_log_calls")
    require_int(receipt, "real_if_count")
    require_int(receipt, "ternary_select_count")

    if capacity != 64:
        raise ReceiptError("SCR040 analytic-continuation factor capacity must be 64")
    if per_factor != 2:
        raise ReceiptError("SCR041 analytic-continuation factor cost must record atan+log")
    if eager_ops != 0:
        raise ReceiptError("SCR042 inactive factor transcendental work is still eager")

    policy = require_field(receipt, "inactive_factor_policy")
    if policy not in INACTIVE_POLICIES:
        raise ReceiptError("SCR043 unknown inactive-factor policy")
    if policy == "EAGER":
        raise ReceiptError("SCR044 eager inactive-factor policy is forbidden")

    if policy == "GUARDED_EXPANDED":
        if require_int(receipt, "real_if_count") == 0:
            raise ReceiptError("SCR045 guarded-expanded code has no real control flow")
        if require_int(receipt, "ternary_select_count") != 0:
            raise ReceiptError("SCR046 guarded-expanded factor fold regressed to eager selects")


def verify(receipt: Receipt) -> None:
    producer = require_field(receipt, "producer_repository")
    backend = require_field(receipt, "backend_repository")
    if "/" not in producer or "/" not in backend:
        raise ReceiptError("SCR013 repository fields must use owner/name")

    for name in ("source_head_sha", "backend_sha"):
        if not SHA.fullmatch(require_field(receipt, name)):
            raise ReceiptError(f"SCR014 {name} is not a full SHA-1")

    precision = require_field(receipt, "precision")
    if precision not in PRECISIONS:
        raise ReceiptError("SCR015 precision must be lowp, mediump, or highp")

    if any(stage.status == "FAIL" for stage in receipt.stages.values()):
        raise ReceiptError("SCR016 acceptance receipt contains FAIL")

    for stage in ("typed_ir_generation", "shader_generation", "shader_validation"):
        require_pass(receipt, stage)

    workload = require_field(receipt, "workload")
    if workload == "analytic-continuation-factor-fold-v1":
        verify_analytic_continuation(receipt)

    verify_hardware_chain(receipt)


def verify_text(text: str) -> None:
    verify(parse(text))


def fixture(*, precision: str = "lowp", policy: str = "GUARDED_EXPANDED", eager: int = 0,
            real_if: int = 68, ternary: int = 0) -> str:
    return f"""SHADER_CODEGEN_RECEIPT\t1
producer_repository\tisomorphismes/analytic-continuation
source_head_sha\tc7e0a2d8e05daec101f785a61cad9aeefe7230d7
backend_repository\tisomorphisms/idris-shader-backend
backend_sha\te4dd4ef1a51a81d2b0ab03655f81e2ae7037bc9c
workload\tanalytic-continuation-factor-fold-v1
precision\t{precision}
inactive_factor_policy\t{policy}
logical_factor_capacity\t64
expensive_ops_per_factor\t2
eager_expensive_ops\t{eager}
static_atan_calls\t64
static_log_calls\t64
real_if_count\t{real_if}
ternary_select_count\t{ternary}
stage\ttyped_ir_generation\tPASS
stage\tshader_generation\tPASS
stage\tshader_validation\tPASS
stage\tprogram_link\tPASS
stage\tdriver_load\tSKIP\thardware result not imported into this receipt
stage\tgpu_execution\tSKIP\thardware result not imported into this receipt
stage\tframebuffer_capture\tSKIP\thardware result not imported into this receipt
stage\tvendor_device_receipt\tSKIP\thardware result not imported into this receipt
stage\tinteraction_response\tSKIP\thardware result not imported into this receipt
"""


def self_test() -> None:
    # Structural success is independent of precision class.
    verify_text(fixture(precision="lowp"))
    verify_text(fixture(precision="highp"))
    verify_text(fixture(precision="mediump"))

    bad_cases = {
        "old-eager-codegen": fixture(policy="EAGER", eager=124, real_if=0, ternary=68),
        "precision-only-is-not-a-fix": fixture(precision="lowp", policy="EAGER", eager=124, real_if=0, ternary=68),
        "guarded-regressed-to-selects": fixture(policy="GUARDED_EXPANDED", ternary=68),
        "fake-device-receipt": fixture().replace(
            "stage\tvendor_device_receipt\tSKIP\thardware result not imported into this receipt",
            "stage\tvendor_device_receipt\tPASS",
        ),
        "skip-without-reason": fixture().replace(
            "stage\tdriver_load\tSKIP\thardware result not imported into this receipt",
            "stage\tdriver_load\tSKIP",
        ),
    }

    for name, text in bad_cases.items():
        try:
            verify_text(text)
        except ReceiptError:
            continue
        raise AssertionError(f"bad fixture accepted: {name}")

    print("shader codegen receipt policy: PASS")


def main(argv: list[str]) -> int:
    if len(argv) == 2 and argv[1] == "self-test":
        self_test()
        return 0
    if len(argv) == 3 and argv[1] == "verify":
        verify_text(Path(argv[2]).read_text())
        print("shader codegen receipt: PASS")
        return 0
    print(f"usage: {argv[0]} self-test | verify RECEIPT", file=sys.stderr)
    return 2


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv))
    except (ReceiptError, AssertionError) as error:
        print(error, file=sys.stderr)
        raise SystemExit(1)
