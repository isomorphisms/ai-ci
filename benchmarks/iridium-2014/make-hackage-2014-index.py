#!/usr/bin/env python3
"""Build the old-style Hackage index as it existed at a UTC cutoff.

Modern Hackage's 01-index contains the complete append-only history of Cabal
metadata. Old cabal-install expects a 00-index containing the effective .cabal
file for each package version plus the top-level preferred-versions file. Keep
the last revision at or before the cutoff and discard hackage-security records
that a 2014 client never knew.
"""

from __future__ import annotations

import argparse
import datetime as dt
import gzip
import io
import tarfile
from pathlib import Path


def parse_cutoff(value: str) -> int:
    when = dt.datetime.fromisoformat(value.replace("Z", "+00:00"))
    if when.tzinfo is None:
        when = when.replace(tzinfo=dt.timezone.utc)
    return int(when.timestamp())


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("source", type=Path)
    p.add_argument("dest", type=Path)
    p.add_argument("--cutoff", default="2014-10-16T23:59:59Z")
    args = p.parse_args()

    cutoff = parse_cutoff(args.cutoff)
    latest: dict[str, tuple[tarfile.TarInfo, bytes]] = {}

    with tarfile.open(args.source, "r:gz") as src:
        for member in src:
            if not member.isfile() or member.mtime > cutoff:
                continue
            # Legacy 00-index semantics include package .cabal files and one
            # top-level preferred-versions file. Ignore security JSON and later
            # metadata types unknown to a 2014 client.
            if not (member.name.endswith(".cabal") or member.name == "preferred-versions"):
                continue
            f = src.extractfile(member)
            if f is None:
                continue
            latest[member.name] = (member, f.read())

    args.dest.parent.mkdir(parents=True, exist_ok=True)
    with gzip.GzipFile(filename="", mode="wb", fileobj=args.dest.open("wb"), mtime=0) as gz:
        with tarfile.open(fileobj=gz, mode="w") as out:
            for name in sorted(latest):
                original, data = latest[name]
                info = tarfile.TarInfo(name)
                info.size = len(data)
                info.mtime = original.mtime
                info.mode = 0o644
                info.uid = 0
                info.gid = 0
                info.uname = ""
                info.gname = ""
                out.addfile(info, io.BytesIO(data))

    print(f"cutoff={args.cutoff}")
    print(f"cabal_files={sum(name.endswith('.cabal') for name in latest)}")
    print(f"preferred_versions={'yes' if 'preferred-versions' in latest else 'no'}")
    print(f"bytes={args.dest.stat().st_size}")


if __name__ == "__main__":
    main()
