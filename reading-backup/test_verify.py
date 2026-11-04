#!/usr/bin/env python3
"""Positive and targeted known-bad archives for the independent reading verifier."""
import copy
import hashlib
import importlib.util
import io
import json
import os
import tempfile
import unittest
import warnings
import zipfile

spec = importlib.util.spec_from_file_location(
    "reading_backup_verify", os.path.join(os.path.dirname(__file__), "verify.py"))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

BOOK = {
    "id": 1, "title": "Sample", "author": "A", "kind": 2,
    "epub_path": "books/1.txt", "source_uri": None, "source_sha1": None,
    "chapter": 0, "scroll_y": 0, "char_offset": 5, "content_length": 12,
    "current_page": 0, "total_pages": 0, "added_ms": 5,
    "last_read_ms": 10, "total_seconds": 10, "reading_since_ms": 0,
}
PAPER = dict(BOOK, id=2, kind=1, epub_path=None, current_page=15,
             total_pages=200)
MARK = {"id": 1, "book_id": 1, "chapter": 0, "char_offset": 5,
        "page": 0, "label": "mark", "saved_ms": 12}
SESSION = {"id": 1, "book_id": 1, "started_ms": 10,
           "ended_ms": 20, "seconds": 10}
READERA = {"sha1": "f" * 40, "title": "external", "filename": "x.txt",
           "ratio": 0.5, "last_read_ms": 11,
           "raw_position": "chapter 1", "imported_ms": 12}
DATABASE = {"books": [BOOK, PAPER], "bookmarks": [MARK],
            "sessions": [SESSION], "readera_positions": [READERA]}


def emit(root, db=None, files=None, mutate_manifest=None, extra_entries=None):
    if db is None:
        db = copy.deepcopy(DATABASE)
    if files is None:
        files = {"books/1.txt": b"Hello world!"}
    payloads = {"database.json": json.dumps(db).encode(), **files}
    manifest = {"format": module.MAGIC, "version": 1, "files": [
        {"name": name, "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}
        for name, data in payloads.items()]}
    if mutate_manifest:
        mutate_manifest(manifest)
    filename = os.path.join(root, "backup.zip")
    with zipfile.ZipFile(filename, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for name, data in payloads.items():
            archive.writestr(name, data)
        for name, data in (extra_entries or {}).items():
            archive.writestr(name, data)
        archive.writestr("manifest.json", json.dumps(manifest))
    return filename


class NegativeControls(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="aici-reading-")
        self.addCleanup(self.tmp.cleanup)
        self.path = self.tmp.name

    def reject(self, archive):
        with self.assertRaises((OSError, ValueError, zipfile.BadZipFile, TypeError, KeyError)):
            module.verify(archive)

    def test_complete_good_with_session_and_readera(self):
        proof = module.verify(emit(self.path))
        self.assertEqual(proof["book_files"], 1)
        self.assertEqual(proof["bookmarks"], 1)
        self.assertEqual(proof["sessions"], 1)
        self.assertEqual(proof["readera_positions"], 1)

    def test_changed_book_bytes(self):
        self.reject(emit(self.path, files={"books/1.txt": b"wrong"} ,
                         mutate_manifest=lambda m:
                         m["files"][1].update({"sha256": "0" * 64})))

    def test_missing_book(self):
        self.reject(emit(self.path, files={}))

    def test_unknown_zip_member(self):
        self.reject(emit(self.path, extra_entries={"books/../pass.txt": b"attack"}))

    def test_manifest_omits_entry(self):
        self.reject(emit(self.path, mutate_manifest=lambda m: m["files"].pop()))

    def test_wrong_schema(self):
        db = copy.deepcopy(DATABASE)
        del db["books"][0]["char_offset"]
        self.reject(emit(self.path, db=db))

    def test_orphan_bookmark(self):
        db = copy.deepcopy(DATABASE)
        db["bookmarks"][0]["book_id"] = 99
        self.reject(emit(self.path, db=db))

    def test_orphan_session(self):
        db = copy.deepcopy(DATABASE)
        db["sessions"][0]["book_id"] = 99
        self.reject(emit(self.path, db=db))

    def test_duplicate_archive_member(self):
        archive = emit(self.path)
        with warnings.catch_warnings():
            warnings.simplefilter("ignore", UserWarning)
            with zipfile.ZipFile(archive, "a") as z:
                z.writestr("database.json", b"bad")
        self.reject(archive)

    def test_truncated_archive(self):
        archive = emit(self.path)
        with open(archive, "rb") as f:
            data = f.read()
        with open(archive, "wb") as f:
            f.write(data[:-15])
        self.reject(archive)

    def test_unknown_format(self):
        self.reject(emit(self.path, mutate_manifest=lambda m: m.update({"version": 99})))


if __name__ == "__main__":
    unittest.main()
