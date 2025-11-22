from __future__ import annotations

import re
from pathlib import Path
from typing import List, Optional, Tuple

from core.models import Track

SUPPORTED_EXTS = {".mp3", ".wav", ".flac"}


def _parse_filename(name: str) -> Tuple[Optional[int], str]:
    """Extract optional leading track number and title from a filename stem."""
    # Patterns: "01 - Title", "01_Title", "01 Title"
    m = re.match(r"^(\d+)[\s\-_\.]+(.+)$", name)
    if m:
        try:
            number = int(m.group(1))
        except ValueError:
            number = None
        title = m.group(2)
        return number, title
    return None, name


def load_tracks_from_dir(path: str) -> List[Track]:
    """Build Track objects from a directory tree using Artist/Album/Track convention."""
    base = Path(path)
    if not base.exists() or not base.is_dir():
        return []

    tracks: List[Track] = []

    for artist_dir in sorted([p for p in base.iterdir() if p.is_dir()]):
        artist = artist_dir.name
        album_dirs = [p for p in artist_dir.iterdir() if p.is_dir()]
        # If files are directly under artist_dir, treat album as unknown.
        file_entries = [p for p in artist_dir.iterdir() if p.is_file()]

        for file_entry in file_entries:
            if file_entry.suffix.lower() not in SUPPORTED_EXTS:
                continue
            number, title = _parse_filename(file_entry.stem)
            tracks.append(
                Track(
                    id=str(file_entry),
                    title=title,
                    artist=artist,
                    album=None,
                    track_number=number,
                    duration_secs=0,
                    path=str(file_entry),
                )
            )

        for album_dir in sorted(album_dirs):
            album = album_dir.name
            for file_entry in sorted([p for p in album_dir.iterdir() if p.is_file()]):
                if file_entry.suffix.lower() not in SUPPORTED_EXTS:
                    continue
                number, title = _parse_filename(file_entry.stem)
                tracks.append(
                    Track(
                        id=str(file_entry),
                        title=title,
                        artist=artist,
                        album=album,
                        track_number=number,
                        duration_secs=0,
                        path=str(file_entry),
                    )
                )

    # Files directly under base (no artist folder) fallback to unknown artist/album.
    for file_entry in sorted([p for p in base.iterdir() if p.is_file()]):
        if file_entry.suffix.lower() not in SUPPORTED_EXTS:
            continue
        number, title = _parse_filename(file_entry.stem)
        tracks.append(
            Track(
                id=str(file_entry),
                title=title,
                artist=None,
                album=None,
                track_number=number,
                duration_secs=0,
                path=str(file_entry),
            )
        )

    return tracks
