#!/usr/bin/env python3
"""Drop-in fake for a future fresh-chat command-line client.

Stable evaluator-facing contract:

    prompt bytes on stdin -> answer text on stdout

Success is exit 0. Diagnostics go to stderr. Any nonzero exit means there is no
answer to classify.

Mock-only environment variables select a deterministic fixture:

    AICI_BLACKBALL_MOCK_ID=positive
    AICI_BLACKBALL_MOCK_PHASE=baseline|blackball|judge

A real client does not need to implement or understand those variables.
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
CASES = HERE / "mocks" / "cases.jsonl"
EX_USAGE = 64
EX_UNAVAILABLE = 69
EX_TEMPFAIL = 75


def load_cases() -> dict[str, dict]:
    cases: dict[str, dict] = {}
    with CASES.open("r", encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, 1):
            if not line.strip():
                continue
            item = json.loads(line)
            mock_id = item.get("mock_id")
            if not isinstance(mock_id, str) or not mock_id:
                raise ValueError(f"{CASES}:{line_number}: missing mock_id")
            if mock_id in cases:
                raise ValueError(f"{CASES}:{line_number}: duplicate mock_id {mock_id}")
            cases[mock_id] = item
    return cases


def fail(code: int, message: str) -> int:
    print(message, file=sys.stderr)
    return code


def main() -> int:
    if sys.argv[1:] == ["--version"]:
        print("aici-blackball-mock-cli-v0")
        return 0
    if len(sys.argv) != 1:
        return fail(EX_USAGE, "mock_chat_cli.py takes no arguments; pass the prompt on stdin")

    try:
        prompt = sys.stdin.read()
    except UnicodeError as exc:
        return fail(EX_USAGE, f"stdin is not valid UTF-8 text: {exc}")
    if not prompt:
        return fail(EX_USAGE, "empty prompt")

    mock_id = os.environ.get("AICI_BLACKBALL_MOCK_ID")
    phase = os.environ.get("AICI_BLACKBALL_MOCK_PHASE")
    if not mock_id or phase not in {"baseline", "blackball", "judge"}:
        return fail(
            EX_USAGE,
            "set AICI_BLACKBALL_MOCK_ID and AICI_BLACKBALL_MOCK_PHASE=baseline|blackball|judge",
        )

    cases = load_cases()
    case = cases.get(mock_id)
    if case is None:
        return fail(EX_USAGE, f"unknown mock fixture: {mock_id}")

    if phase == "baseline":
        sys.stdout.write(case["baseline"])
        return 0

    if phase == "blackball":
        error = case.get("blackball_error")
        if error is not None:
            return fail(
                EX_TEMPFAIL,
                f"{error['type']}: {error['message']}",
            )
        sys.stdout.write(case["blackball"])
        return 0

    judge = case.get("judge")
    if judge is None:
        return fail(EX_UNAVAILABLE, "comparison_unavailable: required generation did not complete")
    sys.stdout.write(json.dumps(judge, ensure_ascii=False, separators=(",", ":")))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
