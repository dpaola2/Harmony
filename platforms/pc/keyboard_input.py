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


def read_key() -> str:
    """Read a line from stdin without stripping spaces."""
    line = sys.stdin.readline()
    if line == "":
        return ""  # EOF
    return line.rstrip("\n")


def read_event() -> tuple[Optional[ButtonEvent], bool]:
    """Return (ButtonEvent or None, quit_flag). Blocking read."""
    key = read_key()
    # EOF signals quit; Enter (empty string before newline strip) should map via KEYMAP.
    if key == "":
        return None, True if sys.stdin.closed else False

    event = KEYMAP.get(key)
    if key in QUIT_KEYS:
        return None, True
    return event, False
