from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum, auto
from typing import List, Optional


class ButtonEvent(Enum):
    """Logical input events independent of hardware details."""

    UP = auto()
    DOWN = auto()
    LEFT = auto()
    RIGHT = auto()
    SELECT = auto()
    BACK = auto()
    PLAY_PAUSE = auto()


class ScreenID(Enum):
    """High-level screens used by the state machine."""

    ROOT = "root"
    LIBRARY = "library"
    NOW_PLAYING = "now_playing"
    SETTINGS = "settings"


class LibraryLevel(Enum):
    """Navigation level within the Library drilldown."""

    ARTISTS = auto()
    ALBUMS = auto()
    TRACKS = auto()


@dataclass
class Track:
    """Basic metadata for a track."""

    id: str
    title: str
    artist: Optional[str]
    album: Optional[str]
    track_number: Optional[int]
    duration_secs: int
    path: str  # local file path on PC or device


@dataclass
class PlayerState:
    """State shared across screens and platform implementations."""

    tracks: List[Track] = field(default_factory=list)
    # Root navigation
    root_index: int = 0  # which root menu item is highlighted
    current_screen: ScreenID = ScreenID.ROOT
    # Library drilldown navigation
    library_level: LibraryLevel = LibraryLevel.ARTISTS
    selected_artist_index: int = 0
    selected_album_index: int = 0
    selected_track_index: int = 0
    # Playback
    playing_index: Optional[int] = None
    is_playing: bool = False
