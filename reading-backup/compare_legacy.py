#!/usr/bin/env python3
"""Independent origin-vs-portable comparison for an old installed reading app.

Reads a rescued private SQLite database (versions 1..3) and source EPUB/TXT
bytes in a TAR, and independently verifies that a complete ZIP faithfully
represents them. It does not use the application's conversion routine.
"""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path, PurePosixPath
import sqlite3
import sys
import tarfile
import tempfile
import zipfile

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("aici_reading_verify", HERE / "verify.py")
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)

TABLES = {
    "books": (
        "id title author kind epub_path source_uri source_sha1 chapter scroll_y "
        "char_offset content_length current_page total_pages added_ms last_read_ms "
        "total_seconds reading_since_ms"
    ).split(),
    "bookmarks": "id book_id chapter char_offset page label saved_ms".split(),
    "sessions": "id book_id started_ms ended_ms seconds".split(),
    "readera_positions": (
        "sha1 title filename ratio last_read_ms raw_position imported_ms"
    ).split(),
}
MISSING_V1 = {"char_offset": 0, "content_length": 0, "source_uri": None, "source_sha1": None}
MISSING_V2 = {"source_uri": None, "source_sha1": None}
MAX_BYTES = 1024 * 1024 * 1024
MAX_DB = 16 * 1024 * 1024
MAX_ROWS = 100000


def fail(message):
    raise ValueError(message)


def archive_index(archive):
    index = {}
    for member in archive:
        name = member.name.removeprefix("./")
        path = PurePosixPath(name)
        if path.is_absolute() or ".." in path.parts:
            fail("unsafe source archive path")
        if member.isfile():
            if name in index:
                fail("duplicate legacy archive entry")
            index[name] = member
        elif name.startswith("files/epubs/") or name.startswith("databases/"):
            if not member.isdir():
                fail("unexpected private-file symlink or special TAR member")
    if "databases/reading.sqlite" not in index:
        fail("rescue TAR omitted the SQLite database")
    return index


def legacy_tables(connection):
    version = connection.execute("PRAGMA user_version").fetchone()[0]
    if version not in (1, 2, 3):
        fail("unrecognized legacy database version")
    expected = {}
    for table, cols in TABLES.items():
        info = connection.execute(f"PRAGMA table_info({table})").fetchall()
        if not info:
            if (version == 1 and table == "bookmarks") or (
                version < 3 and table == "readera_positions"
            ):
                expected[table] = []
                continue
            fail("missing historical table " + table)
        present = [c["name"] for c in info]
        if len(present) != len(set(present)) or set(present) - set(cols):
            fail("unknown old reading table columns")
        missing = set(cols) - set(present)
        permitted = MISSING_V1 if version == 1 else MISSING_V2 if version == 2 else {}
        if not missing.issubset(permitted):
            fail("unexplained historical column gap")
        records = []
        for row in connection.execute(f"SELECT * FROM {table}"):
            if len(records) >= MAX_ROWS or (table == "books" and len(records) >= 10000):
                fail("legacy reading table too large")
            item = dict(row)
            item.update({key: permitted[key] for key in missing})
            records.append({column: item[column] for column in cols})
        expected[table] = records
    return expected


def private_book_member(absolute_path, kind):
    if not isinstance(absolute_path, str):
        fail("missing legacy private EPUB/TXT path")
    path = PurePosixPath(absolute_path)
    parts = path.parts
    if not path.is_absolute() or ".." in parts or len(parts) < 7 or (
        parts[-3:-1] != ("files", "epubs")
    ):
        fail("legacy book is not under its private files/epubs directory")
    if not parts[-1].endswith(".txt" if kind == 2 else ".epub"):
        fail("private file extension does not match book kind")
    return "files/epubs/" + parts[-1]


