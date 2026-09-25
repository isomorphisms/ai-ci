#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import subprocess
import sys
import threading
import urllib.error
import urllib.request
from http.server import ThreadingHTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "evals" / "blackball"))

from mock_openai_responses import Handler, load_cases  # noqa: E402

OPENAI_CLIENT = ROOT / "evals" / "blackball" / "openai_responses_cli.py"
EXPECTED_DIMENSIONS = {
    "positive": {"substantive_effect": "improved", "evidence_status": "supported", "run_status": "complete"},
    "negative": {"substantive_effect": "no_appreciable_difference", "evidence_status": "supported", "run_status": "complete"},
    "mixed": {"substantive_effect": "mixed", "evidence_status": "mixed", "run_status": "complete"},
    "terrible": {"substantive_effect": "worse", "evidence_status": "unsupported", "run_status": "complete"},
    "conspiratorial": {"substantive_effect": "pessimistic", "evidence_status": "unsupported", "run_status": "complete"},
    "failure": {"substantive_effect": "not_evaluated", "evidence_status": "not_evaluated", "run_status": "failed"},
    "unknown": {"substantive_effect": "unclassified", "evidence_status": "insufficient", "run_status": "complete"},
}


def post(port: int, text: str) -> tuple[int, dict]:
    request = urllib.request.Request(
        f"http://127.0.0.1:{port}/v1/responses",
        data=json.dumps({"model": "chat-latest", "input": text}).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=5) as response:
            return response.status, json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        return exc.code, json.loads(exc.read().decode("utf-8"))


def extract_text(payload: dict) -> str:
    return payload["output"][0]["content"][0]["text"]


def invoke_openai_client(port: int, text: str) -> subprocess.CompletedProcess[str]:
    env = os.environ.copy()
    env["OPENAI_API_KEY"] = "acceptance-test-key"
    env["AICI_OPENAI_BASE_URL"] = f"http://127.0.0.1:{port}/v1"
    return subprocess.run(
        [sys.executable, str(OPENAI_CLIENT), "chat-latest"],
        input=text,
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

    server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    port = server.server_port

    try:
        for mock_id, case in cases.items():
            status, baseline = post(port, f"aici-blackball-mock {mock_id} baseline")
            assert status == 200, (mock_id, status, baseline)
            assert extract_text(baseline) == case["baseline"]

            status, blackball = post(port, f"aici-blackball-mock {mock_id} blackball")
            if mock_id == "failure":
                assert status == 503
                assert blackball["error"]["type"] == "server_error"
                assert case["expected_verdict"] == "failure"
                assert case["dimensions"]["run_status"] == "failed"
                status, judge = post(port, f"aici-blackball-mock {mock_id} judge")
                assert status == 409
                assert judge["error"]["type"] == "comparison_unavailable"
                print(f"PASS {mock_id}: failure remains failure")
                continue

            assert status == 200, (mock_id, status, blackball)
            assert extract_text(blackball) == case["blackball"]
            status, judge_payload = post(port, f"aici-blackball-mock {mock_id} judge")
            assert status == 200
            judge = json.loads(extract_text(judge_payload))
            assert judge["classification"] == case["expected_verdict"], (mock_id, judge)
            for key, value in case["dimensions"].items():
                assert judge[key] == value, (mock_id, key, judge[key], value)
            print(f"PASS {mock_id}: {judge['classification']}")

        live_boundary = invoke_openai_client(port, "aici-blackball-mock positive baseline")
        assert live_boundary.returncode == 0, live_boundary.stderr
        assert live_boundary.stdout == cases["positive"]["baseline"]
        assert live_boundary.stderr == ""

        live_failure = invoke_openai_client(port, "aici-blackball-mock failure blackball")
        assert live_failure.returncode != 0
        assert live_failure.stdout == ""
        assert "OpenAI Responses HTTP 503" in live_failure.stderr
        print("PASS OpenAI Responses CLI: stdout answer and nonzero/no-answer contract preserved")
    finally:
        server.shutdown()
        server.server_close()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
