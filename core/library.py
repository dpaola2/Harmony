from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple

from .models import Track

UNKNOWN_ARTIST = "Unknown Artist"
UNKNOWN_ALBUM = "Unknown Album"


def _normalize(value: Optional[str], fallback: str) -> str:
    if value is None:
        return fallback
    stripped = value.strip()
    return stripped if stripped else fallback


@dataclass
class Library:
    """Derived indexes for artist/album/track drilldown."""

    tracks: List[Track]

    def __post_init__(self) -> None:
        self.artist_index: Dict[str, List[int]] = {}
        self.album_index: Dict[Tuple[str, str], List[int]] = {}
        for idx, track in enumerate(self.tracks):
            artist = _normalize(track.artist, UNKNOWN_ARTIST)
            album = _normalize(track.album, UNKNOWN_ALBUM)

            self.artist_index.setdefault(artist, []).append(idx)
            self.album_index.setdefault((artist, album), []).append(idx)

    def artists(self) -> List[str]:
        return sorted(self.artist_index.keys())

    def albums_for_artist(self, artist: str) -> List[str]:
        albums = [album for (artist_key, album) in self.album_index.keys() if artist_key == artist]
        return sorted(set(albums))

    def tracks_for(self, artist: str, album: str) -> List[int]:
        indices = self.album_index.get((artist, album), [])
        return sorted(indices, key=self._track_sort_key)

    def _track_sort_key(self, idx: int) -> Tuple[int, str]:
        track = self.tracks[idx]
        # Numbered tracks first; then title.
        number = track.track_number if track.track_number is not None else 10_000_000
        return (number, track.title)
