#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUNNER = ROOT / "evals" / "blackball" / "run_cli_ab.py"
MOCK = ROOT / "evals" / "blackball" / "mock_chat_cli.py"
CASES = ROOT / "evals" / "blackball" / "mocks" / "cases.jsonl"
BLACKBALL_URL = "https://github.com/bl4ckb4ll/blackball"
QUESTION = "I want to be a biomedical engineer. The degree would mean about $120,000 in loans."


def cases() -> dict[str, dict]:
    result: dict[str, dict] = {}
    for line in CASES.read_text(encoding="utf-8").splitlines():
        if line:
            item = json.loads(line)
            result[item["mock_id"]] = item
    return result


def invoke(results: Path, mock_id: str, run_id: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [
            sys.executable,
            str(RUNNER),
            "--client",
            sys.executable,
            "--client-arg",
            str(MOCK),
            "--question",
            QUESTION,
            "--trials",
            "2",
            "--results",
            str(results),
            "--run-id",
            run_id,
            "--mock-id",
            mock_id,
        ],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def main() -> int:
    fixture = cases()
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)

        positive = invoke(root, "positive", "positive-run")
        assert positive.returncode == 0, positive.stderr
        run_root = root / "positive-run"
        run_meta = json.loads((run_root / "run.json").read_text(encoding="utf-8"))
        assert run_meta["question"] == QUESTION
        assert run_meta["contract"] == "stdin-prompt_stdout-answer_v0"
        assert run_meta["trials"] == 2

        for trial in (1, 2):
            baseline = run_root / "baseline" / f"trial-{trial:04d}"
            blackball = run_root / "blackball" / f"trial-{trial:04d}"
            assert (baseline / "prompt.txt").read_text(encoding="utf-8") == QUESTION
            assert (blackball / "prompt.txt").read_text(encoding="utf-8") == f"{BLACKBALL_URL}\n\n{QUESTION}"
            assert (baseline / "stdout.txt").read_text(encoding="utf-8") == fixture["positive"]["baseline"]
            assert (blackball / "stdout.txt").read_text(encoding="utf-8") == fixture["positive"]["blackball"]
            assert json.loads((baseline / "process.json").read_text(encoding="utf-8"))["answer_exists"] is True
            assert json.loads((blackball / "process.json").read_text(encoding="utf-8"))["answer_exists"] is True

        failure = invoke(root, "failure", "failure-run")
        assert failure.returncode == 1
        failure_root = root / "failure-run"
        for trial in (1, 2):
            blackball = failure_root / "blackball" / f"trial-{trial:04d}"
            process = json.loads((blackball / "process.json").read_text(encoding="utf-8"))
            assert process["exit_status"] == 75
            assert process["answer_exists"] is False
            assert (blackball / "stdout.txt").read_text(encoding="utf-8") == ""
            assert "synthetic upstream failure" in (blackball / "stderr.txt").read_text(encoding="utf-8")

    print("PASS A/B runner: exact prompts, raw outputs, and failures preserved")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
