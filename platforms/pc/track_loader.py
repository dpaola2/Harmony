from __future__ import annotations

import os
from pathlib import Path
from typing import List

from core.models import Track


def load_tracks_from_dir(path: str) -> List[Track]:
    """Build Track objects from a directory of audio files (shallow scan)."""
    base = Path(path)
    if not base.exists() or not base.is_dir():
        return []

    tracks: List[Track] = []
    for entry in sorted(base.iterdir()):
        if not entry.is_file():
            continue
        if entry.suffix.lower() not in {".mp3", ".wav", ".flac"}:
            continue
        title = entry.stem
        # Simple heuristic: "Artist - Album - Title"
        artist = None
        album = None
        parts = title.split(" - ")
        if len(parts) == 3:
            artist, album, title = parts
        elif len(parts) == 2:
            artist, title = parts
        track = Track(
            id=str(entry),
            title=title,
            artist=artist,
            album=album,
            track_number=None,
            duration_secs=0,
            path=str(entry),
        )
        tracks.append(track)
    return tracks
