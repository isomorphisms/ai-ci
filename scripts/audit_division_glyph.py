#!/usr/bin/env python3
"""Read-only first-party division-glyph source audit.

This scans tracked C, Lua and .idric files, recording arithmetic ASCII-slash
candidates and literal U+00F7 divisions outside strings/comments. It does NOT
replace source, certify a compiler, or claim every slash denotes division.
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
from pathlib import Path

LANGUAGES = {".c": "c", ".lua": "lua", ".idric": "idric"}
EXCLUDED = {
    ".git", ".build", "build", "dist", "out", "vendor", "third_party",
    "third-party", "external", "node_modules", "upstream", "generated",
}
_LONG_BRACKET = re.compile(r"\[(=*)\[")


def classify(path: Path) -> str | None:
    if path.suffix.lower() not in LANGUAGES:
        return None
    if any(part in EXCLUDED for part in path.parts[:-1]):
        return None
    return LANGUAGES[path.suffix.lower()]


def scan_text(text: str, language: str) -> list[dict[str, int | str]]:
    """Emit operator candidates; inspect source, never make substitutions."""
    hits: list[dict[str, int | str]] = []
    i, line, column, n = 0, 1, 1, len(text)
    quote = ""
    state = "code"
    long_end = ""
    nested_blocks = 0
    directive = False
    continued_directive = False

    def advance(count: int = 1) -> None:
        nonlocal i, line, column, directive, continued_directive
        for _ in range(count):
            if i >= n:
                return
            c = text[i]
            if c == "\n":
                # C preprocessor continuation keeps this logical line hidden.
                directive = continued_directive if language == "c" else False
                continued_directive = False
                line += 1
                column = 1
            else:
                column += 1
            i += 1

    while i < n:
        c = text[i]
        two = text[i:i + 2]
        if state == "line_comment":
            if c == "\n":
                state = "code"
            advance()
            continue
        if state == "block_comment":
            if two == "*/":
                advance(2)
                state = "code"
            else:
                advance()
            continue
        if state == "idric_comment":
            if two == "{-":
                nested_blocks += 1
                advance(2)
            elif two == "-}":
                nested_blocks -= 1
                advance(2)
                if nested_blocks == 0:
                    state = "code"
            else:
                advance()
            continue
        if state == "long_string":
            if text.startswith(long_end, i):
                advance(len(long_end))
                state = "code"
            else:
                advance()
            continue
        if state == "quote":
            if c == "\\":
                advance(2)
            elif c == quote:
                advance()
                state = "code"
            else:
                advance()
            continue

        if language == "c":
            if c == "#" and not text[text.rfind("\n", 0, i) + 1:i].strip():
                directive = True
            if directive:
                if c == "\\" and i + 1 < n and text[i + 1] == "\n":
                    continued_directive = True
                advance()
                continue
            if two == "//":
                state = "line_comment"
                advance(2)
                continue
            if two == "/*":
                state = "block_comment"
                advance(2)
                continue
        elif language == "lua":
            if two == "--":
                m = _LONG_BRACKET.match(text, i + 2)
                if m:
                    long_end = "]" + m.group(1) + "]"
                    state = "long_string"
                    advance(2 + len(m.group(0)))
                else:
                    state = "line_comment"
                    advance(2)
                continue
            m = _LONG_BRACKET.match(text, i) if c == "[" else None
            if m:
                long_end = "]" + m.group(1) + "]"
                state = "long_string"
                advance(len(m.group(0)))
                continue
        elif language == "idric":
            if two == "--":
                state = "line_comment"
                advance(2)
                continue
            if two == "{-":
                state = "idric_comment"
                nested_blocks = 1
                advance(2)
                continue
        if c in ('"', "'"):
            quote = c
            state = "quote"
            advance()
            continue
        if c == "÷":
            hits.append({"line": line, "column": column, "kind": "division_glyph"})
            advance()
            continue
        if c == "/":
            if language == "lua" and two == "//":
                hits.append({"line": line, "column": column, "kind": "lua_floor_division"})
                advance(2)
                continue
            if two == "/=":
                kind = "compound_division" if language == "c" else "non_arithmetic_slash_equals"
                hits.append({"line": line, "column": column, "kind": kind})
                advance(2)
                continue
            hits.append({"line": line, "column": column, "kind": "ascii_division_candidate"})
            advance()
            continue
        advance()
    return hits


def tracked_paths(root: Path) -> list[Path]:
    try:
        result = subprocess.run(
            ["git", "-C", str(root), "ls-files", "-z"],
            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, check=True,
        )
        return [Path(p.decode("utf-8", "surrogateescape"))
                for p in result.stdout.split(b"\0") if p]
    except (OSError, subprocess.CalledProcessError):
        return [p.relative_to(root) for p in root.rglob("*") if p.is_file()]


def audit(root: Path, profile: str) -> dict:
    findings, counts = [], {"files": 0, "glyph": 0, "ascii": 0, "compound": 0, "floor": 0}
    for path in tracked_paths(root):
        language = classify(path)
        if language is None or (profile != "all" and profile != language):
            continue
        absolute = root / path
        if not absolute.is_file() or absolute.is_symlink():
            continue
        try:
            source = absolute.read_text(encoding="utf-8")
        except (UnicodeError, OSError):
            findings.append({"path": str(path), "kind": "UNREADABLE"})
            continue
        counts["files"] += 1
        for hit in scan_text(source, language):
            kind = hit["kind"]
            if kind == "division_glyph":
                counts["glyph"] += 1
            elif kind == "ascii_division_candidate":
                counts["ascii"] += 1
            elif kind == "compound_division":
                counts["compound"] += 1
            elif kind == "lua_floor_division":
                counts["floor"] += 1
            findings.append({"path": str(path), "language": language, **hit})
    return {"root": str(root), "profile": profile, "counts": counts,
            "findings": findings, "note": (
                "Candidates need ownership and compiler-pin review; "
                "this is lexical source evidence, not compiler execution.")}


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("root", type=Path)
    p.add_argument("--profile", choices=["all", "c", "lua", "idric"],
                   default="all")
    p.add_argument("--fail-on-ascii", action="store_true",
                   help="Only for repos already qualified with the glyph compiler.")
    args = p.parse_args()
    result = audit(args.root.resolve(), args.profile)
    print(json.dumps(result, ensure_ascii=False, sort_keys=True, indent=2))
    return 1 if args.fail_on_ascii and result["counts"]["ascii"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
