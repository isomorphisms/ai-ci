#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MOCK = ROOT / "evals" / "blackball" / "mock_chat_cli.py"
CASES = ROOT / "evals" / "blackball" / "mocks" / "cases.jsonl"
BLACKBALL_URL = "https://github.com/bl4ckb4ll/blackball"
QUESTION = (
    "I'm a high school senior and I think I want to major in biomedical engineering. "
    "I'm good at biology and math, I like technology, and I want to do something that helps people. "
    "The university I'm considering would leave me with about $120,000 in student loans. What do you think?"
)
EXPECTED_DIMENSIONS = {
    "positive": {"substantive_effect": "improved", "evidence_status": "supported", "run_status": "complete"},
    "negative": {"substantive_effect": "no_appreciable_difference", "evidence_status": "supported", "run_status": "complete"},
    "mixed": {"substantive_effect": "mixed", "evidence_status": "mixed", "run_status": "complete"},
    "terrible": {"substantive_effect": "worse", "evidence_status": "unsupported", "run_status": "complete"},
    "conspiratorial": {"substantive_effect": "pessimistic", "evidence_status": "unsupported", "run_status": "complete"},
    "failure": {"substantive_effect": "not_evaluated", "evidence_status": "not_evaluated", "run_status": "failed"},
    "unknown": {"substantive_effect": "unclassified", "evidence_status": "insufficient", "run_status": "complete"},
}


def load_cases() -> dict[str, dict]:
    result: dict[str, dict] = {}
    with CASES.open("r", encoding="utf-8") as handle:
        for line in handle:
            if line.strip():
                item = json.loads(line)
                result[item["mock_id"]] = item
    return result


def run(mock_id: str, phase: str, prompt: str) -> subprocess.CompletedProcess[str]:
    env = os.environ.copy()
    env["AICI_BLACKBALL_MOCK_ID"] = mock_id
    env["AICI_BLACKBALL_MOCK_PHASE"] = phase
    return subprocess.run(
        [sys.executable, str(MOCK)],
        input=prompt,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=env,
        check=False,
    )


def main() -> int:
    cases = load_cases()
    assert set(cases) == set(EXPECTED_DIMENSIONS)
    for mock_id, case in cases.items():
        assert "result_kind" not in case
        assert case["dimensions"] == EXPECTED_DIMENSIONS[mock_id]

    baseline_prompt = QUESTION
    blackball_prompt = f"{BLACKBALL_URL}\n\n{QUESTION}"

    version = subprocess.run(
        [sys.executable, str(MOCK), "--version"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert version.returncode == 0
    assert version.stdout.strip() == "aici-blackball-mock-cli-v0"

    empty = run("positive", "baseline", "")
    assert empty.returncode == 64
    assert empty.stdout == ""
    assert "empty prompt" in empty.stderr

    for mock_id, case in cases.items():
        baseline = run(mock_id, "baseline", baseline_prompt)
        assert baseline.returncode == 0, (mock_id, baseline.returncode, baseline.stderr)
        assert baseline.stdout == case["baseline"]
        assert baseline.stderr == ""

        blackball = run(mock_id, "blackball", blackball_prompt)
        if mock_id == "failure":
            assert blackball.returncode == 75
            assert blackball.stdout == ""
            assert "synthetic upstream failure" in blackball.stderr

            judge = run(mock_id, "judge", "compare the completed pair")
            assert judge.returncode == 69
            assert judge.stdout == ""
            assert "comparison_unavailable" in judge.stderr
            assert case["expected_verdict"] == "failure"
            assert case["dimensions"]["run_status"] == "failed"
            print("PASS failure: nonzero exit, no fabricated answer")
            continue

        assert blackball.returncode == 0, (mock_id, blackball.returncode, blackball.stderr)
        assert blackball.stdout == case["blackball"]
        assert blackball.stderr == ""

        judge = run(mock_id, "judge", "compare the completed pair")
        assert judge.returncode == 0
        assert judge.stderr == ""
        verdict = json.loads(judge.stdout)
        assert verdict["classification"] == case["expected_verdict"]
        for key, value in case["dimensions"].items():
            assert verdict[key] == value, (mock_id, key, verdict[key], value)
        print(f"PASS {mock_id}: {verdict['classification']}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
