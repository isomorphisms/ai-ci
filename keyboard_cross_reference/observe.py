#!/usr/bin/env python3
"""Deterministic cross-reference for the hardware and phone programmer keyboards."""

from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path
import re
import sys
import unicodedata

MAP_FIELDS = ("hardware_board", "software_page", "mode")
OUTPUT_FIELDS = (
    "hardware_board",
    "software_page",
    "relation",
    "concept",
)

HARDWARE_HEADER_RE = re.compile(
    r'(?m)^([A-Za-z_][A-Za-z0-9_]*)\s*:\s*Board\s*\n'
    r'\1\s*=\s*MkBoard\s+"((?:\\.|[^"\\])*)"'
)
HARDWARE_KEY_RE = re.compile(
    r'\b(one|two|three)\s+((?:"(?:\\.|[^"\\])*"\s*)+)'
)
STRING_RE = re.compile(r'"((?:\\.|[^"\\])*)"')
SOFTWARE_PAGE_RE = re.compile(
    r'(?m)^\s*[\[,]\s*Page\s+"((?:\\.|[^"\\])*)"'
)
SOFTWARE_KEY_RE = re.compile(
    r'\b(?:text_key|pair_key|Key)\s+"((?:\\.|[^"\\])*)"'
)

DISPLAY_PREFIXES = {"𝔽", "DD", "CC", "SS"}
PURE_SYMBOL_ALIASES = {
    "λ": "LAMBDA",
    "ƒ": "FUNCTION",
}
WORD_ALIASES = {
    "PAIRED": "PAIR",
    "QUOTES": "QUOTE",
    "DELIMITERS": "DELIMITER",
    "SPACES": "SPACE",
    "CHARACTERS": "CHARACTER",
}


def decode_string(body: str) -> str:
    try:
        return json.loads(f'"{body}"')
    except json.JSONDecodeError as error:
        raise ValueError(f"unsupported quoted string {body!r}") from error


def has_symbol_or_punctuation(value: str) -> bool:
    return any(
        unicodedata.category(character)[0] in {"P", "S"}
        for character in value
        if not character.isspace()
    )


def normalize_concept(label: str) -> str:
    """Discard display glyphs while preserving the semantic words on a key."""

    lines = [line.strip() for line in label.strip().splitlines() if line.strip()]
    if not lines:
        return ""

    if len(lines) > 1 and (
        lines[0] in DISPLAY_PREFIXES or has_symbol_or_punctuation(lines[0])
    ):
        lines = lines[1:]

    value = unicodedata.normalize("NFKC", " ".join(lines)).strip()
    value = PURE_SYMBOL_ALIASES.get(value, value)
    value = re.sub(
        r"(?<=[^\W\d_])(?=\d)|(?<=\d)(?=[^\W\d_])",
        " ",
        value,
        flags=re.UNICODE,
    )
    words = re.findall(r"[^\W_]+", value.upper(), flags=re.UNICODE)
    words = [WORD_ALIASES.get(word, word) for word in words]
    return " ".join(words)


def parse_hardware(text: str) -> dict[str, set[str]]:
    headers = list(HARDWARE_HEADER_RE.finditer(text))
    if not headers:
        raise ValueError("hardware source contains no Board definitions")

    boards: dict[str, set[str]] = {}
    for index, header in enumerate(headers):
        name = header.group(1)
        if name in boards:
            raise ValueError(f"duplicate hardware board {name!r}")
        block_end = (
            headers[index + 1].start() if index + 1 < len(headers) else len(text)
        )
        block = text[header.end() : block_end]
        concepts: set[str] = set()

        for match in HARDWARE_KEY_RE.finditer(block):
            constructor = match.group(1)
            expected = {"one": 1, "two": 2, "three": 3}[constructor]
            pieces = [decode_string(body) for body in STRING_RE.findall(match.group(2))]
            if len(pieces) != expected:
                raise ValueError(
                    f"{name}: {constructor} key has {len(pieces)} labels, expected {expected}"
                )
            concept = normalize_concept(" ".join(pieces))
            if concept:
                concepts.add(concept)

        boards[name] = concepts

    return boards


def parse_software(text: str) -> dict[str, set[str]]:
    headers = list(SOFTWARE_PAGE_RE.finditer(text))
    if not headers:
        raise ValueError("software source contains no Page definitions")

    pages: dict[str, set[str]] = {}
    for index, header in enumerate(headers):
        name = decode_string(header.group(1))
        if name in pages:
            raise ValueError(f"duplicate software page {name!r}")
        block_end = (
            headers[index + 1].start() if index + 1 < len(headers) else len(text)
        )
        block = text[header.end() : block_end]
        concepts = {
            concept
            for body in SOFTWARE_KEY_RE.findall(block)
            if (concept := normalize_concept(decode_string(body)))
        }
        pages[name] = concepts

    return pages


