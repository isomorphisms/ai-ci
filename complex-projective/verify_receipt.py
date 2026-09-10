#!/usr/bin/env python3
"""Verify evidence claims for the complex/projective implementation hierarchy."""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path

SHA = re.compile(r"^[0-9a-f]{40}$")
ROLES = {"X86_LEADER", "THUMB_FOLLOWER", "SHADER_FOLLOWER", "APPLICATION_CONSUMER"}
STATUSES = {"PASS", "SKIP", "FAIL"}


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
    if not lines or lines[0] != "COMPLEX_PROJECTIVE_RECEIPT\t1":
        raise ReceiptError("CPR001 invalid receipt header")

    fields: dict[str, str] = {}
    stages: dict[str, Stage] = {}
    for line in lines[1:]:
        columns = line.split("\t")
        if columns[0] == "stage":
            if len(columns) not in (3, 4):
                raise ReceiptError("CPR002 malformed stage record")
            name, status = columns[1], columns[2]
            reason = columns[3] if len(columns) == 4 else ""
            if not name or name in stages:
                raise ReceiptError("CPR003 duplicate or empty stage")
            if status not in STATUSES:
                raise ReceiptError("CPR004 invalid stage status")
            if status == "SKIP" and not reason:
                raise ReceiptError("CPR005 skipped stage requires a reason")
            if status == "PASS" and reason:
                raise ReceiptError("CPR006 passing stage must not carry an excuse")
            stages[name] = Stage(name, status, reason)
            continue

        if len(columns) != 2 or not columns[0] or columns[0] in fields:
            raise ReceiptError("CPR007 malformed or duplicate field")
        fields[columns[0]] = columns[1]

    return Receipt(fields, stages)


def require_field(receipt: Receipt, name: str) -> str:
    value = receipt.fields.get(name, "")
    if not value:
        raise ReceiptError(f"CPR010 missing {name}")
    return value


def require_pass(receipt: Receipt, name: str) -> None:
    stage = receipt.stages.get(name)
    if stage is None:
        raise ReceiptError(f"CPR020 missing required stage {name}")
    if stage.status != "PASS":
        raise ReceiptError(f"CPR021 required stage {name} is {stage.status}")


def verify(receipt: Receipt) -> None:
    role = require_field(receipt, "role")
    if role not in ROLES:
        raise ReceiptError("CPR011 invalid role")
    require_field(receipt, "repository")
    source_head = require_field(receipt, "source_head_sha")
    tested_checkout = require_field(receipt, "tested_checkout_sha")
    if not SHA.fullmatch(source_head):
        raise ReceiptError("CPR012 source_head_sha is not a full SHA-1")
    if not SHA.fullmatch(tested_checkout):
        raise ReceiptError("CPR013 tested_checkout_sha is not a full SHA-1")
    if any(stage.status == "FAIL" for stage in receipt.stages.values()):
        raise ReceiptError("CPR014 acceptance receipt contains FAIL")

    if role == "X86_LEADER":
        for stage in (
            "direct_backend_generation",
            "native_execution",
            "numerical_corpus",
            "projective_corpus",
            "thin_debian_execution",
            "headless_render",
        ):
            require_pass(receipt, stage)

    elif role == "THUMB_FOLLOWER":
        if receipt.fields.get("implementation_status") != "PROVISIONAL_DISPOSABLE":
            raise ReceiptError("CPR030 Thumb follower is not marked provisional/disposable")
        require_pass(receipt, "qemu_complex_multiplication_execution")

    elif role == "SHADER_FOLLOWER":
        for stage in (
            "typed_ir_generation",
            "shader_generation",
            "shader_validation",
            "program_link",
        ):
            require_pass(receipt, stage)
        hardware_chain = (
            "shader_load",
            "gpu_execution",
            "framebuffer_capture",
            "vendor_device_receipt",
        )
        for index, name in enumerate(hardware_chain):
            stage = receipt.stages.get(name)
            if stage is None:
                raise ReceiptError(f"CPR040 missing hardware evidence stage {name}")
            if stage.status == "PASS":
                for prerequisite in hardware_chain[:index]:
                    require_pass(receipt, prerequisite)

    elif role == "APPLICATION_CONSUMER":
        require_pass(receipt, "shared_semantic_contract")


def verify_text(text: str) -> None:
    verify(parse(text))


