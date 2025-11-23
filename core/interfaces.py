try:
    from typing import Optional, Protocol
except ImportError:
    Protocol = object  # type: ignore
    Optional = object  # type: ignore

from .models import ButtonEvent, Track


class Screen(Protocol):
    """Abstract display surface for both PC and ESP32 implementations."""

    def clear(self) -> None: ...

    def draw_text(self, x: int, y: int, text: str) -> None: ...

    def refresh(self) -> None: ...


class AudioBackend(Protocol):
    """Abstract audio control; implementations may be real or stubbed."""

    def play(self, track: Track) -> None: ...

    def pause(self) -> None: ...

    def resume(self) -> None: ...

    def stop(self) -> None: ...

    def set_volume(self, level: int) -> None: ...


class InputSource(Protocol):
    """Abstract input source to produce logical button events."""

    def read_event(self) -> Optional[ButtonEvent]: ...
