from __future__ import annotations

from typing import Optional

from .interfaces import AudioBackend, Screen
from .models import ButtonEvent, PlayerState, ScreenID, Track


class PlayerApp:
    """Hardware-agnostic state machine for the MP3 player."""

    def __init__(self, state: PlayerState, screen: Screen, audio_backend: AudioBackend) -> None:
        self.state = state
        self.screen = screen
        self.audio_backend = audio_backend

    def handle_button(self, event: ButtonEvent) -> None:
        """Dispatch button input based on the current screen, then render."""
        if self.state.current_screen == ScreenID.LIBRARY:
            self._handle_library_input(event)
        elif self.state.current_screen == ScreenID.NOW_PLAYING:
            self._handle_now_playing_input(event)
        elif self.state.current_screen == ScreenID.SETTINGS:
            self._handle_settings_input(event)

        self.render()

    def render(self) -> None:
        """Render the current screen."""
        self.screen.clear()
        if self.state.current_screen == ScreenID.LIBRARY:
            self._render_library()
        elif self.state.current_screen == ScreenID.NOW_PLAYING:
            self._render_now_playing()
        elif self.state.current_screen == ScreenID.SETTINGS:
            self._render_settings()
        self.screen.refresh()

    # Input handling

    def _handle_library_input(self, event: ButtonEvent) -> None:
        if event == ButtonEvent.UP:
            self._move_selection(-1)
        elif event == ButtonEvent.DOWN:
            self._move_selection(1)
        elif event in (ButtonEvent.SELECT, ButtonEvent.RIGHT):
            self._enter_now_playing()
        elif event == ButtonEvent.PLAY_PAUSE:
            self._toggle_play_pause(selected_only=True)
        elif event == ButtonEvent.BACK:
            self.state.current_screen = ScreenID.SETTINGS

    def _handle_now_playing_input(self, event: ButtonEvent) -> None:
        if event in (ButtonEvent.LEFT, ButtonEvent.BACK):
            self.state.current_screen = ScreenID.LIBRARY
        elif event == ButtonEvent.PLAY_PAUSE:
            self._toggle_play_pause(selected_only=False)
        # LEFT/RIGHT for prev/next could be added later; keep minimal for now.

    def _handle_settings_input(self, event: ButtonEvent) -> None:
        if event == ButtonEvent.BACK:
            self.state.current_screen = ScreenID.LIBRARY
        # Settings screen interactions are intentionally stubbed for now.

    # Rendering helpers

    def _render_library(self) -> None:
        self.screen.draw_text(0, 0, "Library")
        if not self.state.tracks:
            self.screen.draw_text(0, 1, "(no tracks)")
            return

        for idx, track in enumerate(self.state.tracks):
            prefix = ">" if idx == self.state.selected_index else " "
            line = f"{prefix} {track.title} - {track.artist}"
            self.screen.draw_text(0, idx + 1, line)

    def _render_now_playing(self) -> None:
        self.screen.draw_text(0, 0, "Now Playing")
        track = self._current_track() or self._track_at(self.state.selected_index)
        if not track:
            self.screen.draw_text(0, 1, "(nothing playing)")
            return

        status = "Playing" if self.state.is_playing else "Paused"
        self.screen.draw_text(0, 1, f"{track.title} - {track.artist}")
        self.screen.draw_text(0, 2, f"{status}")

    def _render_settings(self) -> None:
        self.screen.draw_text(0, 0, "Settings")
        self.screen.draw_text(0, 1, "(stub)")

    # Playback helpers

    def _toggle_play_pause(self, *, selected_only: bool) -> None:
        if not self.state.tracks:
            return

        # Decide which track to act on.
        target_index: Optional[int]
        if self.state.playing_index is None or selected_only:
            target_index = self.state.selected_index
        else:
            target_index = self.state.playing_index

        track = self._track_at(target_index)
        if track is None:
            return

        if self.state.is_playing and self.state.playing_index == target_index:
            self.audio_backend.pause()
            self.state.is_playing = False
            return

        if self.state.playing_index != target_index or self.state.playing_index is None:
            # Switch to a new track or start fresh.
            self.audio_backend.stop()
            self.state.playing_index = target_index
            self.audio_backend.play(track)
        else:
            # Same track, currently paused.
            self.audio_backend.resume()

        self.state.is_playing = True

    def _enter_now_playing(self) -> None:
        self.state.current_screen = ScreenID.NOW_PLAYING

    # Selection helpers

    def _move_selection(self, delta: int) -> None:
        if not self.state.tracks:
            self.state.selected_index = 0
            return

        new_index = self.state.selected_index + delta
        new_index = max(0, min(new_index, len(self.state.tracks) - 1))
        self.state.selected_index = new_index

    # State accessors

    def _track_at(self, index: Optional[int]) -> Optional[Track]:
        if index is None:
            return None
        if 0 <= index < len(self.state.tracks):
            return self.state.tracks[index]
        return None

    def _current_track(self) -> Optional[Track]:
        return self._track_at(self.state.playing_index)
