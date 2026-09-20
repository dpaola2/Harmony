"""Validate an ordered album manifest without filesystem or hardware imports."""


def tracks_from_manifest(manifest, root, track_class):
    if not isinstance(manifest, dict) or manifest.get("version") != 1:
        raise ValueError("Unsupported album manifest version")
    entries = manifest.get("tracks")
    if not isinstance(entries, list) or not entries or len(entries) > 200:
        raise ValueError("Album must contain 1..200 tracks")
    tracks = []
    files = set()
    positions = set()
    for entry in entries:
        if not isinstance(entry, dict):
            raise ValueError("Invalid track entry")
        filename = entry.get("file", "")
        if (not isinstance(filename, str) or not filename
                or "/" in filename or "\\" in filename
                or filename in (".", "..") or not filename.lower().endswith(".mp3")):
            raise ValueError("Track filename must be an MP3 in the album directory")
        if filename.lower() in files:
            raise ValueError("Duplicate track filename")
        files.add(filename.lower())
        disc = entry.get("disc", 1)
        number = entry.get("number")
        duration = entry.get("duration_secs")
        size = entry.get("bytes")
        digest = entry.get("sha256", "")
        if any(type(n) is not int or n <= 0 for n in (disc, number, duration, size)):
            raise ValueError("Track numbering, duration and size must be positive integers")
        if (disc, number) in positions:
            raise ValueError("Duplicate disc/track number")
        positions.add((disc, number))
        if (not isinstance(digest, str) or len(digest) != 64
                or any(c not in "0123456789abcdef" for c in digest)):
            raise ValueError("Invalid track checksum")
        for field in ("title", "artist", "album"):
            value = entry.get(field)
            if not isinstance(value, str) or not value.strip():
                raise ValueError("Missing track " + field)
        track = track_class(filename, entry["title"], entry["artist"], entry["album"],
                            number, duration, root.rstrip("/") + "/" + filename)
        track.disc_number = disc
        track.expected_bytes = size
        track.expected_sha256 = digest
        tracks.append(track)
    return sorted(tracks, key=lambda track: (track.disc_number, track.track_number))
