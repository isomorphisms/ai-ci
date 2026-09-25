#!/usr/bin/env python3
"""Run a literal before/after Blackball pair through a replaceable chat command."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import pathlib
import subprocess

BLACKBALL_URL = "https://github.com/bl4ckb4ll/blackball"


def args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--client", required=True, help="executable to invoke for each fresh answer")
    parser.add_argument("--client-arg", action="append", default=[], help="repeatable argument passed to client")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--question")
    group.add_argument("--question-file", type=pathlib.Path)
    parser.add_argument("--trials", type=int, default=1)
    parser.add_argument("--results", type=pathlib.Path, default=pathlib.Path("blackball-cli-results"))
    parser.add_argument("--run-id", default=None)
    parser.add_argument(
        "--mock-id",
        default=None,
        help="development only: select AICI mock fixture without changing client arguments",
    )
    return parser.parse_args()


def now() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat()


def write_json(path: pathlib.Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def question_text(ns: argparse.Namespace) -> str:
    if ns.question is not None:
        return ns.question
    return ns.question_file.read_text(encoding="utf-8")


def prompt_for(question: str, condition: str) -> str:
    if condition == "baseline":
        return question
    if condition == "blackball":
        return f"{BLACKBALL_URL}\n\n{question}"
    raise ValueError(condition)


def run_client(ns: argparse.Namespace, prompt: str, condition: str) -> subprocess.CompletedProcess[str]:
    env = os.environ.copy()
    if ns.mock_id is not None:
        env["AICI_BLACKBALL_MOCK_ID"] = ns.mock_id
        env["AICI_BLACKBALL_MOCK_PHASE"] = condition
    return subprocess.run(
        [ns.client, *ns.client_arg],
        input=prompt,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=env,
        check=False,
    )


def main() -> int:
    ns = args()
    if ns.trials < 1:
        raise SystemExit("--trials must be at least 1")
    question = question_text(ns)
    if not question:
        raise SystemExit("question must not be empty")

    run_id = ns.run_id or dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    root = ns.results / run_id
    write_json(
        root / "run.json",
        {
            "run_id": run_id,
            "created_at": now(),
            "question": question,
            "blackball_url": BLACKBALL_URL,
            "client": ns.client,
            "client_args": ns.client_arg,
            "trials": ns.trials,
            "mock_id": ns.mock_id,
            "contract": "stdin-prompt_stdout-answer_v0",
        },
    )

    any_failure = False
    for trial in range(1, ns.trials + 1):
        # Alternate order so a stateful or rate-limited client cannot always give
        # one condition the first request. Each invocation is still a new process.
        order = ("baseline", "blackball") if trial % 2 else ("blackball", "baseline")
        for condition in order:
            prompt = prompt_for(question, condition)
            started_at = now()
            completed = run_client(ns, prompt, condition)
            finished_at = now()
            sample = root / condition / f"trial-{trial:04d}"
            sample.mkdir(parents=True, exist_ok=True)
            (sample / "prompt.txt").write_text(prompt, encoding="utf-8")
            (sample / "stdout.txt").write_text(completed.stdout, encoding="utf-8")
            (sample / "stderr.txt").write_text(completed.stderr, encoding="utf-8")
            write_json(
                sample / "process.json",
                {
                    "condition": condition,
                    "trial": trial,
                    "started_at": started_at,
                    "finished_at": finished_at,
                    "exit_status": completed.returncode,
                    "answer_exists": completed.returncode == 0,
                },
            )
            if completed.returncode != 0:
                any_failure = True
                print(f"FAIL {condition} trial {trial}: exit {completed.returncode}")
            else:
                print(f"PASS {condition} trial {trial}")

    return 1 if any_failure else 0


if __name__ == "__main__":
    raise SystemExit(main())