def load_map(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        if reader.fieldnames != list(MAP_FIELDS):
            raise ValueError(
                f"{path}: expected TSV header {list(MAP_FIELDS)!r}, "
                f"received {reader.fieldnames!r}"
            )

        rows: list[dict[str, str]] = []
        seen_hardware: set[str] = set()
        seen_software: set[str] = set()

        for line_number, row in enumerate(reader, start=2):
            if any(row[field] is None or row[field] == "" for field in MAP_FIELDS):
                raise ValueError(f"{path}:{line_number}: empty required field")

            hardware = row["hardware_board"]
            software = row["software_page"]
            mode = row["mode"]

            if hardware in seen_hardware:
                raise ValueError(
                    f"{path}:{line_number}: duplicate hardware board {hardware!r}"
                )
            seen_hardware.add(hardware)

            if mode == "mirror":
                if software == "-":
                    raise ValueError(
                        f"{path}:{line_number}: mirror row requires a software page"
                    )
                if software in seen_software:
                    raise ValueError(
                        f"{path}:{line_number}: duplicate mirrored software page {software!r}"
                    )
                seen_software.add(software)
            elif mode == "hardware_only":
                if software != "-":
                    raise ValueError(
                        f"{path}:{line_number}: hardware_only row must use software page '-'"
                    )
            else:
                raise ValueError(f"{path}:{line_number}: unknown mode {mode!r}")

            rows.append({field: row[field] for field in MAP_FIELDS})

    return rows


def observe(
    hardware: dict[str, set[str]],
    software: dict[str, set[str]],
    mapping: list[dict[str, str]],
) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    configured_hardware: set[str] = set()
    mirrored_software: set[str] = set()

    for entry in mapping:
        board = entry["hardware_board"]
        page = entry["software_page"]
        mode = entry["mode"]
        configured_hardware.add(board)

        if board not in hardware:
            raise ValueError(f"mapped hardware board {board!r} is absent")

        if mode == "hardware_only":
            rows.append(
                {
                    "hardware_board": board,
                    "software_page": "",
                    "relation": "hardware_only_board",
                    "concept": "",
                }
            )
            continue

        if page not in software:
            raise ValueError(f"mapped software page {page!r} is absent")
        mirrored_software.add(page)

        hardware_concepts = hardware[board]
        software_concepts = software[page]

        for concept in sorted(hardware_concepts & software_concepts):
            rows.append(
                {
                    "hardware_board": board,
                    "software_page": page,
                    "relation": "shared",
                    "concept": concept,
                }
            )

        for concept in sorted(hardware_concepts - software_concepts):
            rows.append(
                {
                    "hardware_board": board,
                    "software_page": page,
                    "relation": "hardware_only",
                    "concept": concept,
                }
            )

        for concept in sorted(software_concepts - hardware_concepts):
            rows.append(
                {
                    "hardware_board": board,
                    "software_page": page,
                    "relation": "software_only",
                    "concept": concept,
                }
            )

    for board in sorted(set(hardware) - configured_hardware):
        rows.append(
            {
                "hardware_board": board,
                "software_page": "",
                "relation": "unmapped_hardware_board",
                "concept": "",
            }
        )

    for page in sorted(set(software) - mirrored_software):
        rows.append(
            {
                "hardware_board": "",
                "software_page": page,
                "relation": "unmapped_software_page",
                "concept": "",
            }
        )

    return sorted(
        rows,
        key=lambda row: (
            row["hardware_board"],
            row["software_page"],
            row["relation"],
            row["concept"],
        ),
    )


def write_tsv(rows: list[dict[str, str]], handle) -> None:
    writer = csv.DictWriter(
        handle, fieldnames=OUTPUT_FIELDS, delimiter="\t", lineterminator="\n"
    )
    writer.writeheader()
    writer.writerows(rows)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument("--hardware", type=Path, required=True)
    parser.add_argument("--software", type=Path, required=True)
    parser.add_argument("--map", dest="map_path", type=Path, required=True)
    parser.add_argument("--output", default="-")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)

    try:
        hardware = parse_hardware(args.hardware.read_text(encoding="utf-8"))
        software = parse_software(args.software.read_text(encoding="utf-8"))
        mapping = load_map(args.map_path)
        rows = observe(hardware, software, mapping)
    except (OSError, UnicodeError, ValueError) as error:
        print(f"keyboard cross-reference error: {error}", file=sys.stderr)
        return 2

    if args.output == "-":
        write_tsv(rows, sys.stdout)
    else:
        with Path(args.output).open("w", encoding="utf-8", newline="") as handle:
            write_tsv(rows, handle)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
