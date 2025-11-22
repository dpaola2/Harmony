from __future__ import annotations

from core.interfaces import AudioBackend
from core.models import Track


class PcAudioBackend(AudioBackend):
    """Print-only audio backend for the PC simulator."""

    def __init__(self) -> None:
        self.last_track: Track | None = None
        self.volume: int | None = None

    def play(self, track: Track) -> None:
        self.last_track = track
        self._log(f"Play: {track.title} - {track.artist}")

    def pause(self) -> None:
        self._log("Pause")

    def resume(self) -> None:
        self._log("Resume")

    def stop(self) -> None:
        self._log("Stop")

    def set_volume(self, level: int) -> None:
        self.volume = level
        self._log(f"Volume: {level}")

    def _log(self, message: str) -> None:
        print(f"[Audio] {message}")
