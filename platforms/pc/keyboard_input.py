from __future__ import annotations

import sys
from typing import Optional

from core.models import ButtonEvent

# Map keys to button events.
KEYMAP = {
    "w": ButtonEvent.UP,
    "s": ButtonEvent.DOWN,
    "a": ButtonEvent.LEFT,
    "d": ButtonEvent.RIGHT,
    " ": ButtonEvent.SELECT,
    "": ButtonEvent.SELECT,  # plain Enter
    "p": ButtonEvent.PLAY_PAUSE,
    "b": ButtonEvent.BACK,
    "q": ButtonEvent.BACK,
}

QUIT_KEYS = {"x", "X"}


def read_key() -> Optional[str]:
    """Read a line from stdin without stripping spaces."""
    line = sys.stdin.readline()
    if line == "":
        return None  # EOF
    return line.rstrip("\n")


def read_event() -> tuple[Optional[ButtonEvent], bool]:
    """Return (ButtonEvent or None, quit_flag). Blocking read."""
    key = read_key()
    if key is None:
        return None, True  # EOF

    if key in QUIT_KEYS:
        return None, True

    event = KEYMAP.get(key)
    return event, False
