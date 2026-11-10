#!/usr/bin/env python3
"""Independent migration comparison positive/negative controls with seeded library."""
import copy
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import sqlite3
import tarfile
import tempfile
import unittest
import zipfile

BASE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("independent_compare", BASE / "compare_legacy.py")
compare = importlib.util.module_from_spec(spec)
spec.loader.exec_module(compare)

TXT = b"Stable reading progress.\n"
EPUB = b"Example small imported EPUB bytes\x00\x01"
DOCS = {"files/epubs/novel.txt": TXT, "files/epubs/algebra.epub": EPUB}
APP = "/data/user/0/org.isomorphisms.remindmetoread/"
COLS = compare.TABLES


def fixture(root, version=3):
    path = root / "old.sqlite"
    con = sqlite3.connect(path)
    con.execute(f"PRAGMA user_version={version}")
    for table, columns in COLS.items():
        if table == "readera_positions" and version < 3: continue
        if table == "bookmarks" and version < 2: continue
        use = [c for c in columns if not (
            table == "books" and
            ((version < 2 and c in ("char_offset", "content_length")) or
             (version < 3 and c in ("source_uri", "source_sha1")))
        )]
        string_columns = {"title", "author", "epub_path", "source_uri", "source_sha1",
                          "label", "sha1", "filename", "raw_position"}
        definitions = [c + " " + ("REAL" if c == "ratio" else
                                  "TEXT" if c in string_columns else "INTEGER") for c in use]
        con.execute(f"CREATE TABLE {table} ({','.join(definitions)})")
    originals = [
        {"id": 1, "title": "Novel", "author": "Reader", "kind": 2,
         "epub_path": APP + "files/epubs/novel.txt",
         "source_uri": "content://expired/novel", "source_sha1": hashlib.sha1(TXT).hexdigest(),
         "chapter": 0, "scroll_y": 21, "char_offset": 12, "content_length": 25,
         "current_page": 0, "total_pages": 0, "added_ms": 3, "last_read_ms": 32,
         "total_seconds": 19, "reading_since_ms": 0},
        {"id": 2, "title": "Algebra", "author": "Math", "kind": 0,
         "epub_path": APP + "files/epubs/algebra.epub",
         "source_uri": None, "source_sha1": hashlib.sha1(EPUB).hexdigest(),
         "chapter": 2, "scroll_y": 4, "char_offset": 6, "content_length": 0,
         "current_page": 0, "total_pages": 0, "added_ms": 2, "last_read_ms": 50,
         "total_seconds": 15, "reading_since_ms": 0},
        {"id": 3, "title": "Paper", "author": "Writer", "kind": 1,
         "epub_path": None, "source_uri": None, "source_sha1": None,
         "chapter": 0, "scroll_y": 0, "char_offset": 0, "content_length": 0,
         "current_page": 41, "total_pages": 300, "added_ms": 1, "last_read_ms": 60,
         "total_seconds": 38, "reading_since_ms": 0}
    ]
    all_records = {"books": originals,
                   "bookmarks": [
                       {"id": 1, "book_id": 1, "chapter": 0, "char_offset": 12,
                        "page": 0, "label": "later", "saved_ms": 40}
                   ] if version >= 2 else [],
                   "sessions": [
                       {"id": 1, "book_id": 1, "started_ms": 13, "ended_ms": 32, "seconds": 19},
                       {"id": 2, "book_id": 3, "started_ms": 22, "ended_ms": 60, "seconds": 38}
                   ],
                   "readera_positions": [
                       {"sha1": "f" * 40, "title": "External", "filename": "external.epub",
                        "ratio": 0.4, "last_read_ms": 20, "raw_position": "pos/path",
                        "imported_ms": 30}
                   ] if version >= 3 else []}
    for table, records in all_records.items():
        use = [c[1] for c in con.execute(f"PRAGMA table_info({table})")]
        for row in records:
            con.execute(f"INSERT INTO {table} ({','.join(use)}) VALUES ({','.join('?' for _ in use)})",
                        [row[col] for col in use])
    con.commit()
    con.close()
    tar_path = root / "old.tar"
    with tarfile.open(tar_path, "w") as out:
        contents = {"databases/reading.sqlite": path.read_bytes(), **DOCS}
        for name, data in contents.items():
            member = tarfile.TarInfo(name)
            member.size = len(data)
            out.addfile(member, io.BytesIO(data))

    database = copy.deepcopy(all_records)
    for row in database["books"]:
        if version < 2:
            row["char_offset"] = 0
            row["content_length"] = 0
        if version < 3:
            row["source_uri"] = None
            row["source_sha1"] = None
        row["source_uri"] = None
        if row["kind"] != 1:
            row["epub_path"] = ("books/" + str(row["id"]) +
                                (".txt" if row["kind"] == 2 else ".epub"))
    body = {"books/1.txt": TXT, "books/2.epub": EPUB}
    zip_path = root / "portable.zip"
    rewrite_zip(zip_path, database, body)
    return tar_path, zip_path, database, body