def good_x86() -> str:
    return """COMPLEX_PROJECTIVE_RECEIPT\t1
role\tX86_LEADER
repository\tisomorphisms/idric-x86-aggressive-backend
source_head_sha\t1111111111111111111111111111111111111111
tested_checkout_sha\t2222222222222222222222222222222222222222
stage\tdirect_backend_generation\tPASS
stage\tnative_execution\tPASS
stage\tnumerical_corpus\tPASS
stage\tprojective_corpus\tPASS
stage\tthin_debian_execution\tPASS
stage\theadless_render\tPASS
"""


def good_thumb() -> str:
    return """COMPLEX_PROJECTIVE_RECEIPT\t1
role\tTHUMB_FOLLOWER
repository\tisomorphisms/idric-arm-thumb
source_head_sha\t1111111111111111111111111111111111111111
tested_checkout_sha\t2222222222222222222222222222222222222222
implementation_status\tPROVISIONAL_DISPOSABLE
stage\tqemu_complex_multiplication_execution\tPASS
stage\tprojective_corpus\tSKIP\tnot implemented by provisional follower
stage\tphysical_arm_device\tSKIP\tQEMU evidence only
"""


def good_shader() -> str:
    return """COMPLEX_PROJECTIVE_RECEIPT\t1
role\tSHADER_FOLLOWER
repository\tisomorphisms/idris-shader-backend
source_head_sha\t1111111111111111111111111111111111111111
tested_checkout_sha\t2222222222222222222222222222222222222222
stage\ttyped_ir_generation\tPASS
stage\tshader_generation\tPASS
stage\tshader_validation\tPASS
stage\tprogram_link\tPASS
stage\tshader_load\tSKIP\tno driver in CI
stage\tgpu_execution\tSKIP\tno driver in CI
stage\tframebuffer_capture\tSKIP\tno driver in CI
stage\tvendor_device_receipt\tSKIP\tno physical GPU in CI
"""


def good_application() -> str:
    return """COMPLEX_PROJECTIVE_RECEIPT\t1
role\tAPPLICATION_CONSUMER
repository\tisomorphismes/analytic-continuation
source_head_sha\t1111111111111111111111111111111111111111
tested_checkout_sha\t2222222222222222222222222222222222222222
stage\tshared_semantic_contract\tPASS
stage\tprojective_cp1_runtime\tSKIP\tfinite viewport does not require it
"""


def self_test() -> None:
    for name, text in {
        "x86": good_x86(),
        "thumb": good_thumb(),
        "shader": good_shader(),
        "application": good_application(),
    }.items():
        try:
            verify_text(text)
        except ReceiptError as error:
            raise AssertionError(f"good {name} fixture rejected: {error}") from error

    bad_cases = {
        "leader-skips-projective": good_x86().replace(
            "stage\tprojective_corpus\tPASS",
            "stage\tprojective_corpus\tSKIP\tnot ready",
        ),
        "thumb-not-provisional": good_thumb().replace(
            "implementation_status\tPROVISIONAL_DISPOSABLE\n", ""
        ),
        "shader-fakes-vendor": good_shader()
        .replace("stage\tshader_load\tSKIP\tno driver in CI", "stage\tshader_load\tSKIP\tno driver")
        .replace("stage\tvendor_device_receipt\tSKIP\tno physical GPU in CI", "stage\tvendor_device_receipt\tPASS"),
        "skip-without-reason": good_application().replace(
            "stage\tprojective_cp1_runtime\tSKIP\tfinite viewport does not require it",
            "stage\tprojective_cp1_runtime\tSKIP",
        ),
        "missing-source-head": good_x86().replace(
            "source_head_sha\t1111111111111111111111111111111111111111\n", ""
        ),
    }
    for name, text in bad_cases.items():
        try:
            verify_text(text)
        except ReceiptError:
            continue
        raise AssertionError(f"bad fixture accepted: {name}")

    print("complex/projective receipt policy: PASS")


def main(argv: list[str]) -> int:
    if len(argv) == 2 and argv[1] == "self-test":
        self_test()
        return 0
    if len(argv) == 3 and argv[1] == "verify":
        verify_text(Path(argv[2]).read_text())
        print("complex/projective receipt: PASS")
        return 0
    print(f"usage: {argv[0]} self-test | verify RECEIPT", file=sys.stderr)
    return 2


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv))
    except (ReceiptError, AssertionError) as error:
        print(error, file=sys.stderr)
        raise SystemExit(1)