def compare(source_tar, portable_zip):
    proof = validator.verify(portable_zip)
    old_paths = set()
    with tarfile.open(source_tar, "r:*") as archive:
        index = archive_index(archive)
        with tempfile.TemporaryDirectory(prefix="aici-reading-old-") as directory:
            root = Path(directory)
            for suffix in ("", "-wal", "-shm"):
                path = "databases/reading.sqlite" + suffix
                if path not in index:
                    continue
                if index[path].size > MAX_DB:
                    fail("legacy SQLite file too large")
                target = root / ("reading.sqlite" + suffix)
                with archive.extractfile(index[path]) as source, target.open("wb") as out:
                    size = 0
                    while block := source.read(16384):
                        size += len(block)
                        if size > MAX_DB:
                            fail("oversized private database")
                        out.write(block)
            connection = sqlite3.connect(
                "file:" + str(root / "reading.sqlite") + "?mode=ro", uri=True
            )
            connection.row_factory = sqlite3.Row
            try:
                source_tables = legacy_tables(connection)
            finally:
                connection.close()
        with zipfile.ZipFile(portable_zip) as output:
            target_tables = json.loads(output.read("database.json"))
            if set(source_tables) != set(target_tables):
                fail("converted library has different tables")
            originals = {}
            for record in source_tables["books"]:
                identity, kind = record["id"], record["kind"]
                if type(identity) is not int or identity <= 0:
                    fail("invalid legacy book identity")
                if kind == 1:
                    if record["epub_path"] is not None:
                        fail("paper book references private file")
                    continue
                if kind not in (0, 2):
                    fail("unrecognized digital book kind")
                private = private_book_member(record["epub_path"], kind)
                if private in old_paths or private not in index:
                    fail("duplicate or missing original private book")
                old_paths.add(private)
                sha = hashlib.sha256()
                with archive.extractfile(index[private]) as source:
                    length = 0
                    while block := source.read(16384):
                        length += len(block)
                        if length > 100 * 1024 * 1024:
                            fail("source book exceeds archive profile")
                        sha.update(block)
                logical = f"books/{identity}.{'txt' if kind == 2 else 'epub'}"
                if logical not in output.namelist():
                    fail("converted library omitted a book")
                with output.open(logical) as member:
                    new_sha = hashlib.sha256()
                    while block := member.read(16384):
                        new_sha.update(block)
                if sha.digest() != new_sha.digest():
                    fail("converted bytes differ from the installed book")
                originals[identity] = logical
            orphaned = {
                path for path in index if path.startswith("files/epubs/")
                and path.endswith((".epub", ".txt"))
            } - old_paths
            if orphaned:
                fail("unreported private book data in original installation")
            for table in TABLES:
                expected = source_tables[table]
                converted = target_tables[table]
                if not isinstance(converted, list) or len(expected) != len(converted):
                    fail("lost or added " + table)
                converted_by_key = {}
                key = "sha1" if table == "readera_positions" else "id"
                for row in converted:
                    if not isinstance(row, dict) or set(row) != set(TABLES[table]):
                        fail("unrecognized row schema")
                    k = row[key]
                    if k in converted_by_key:
                        fail("duplicate record")
                    converted_by_key[k] = row
                for row in expected:
                    original = dict(row)
                    target = converted_by_key.get(row[key])
                    if target is None:
                        fail("missing " + table + " record")
                    if table == "books":
                        original["source_uri"] = None  # SAF URI grants are non-portable
                        if original["kind"] != 1:
                            original["epub_path"] = originals[original["id"]]
                    if original != target:
                        differences = sorted(k for k in original if original[k] != target[k])
                        fail("changed " + table + " fields: " + ",".join(differences))
    return {"rows": {table: len(rows) for table, rows in source_tables.items()},
            "matched_book_files": len(old_paths), "zip_sha256": proof["zip_sha256"]}


def main():
    p = argparse.ArgumentParser()
    p.add_argument("rescued_old_tar")
    p.add_argument("converted_complete_zip")
    args = p.parse_args()
    try:
        print("PASS independent old→portable comparison " +
              json.dumps(compare(args.rescued_old_tar, args.converted_complete_zip),
                         sort_keys=True))
    except (OSError, ValueError, TypeError, KeyError, zipfile.BadZipFile,
            tarfile.TarError, sqlite3.DatabaseError) as e:
        p.exit(1, "FAIL independent old→portable comparison: " + str(e) + "\n")


if __name__ == "__main__":
    main()
