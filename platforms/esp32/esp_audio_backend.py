"""Stub audio backend for ESP32 Prototype 1."""

from core.interfaces import AudioBackend
from core.models import Track


class EspAudioBackend(AudioBackend):
    def play(self, track: Track) -> None:
        print("PLAY:", track.title)

    def pause(self) -> None:
        print("PAUSE")

    def resume(self) -> None:
        print("RESUME")

    def stop(self) -> None:
        print("STOP")

    def set_volume(self, level: int) -> None:
        print("VOLUME:", level)
