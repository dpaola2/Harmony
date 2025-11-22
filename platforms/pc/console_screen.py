from __future__ import annotations

import sys
from typing import Dict

from core.interfaces import Screen


class ConsoleScreen(Screen):
    """Minimal console renderer for the PC simulator."""

    def __init__(self) -> None:
        self._lines: Dict[int, str] = {}
        self._clear_seq = "\033[2J\033[H"  # ANSI clear + cursor home

    def clear(self) -> None:
        self._lines.clear()

    def draw_text(self, x: int, y: int, text: str) -> None:
        # x is ignored in this simple renderer; prepend spaces for basic positioning.
        self._lines[y] = f"{' ' * max(0, x)}{text}"

    def refresh(self) -> None:
        sys.stdout.write(self._clear_seq)
        last_y = -1
        for y in sorted(self._lines.keys()):
            while last_y + 1 < y:
                sys.stdout.write("\n")
                last_y += 1
            sys.stdout.write(f"{self._lines[y]}\n")
            last_y = y
        sys.stdout.flush()