def rewrite_zip(filename, database, files):
    payloads = {"database.json": json.dumps(database, separators=(",", ":")).encode(),
                **files}
    declared = [{"name": name, "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}
                for name, data in payloads.items()]
    manifest = {"format": "org.isomorphisms.remindmetoread.backup",
                "version": 1, "files": declared}
    with zipfile.ZipFile(filename, "w", compression=zipfile.ZIP_DEFLATED) as out:
        for name, data in payloads.items():
            out.writestr(name, data)
        out.writestr("manifest.json", json.dumps(manifest))


class IndependenceTests(unittest.TestCase):
    def setUp(self):
        self.workspace = tempfile.TemporaryDirectory(prefix="aici-legacy-")
        self.addCleanup(self.workspace.cleanup)
        self.root = Path(self.workspace.name)

    def test_realistic_full_v3_library_matches(self):
        source, target, db, docs = fixture(self.root, 3)
        proof = compare.compare(source, target)
        self.assertEqual(proof["matched_book_files"], 2)
        self.assertEqual(proof["rows"]["bookmarks"], 1)
        self.assertEqual(proof["rows"]["sessions"], 2)
        self.assertEqual(proof["rows"]["readera_positions"], 1)

    def test_old_v2_schema_defaults_match(self):
        source, target, db, docs = fixture(self.root, 2)
        self.assertEqual(compare.compare(source, target)["rows"]["readera_positions"], 0)

    def test_old_v1_schema_defaults_match(self):
        source, target, db, docs = fixture(self.root, 1)
        self.assertEqual(compare.compare(source, target)["rows"]["bookmarks"], 0)

    def test_reject_changed_position_even_with_valid_hashes(self):
        source, target, db, docs = fixture(self.root)
        db["books"][0]["char_offset"] += 1
        rewrite_zip(target, db, docs)
        compare.validator.verify(target)
        with self.assertRaisesRegex(ValueError, "changed books fields"):
            compare.compare(source, target)

    def test_reject_dropped_session_even_with_valid_hashes(self):
        source, target, db, docs = fixture(self.root)
        db["sessions"].pop()
        rewrite_zip(target, db, docs)
        compare.validator.verify(target)
        with self.assertRaisesRegex(ValueError, "lost or added sessions"):
            compare.compare(source, target)

    def test_reject_changed_book_bytes_even_with_valid_hashes(self):
        source, target, db, docs = fixture(self.root)
        docs["books/1.txt"] += b"appended"
        rewrite_zip(target, db, docs)
        compare.validator.verify(target)
        with self.assertRaisesRegex(ValueError, "converted bytes differ"):
            compare.compare(source, target)

    def test_reject_dropped_bookmark_even_with_valid_hashes(self):
        source, target, db, docs = fixture(self.root)
        db["bookmarks"].clear()
        rewrite_zip(target, db, docs)
        compare.validator.verify(target)
        with self.assertRaisesRegex(ValueError, "lost or added bookmarks"):
            compare.compare(source, target)

    def test_reject_changed_readera_even_with_valid_hashes(self):
        source, target, db, docs = fixture(self.root)
        db["readera_positions"][0]["raw_position"] = "rewritten"
        rewrite_zip(target, db, docs)
        compare.validator.verify(target)
        with self.assertRaisesRegex(ValueError, "changed readera_positions"):
            compare.compare(source, target)

    def test_reject_unexpected_private_book(self):
        source, target, db, docs = fixture(self.root)
        with tarfile.open(source, "a") as out:
            name = "files/epubs/untracked.txt"
            member = tarfile.TarInfo(name)
            member.size = 3
            out.addfile(member, io.BytesIO(b"xxx"))
        with self.assertRaisesRegex(ValueError, "unreported private book"):
            compare.compare(source, target)


if __name__ == "__main__":
    unittest.main()
