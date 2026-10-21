#!/usr/bin/env python3
"""Independent bounded integrity oracle for Remind Me to Read complete ZIP exports.

No Android imports, no use of producer validation routines and no data repair.
It checks a *supplied* archive, not whether a physical device produced one.
"""
import argparse
import hashlib
import json
import os
import re
import stat
import sys
import zipfile

MAGIC = "org.isomorphisms.remindmetoread.backup"
MAX_ARCHIVE = 1024 ** 3
MAX_BOOK = 100 * 1024 ** 2
MAX_DB = 16 * 1024 ** 2
MAX_MANIFEST = 1024 ** 2
COLS = {
    "books": {
        "id", "title", "author", "kind", "epub_path", "source_uri", "source_sha1",
        "chapter", "scroll_y", "char_offset", "content_length", "current_page",
        "total_pages", "added_ms", "last_read_ms", "total_seconds", "reading_since_ms"},
    "bookmarks": {"id", "book_id", "chapter", "char_offset", "page", "label", "saved_ms"},
    "sessions": {"id", "book_id", "started_ms", "ended_ms", "seconds"},
    "readera_positions": {"sha1", "title", "filename", "ratio",
                          "last_read_ms", "raw_position", "imported_ms"},
}
BOOK_NAME = re.compile(r"books/[1-9][0-9]{0,17}\.(txt|epub)\Z")
DIGEST = re.compile(r"[0-9a-f]{64}\Z")


def fail(message):
    raise ValueError(message)


def bounded_json(member, archive, max_bytes):
    with archive.open(member) as source:
        payload = source.read(max_bytes + 1)
    if len(payload) > max_bytes:
        fail(f"oversized metadata {member.filename}")
    return json.loads(payload.decode("utf-8"), parse_constant=lambda x: fail(f"invalid number {x}"))


def verify(archive_path):
    if os.path.getsize(archive_path) > MAX_ARCHIVE:
        fail("compressed archive oversized")
    with zipfile.ZipFile(archive_path) as archive:
        entries = archive.infolist()
        if len(entries) > 10002:
            fail("too many ZIP entries")
        names = [item.filename for item in entries]
        if len(names) != len(set(names)):
            fail("duplicate ZIP entry")
        for entry in entries:
            name = entry.filename
            if name not in ("manifest.json", "database.json") and BOOK_NAME.fullmatch(name) is None:
                fail(f"unexpected or traversal ZIP member: {name}")
            mode = entry.external_attr >> 16
            if entry.is_dir() or entry.flag_bits & 1 or (
                stat.S_IFMT(mode) not in (0, stat.S_IFREG)
            ):
                fail("directory, symlink, special or encrypted ZIP member")
        if "manifest.json" not in names or "database.json" not in names:
            fail("missing backup manifest or database")
        manifest = bounded_json(archive.getinfo("manifest.json"), archive, MAX_MANIFEST)
        if not isinstance(manifest, dict) or set(manifest) != {"format", "version", "files"}:
            fail("unknown manifest schema")
        if manifest["format"] != MAGIC or type(manifest["version"]) is not int or manifest["version"] != 1:
            fail("unknown format/version")
        files = manifest["files"]
        if not isinstance(files, list) or len(files) != len(entries) - 1:
            fail("incomplete manifest")
        seen = set()
        sizes = 0
        for record in files:
            if not isinstance(record, dict) or set(record) != {"name", "sha256", "bytes"}:
                fail("invalid manifest record")
            name, expected, length = record["name"], record["sha256"], record["bytes"]
            if not isinstance(name, str) or name == "manifest.json" or name not in names or name in seen:
                fail("missing, extra or duplicated declared member")
            if not isinstance(expected, str) or not DIGEST.fullmatch(expected):
                fail("invalid sha256")
            if type(length) is not int or length < 0:
                fail("invalid size")
            if length > (MAX_DB if name == "database.json" else MAX_BOOK):
                fail("declared entry exceeds limit")
            sizes += length
            if sizes > MAX_ARCHIVE:
                fail("uncompressed archive oversized")
            seen.add(name)
            sha = hashlib.sha256()
            count = 0
            with archive.open(name) as source:
                while True:
                    block = source.read(16384)
                    if not block:
                        break
                    count += len(block)
                    if count > length:
                        fail("oversized member")
                    sha.update(block)
            if count != length or sha.hexdigest() != expected:
                fail(f"digest or length mismatch: {name}")
        if seen != set(names) - {"manifest.json"}:
            fail("unlisted payload")
        database = bounded_json(archive.getinfo("database.json"), archive, MAX_DB)
        if not isinstance(database, dict) or set(database) != set(COLS):
            fail("unknown reading database table set")
        book_ids = set()
        expected_members = set()
        for table, rows in database.items():
            if not isinstance(rows, list) or len(rows) > (10000 if table == "books" else 100000):
                fail("unbounded or invalid row collection")
            ids = set()
            for row in rows:
                if not isinstance(row, dict) or set(row) != COLS[table]:
                    fail(f"invalid {table} record shape")
                if table in ("books", "bookmarks", "sessions"):
                    ident = row["id"]
                    if type(ident) is not int or ident <= 0 or ident in ids:
                        fail("invalid/duplicate sqlite row id")
                    ids.add(ident)
                if table == "books":
                    book_ids.add(ident)
                    kind = row["kind"]
                    if type(kind) is not int or kind not in (0, 1, 2):
                        fail("invalid book kind")
                    if kind == 1:
                        if row["epub_path"] is not None:
                            fail("paper book carries file path")
                    else:
                        member = f"books/{ident}.{'txt' if kind == 2 else 'epub'}"
                        if row["epub_path"] != member:
                            fail("digital book path not portable")
                        expected_members.add(member)
                if table == "sessions":
                    if type(row["seconds"]) is not int or row["seconds"] <= 0:
                        fail("invalid session duration")
                if table == "readera_positions":
                    ratio = row["ratio"]
                    if not isinstance(ratio, (int, float)) or not 0 <= ratio <= 1:
                        fail("invalid ReadEra ratio")
        for table in ("sessions", "bookmarks"):
            for row in database[table]:
                if type(row["book_id"]) is not int or row["book_id"] not in book_ids:
                    fail("orphan bookmark/session")
        if expected_members != seen - {"database.json"}:
            fail("missing/extra imported book bytes")
        return {
            "books": len(database["books"]),
            "bookmarks": len(database["bookmarks"]),
            "sessions": len(database["sessions"]),
            "readera_positions": len(database["readera_positions"]),
            "book_files": len(expected_members),
            "zip_sha256": hashlib.file_digest(open(archive_path, "rb"), "sha256").hexdigest(),
        }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("zip_path")
    args = parser.parse_args()
    try:
        proof = verify(args.zip_path)
        print("PASS complete-local-library integrity: " + json.dumps(proof, sort_keys=True))
    except (OSError, ValueError, zipfile.BadZipFile, UnicodeError, KeyError, TypeError) as ex:
        print(f"FAIL {ex}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
