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


@dataclass
class Track:
    """Basic metadata for a track."""

    id: str
    title: str
    artist: str
    duration_secs: int
    path: str  # local file path on PC or device


@dataclass
class PlayerState:
    """State shared across screens and platform implementations."""

    tracks: List[Track] = field(default_factory=list)
    selected_index: int = 0
    playing_index: Optional[int] = None
    is_playing: bool = False
    current_screen: ScreenID = ScreenID.ROOT
    root_index: int = 0  # which root menu item is highlighted
