#!/usr/bin/env python3
"""Fresh-chat stdin/stdout adapter for the OpenAI Responses API."""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request

DEFAULT_BASE_URL = "https://api.openai.com/v1"


def response_text(payload: dict) -> str:
    direct = payload.get("output_text")
    if isinstance(direct, str) and direct:
        return direct

    parts: list[str] = []
    output = payload.get("output")
    if isinstance(output, list):
        for item in output:
            if not isinstance(item, dict) or item.get("type") != "message":
                continue
            content = item.get("content")
            if not isinstance(content, list):
                continue
            for part in content:
                if isinstance(part, dict) and part.get("type") == "output_text":
                    text = part.get("text")
                    if isinstance(text, str) and text:
                        parts.append(text)
    return "\n".join(parts)


def error_message(raw: bytes) -> str:
    text = raw.decode("utf-8", errors="replace")
    try:
        payload = json.loads(text)
        error = payload.get("error")
        if isinstance(error, dict) and isinstance(error.get("message"), str):
            return error["message"]
    except json.JSONDecodeError:
        pass
    return text.strip() or "empty error response"


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: openai_responses_cli.py MODEL", file=sys.stderr)
        return 2

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        print("OPENAI_API_KEY is required", file=sys.stderr)
        return 2

    prompt = sys.stdin.read()
    if not prompt:
        print("prompt on stdin must not be empty", file=sys.stderr)
        return 2

    model = sys.argv[1]
    base_url = os.environ.get("AICI_OPENAI_BASE_URL", DEFAULT_BASE_URL).rstrip("/")
    request = urllib.request.Request(
        f"{base_url}/responses",
        data=json.dumps({"model": model, "input": prompt, "store": False}).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            payload = json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        print(f"OpenAI Responses HTTP {exc.code}: {error_message(exc.read())}", file=sys.stderr)
        return 1
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError) as exc:
        print(f"OpenAI Responses request failed: {exc}", file=sys.stderr)
        return 1

    if payload.get("status") != "completed":
        print(f"OpenAI Responses request did not complete: {payload.get('status')!r}", file=sys.stderr)
        return 1

    text = response_text(payload)
    if not text:
        print("OpenAI Responses request completed without output_text", file=sys.stderr)
        return 1

    sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
