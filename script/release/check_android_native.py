#!/usr/bin/env python3
"""Verify ELF LOAD segment alignment in an AAB; device and APK checks remain required."""
import json
import struct
import sys
import zipfile
from pathlib import Path


def inspect(artifact):
    libraries = []
    with zipfile.ZipFile(artifact) as archive:
        for name in archive.namelist():
            if not name.endswith(".so"):
                continue
            raw = archive.read(name)
            if raw[:4] != b"\x7fELF" or raw[4] not in (1, 2) or raw[5] not in (1, 2):
                raise ValueError("Invalid ELF library: " + name)
            endian = "<" if raw[5] == 1 else ">"
            if raw[4] == 2:
                offset = struct.unpack_from(endian + "Q", raw, 32)[0]
                size, count = struct.unpack_from(endian + "HH", raw, 54)
                alignment_offset, alignment_type = 48, "Q"
            else:
                offset = struct.unpack_from(endian + "I", raw, 28)[0]
                size, count = struct.unpack_from(endian + "HH", raw, 42)
                alignment_offset, alignment_type = 28, "I"
            alignments = [
                struct.unpack_from(endian + alignment_type, raw, offset + i * size + alignment_offset)[0]
                for i in range(count)
                if struct.unpack_from(endian + "I", raw, offset + i * size)[0] == 1
            ]
            aligned = bool(alignments) and all(a >= 16384 and a & (a - 1) == 0 for a in alignments)
            libraries.append({"library": name, "load_segment_alignments": alignments, "elf_16kb_aligned": aligned})
    return {"artifact": str(Path(artifact).resolve()), "libraries": libraries,
            "passed": bool(libraries) and all(row["elf_16kb_aligned"] for row in libraries),
            "scope": "ELF segment alignment; final APK ZIP alignment and a 16 KB device run are separate checks"}


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: check_android_native.py path/to/app.aab")
    try:
        result = inspect(sys.argv[1])
    except (OSError, ValueError, zipfile.BadZipFile, struct.error, IndexError):
        result = {"passed": False, "error": "Unable to inspect Android native libraries"}
    print(json.dumps(result, indent=2))
    sys.exit(0 if result["passed"] else 1)
