#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

HERE = Path(__file__).resolve().parent
CASES = HERE / "mocks" / "cases.jsonl"
PREFIX = "aici-blackball-mock"


def load_cases(path: Path = CASES) -> dict[str, dict]:
    result: dict[str, dict] = {}
    with path.open("r", encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, 1):
            if not line.strip():
                continue
            item = json.loads(line)
            mock_id = item.get("mock_id")
            if not isinstance(mock_id, str) or not mock_id:
                raise ValueError(f"{path}:{line_number}: missing mock_id")
            if mock_id in result:
                raise ValueError(f"{path}:{line_number}: duplicate mock_id {mock_id}")
            result[mock_id] = item
    return result


def parse_command(text: str) -> tuple[str, str]:
    words = text.strip().split()
    if len(words) != 3 or words[0] != PREFIX:
        raise ValueError(f"input must be: {PREFIX} <mock_id> <baseline|blackball|judge>")
    phase = words[2]
    if phase not in {"baseline", "blackball", "judge"}:
        raise ValueError(f"unsupported phase: {phase}")
    return words[1], phase


def output_text(case: dict, phase: str) -> str:
    if phase == "baseline":
        return case["baseline"]
    if phase == "blackball":
        if "blackball_error" in case:
            error = case["blackball_error"]
            raise MockHTTPError(int(error["status"]), str(error["type"]), str(error["message"]))
        return case["blackball"]
    judge = case.get("judge")
    if judge is None:
        raise MockHTTPError(409, "comparison_unavailable", "judge cannot run because a required generation failed")
    return json.dumps(judge, ensure_ascii=False, separators=(",", ":"))


class MockHTTPError(Exception):
    def __init__(self, status: int, error_type: str, message: str):
        super().__init__(message)
        self.status = status
        self.error_type = error_type
        self.message = message


def response_payload(mock_id: str, phase: str, text: str) -> dict:
    return {
        "id": f"resp_mock_{mock_id}_{phase}",
        "object": "response",
        "created_at": 0,
        "status": "completed",
        "model": "chat-latest-mock",
        "output": [
            {
                "id": f"msg_mock_{mock_id}_{phase}",
                "type": "message",
                "status": "completed",
                "role": "assistant",
                "content": [{"type": "output_text", "text": text, "annotations": []}],
            }
        ],
        "usage": {"input_tokens": 0, "output_tokens": 0, "total_tokens": 0},
    }


class Handler(BaseHTTPRequestHandler):
    cases = load_cases()

    def log_message(self, format: str, *args) -> None:
        return

    def send_json(self, status: int, payload: dict) -> None:
        raw = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)

    def do_POST(self) -> None:
        if self.path != "/v1/responses":
            self.send_json(404, {"error": {"type": "not_found", "message": "mock only serves /v1/responses"}})
            return
        try:
            length = int(self.headers.get("Content-Length", "0"))
            request = json.loads(self.rfile.read(length).decode("utf-8"))
            input_value = request.get("input")
            if not isinstance(input_value, str):
                raise ValueError("mock requires string input")
            mock_id, phase = parse_command(input_value)
            case = self.cases.get(mock_id)
            if case is None:
                raise ValueError(f"unknown mock_id: {mock_id}")
            text = output_text(case, phase)
            self.send_json(200, response_payload(mock_id, phase, text))
        except MockHTTPError as exc:
            self.send_json(exc.status, {"error": {"type": exc.error_type, "message": exc.message}})
        except (ValueError, KeyError, json.JSONDecodeError) as exc:
            self.send_json(400, {"error": {"type": "invalid_request_error", "message": str(exc)}})


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8787)
    args = parser.parse_args()
    server = ThreadingHTTPServer((args.host, args.port), Handler)
    print(f"mock responses endpoint: http://{args.host}:{server.server_port}/v1/responses", flush=True)
    server.serve_forever()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
