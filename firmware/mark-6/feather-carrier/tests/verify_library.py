#!/usr/bin/env python3
"""Run bounded, filesystem-backed library tests with memory/UB checks."""
import pathlib
import subprocess
import tempfile

P = pathlib.Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix="harmony-library-test-") as temp:
    for test in ("album", "library"):
        binary = pathlib.Path(temp) / test
        subprocess.run([
            "cc", "-std=c11", "-D_POSIX_C_SOURCE=200809L", "-Wall", "-Wextra", "-Werror",
            "-fsanitize=address,undefined", "-fno-omit-frame-pointer", "-g",
            "-I", str(P / "main"), str(P / "tests" / f"test_{test}.c"),
            str(P / "main/album.c"), str(P / "main/album_metadata.c"), "-o", str(binary),
        ], check=True)
        subprocess.run([str(binary)], check=True)
