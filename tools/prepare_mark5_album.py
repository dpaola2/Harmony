#!/usr/bin/env python3
"""Copy one tagged MP3 album and write a verified Mark-5 manifest.

Existing files are reused only when their checksums match. No files are removed
or overwritten. Requires ffprobe on the host; the ESP32 needs only album.json.
"""

import argparse
import hashlib
import json
import math
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from core.album import tracks_from_manifest
from core.models import Track


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def inventory(source):
    entries = []
    for path in sorted(source.iterdir()):
        if not path.is_file() or path.suffix.lower() != ".mp3":
            continue
        probe = json.loads(subprocess.check_output([
            "ffprobe", "-v", "error", "-select_streams", "a:0", "-show_entries",
            "stream=codec_name:format=duration:format_tags=title,artist,album,track,disc",
            "-of", "json", str(path)], text=True))
        if not probe.get("streams") or probe["streams"][0]["codec_name"] != "mp3":
            raise ValueError("Not an MP3 audio stream: " + str(path))
        tags = {key.lower(): value for key, value in probe["format"].get("tags", {}).items()}
        number = int(tags["track"].split("/")[0])
        disc = int(tags.get("disc", "1").split("/")[0])
        duration = float(probe["format"]["duration"])
        entries.append((path, dict(file="%02d-%02d.MP3" % (disc, number),
            title=tags["title"], artist=tags["artist"], album=tags["album"],
            number=number, disc=disc, duration_secs=math.ceil(duration),
            bytes=path.stat().st_size, sha256=sha256(path))))
    if not entries:
        raise ValueError("No MP3 files found")
    entries.sort(key=lambda pair: (pair[1]["disc"], pair[1]["number"]))
    if len({e["album"] for _, e in entries}) != 1:
        raise ValueError("Source folder contains more than one album")
    names = [e["file"] for _, e in entries]
    if len(set(names)) != len(names):
        raise ValueError("Duplicate disc/track numbers")
    return entries


def prepare(source, destination):
    entries = inventory(source)
    manifest = dict(version=1, tracks=[entry for _, entry in entries])
    tracks_from_manifest(manifest, "/sd/album", Track)
    manifest_bytes = (json.dumps(manifest, indent=2, ensure_ascii=True) + "\n").encode()
    destination.mkdir(parents=True, exist_ok=True)
    manifest_path = destination / "album.json"
    if manifest_path.exists() and manifest_path.read_bytes() != manifest_bytes:
        raise FileExistsError("Different album manifest already exists: " + str(manifest_path))
    # Check all destination conflicts before starting the copy.
    for _, entry in entries:
        target = destination / entry["file"]
        if target.exists() and sha256(target) != entry["sha256"]:
            raise FileExistsError("Different file already exists: " + str(target))
    for source_path, entry in entries:
        target = destination / entry["file"]
        if not target.exists():
            with tempfile.NamedTemporaryFile(dir=destination, prefix=".copy-", delete=False) as tmp:
                temporary = Path(tmp.name)
            try:
                shutil.copyfile(source_path, temporary)
                if sha256(temporary) != entry["sha256"]:
                    raise IOError("Copied track checksum mismatch")
                temporary.rename(target)
            finally:
                if temporary.exists():
                    temporary.unlink()
        print("VERIFIED", entry["number"], entry["title"], entry["bytes"], flush=True)
    if not manifest_path.exists():
        with manifest_path.open("xb") as output:
            output.write(manifest_bytes)
    print("ALBUM_READY", manifest_path, "tracks", len(entries), "seconds",
          sum(e["duration_secs"] for _, e in entries), flush=True)
    return manifest


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()
    prepare(args.source, args.destination)
