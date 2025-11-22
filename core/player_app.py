from __future__ import annotations

from typing import List, Optional

from .interfaces import AudioBackend, Screen
from .models import ButtonEvent, PlayerState, ScreenID, Track


class PlayerApp:
    """Hardware-agnostic state machine for the MP3 player."""

    def __init__(self, state: PlayerState, screen: Screen, audio_backend: AudioBackend) -> None:
        self.state = state
        self.screen = screen
        self.audio_backend = audio_backend
        self._root_items: List[ScreenID] = [
            ScreenID.LIBRARY,
            ScreenID.NOW_PLAYING,
            ScreenID.SETTINGS,
        ]

    def handle_button(self, event: ButtonEvent) -> None:
        """Dispatch button input based on the current screen, then render."""
        if self.state.current_screen == ScreenID.ROOT:
            self._handle_root_input(event)
        elif self.state.current_screen == ScreenID.LIBRARY:
            self._handle_library_input(event)
        elif self.state.current_screen == ScreenID.NOW_PLAYING:
            self._handle_now_playing_input(event)
        elif self.state.current_screen == ScreenID.SETTINGS:
            self._handle_settings_input(event)

        self.render()

    def render(self) -> None:
        """Render the current screen."""
        self.screen.clear()
        if self.state.current_screen == ScreenID.ROOT:
            self._render_root()
        elif self.state.current_screen == ScreenID.LIBRARY:
            self._render_library()
        elif self.state.current_screen == ScreenID.NOW_PLAYING:
            self._render_now_playing()
        elif self.state.current_screen == ScreenID.SETTINGS:
            self._render_settings()
        self.screen.refresh()

    # Input handling

    def _handle_root_input(self, event: ButtonEvent) -> None:
        if event == ButtonEvent.UP:
            self._move_root_selection(-1)
        elif event == ButtonEvent.DOWN:
            self._move_root_selection(1)
        elif event in (ButtonEvent.RIGHT, ButtonEvent.SELECT):
            self._enter_root_item()
        # LEFT/BACK: no-op at root

    def _handle_library_input(self, event: ButtonEvent) -> None:
        if event == ButtonEvent.UP:
            self._move_selection(-1)
        elif event == ButtonEvent.DOWN:
            self._move_selection(1)
        elif event in (ButtonEvent.SELECT, ButtonEvent.RIGHT):
            self._play_from_library_and_jump()
        elif event == ButtonEvent.PLAY_PAUSE:
            self._toggle_play_pause_on_index(self.state.selected_index)
        elif event in (ButtonEvent.LEFT, ButtonEvent.BACK):
            self._go_to_root(ScreenID.LIBRARY)

    def _handle_now_playing_input(self, event: ButtonEvent) -> None:
        if event in (ButtonEvent.LEFT, ButtonEvent.BACK):
            self._go_to_root(ScreenID.NOW_PLAYING)
        elif event == ButtonEvent.PLAY_PAUSE:
            self._toggle_play_pause_on_index(self.state.playing_index)
        # Other keys: no-op for now.

    def _handle_settings_input(self, event: ButtonEvent) -> None:
        if event in (ButtonEvent.LEFT, ButtonEvent.BACK):
            self._go_to_root(ScreenID.SETTINGS)
        # Other keys: no-op for now.

    # Rendering helpers

    def _render_root(self) -> None:
        self.screen.draw_text(0, 0, "Menu")
        for idx, item in enumerate(self._root_items):
            prefix = ">" if idx == self.state.root_index else " "
            label = self._root_label(item)
            self.screen.draw_text(0, idx + 1, f"{prefix} {label}")

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
        track = self._current_track()
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

    def _toggle_play_pause_on_index(self, target_index: Optional[int]) -> None:
        if not self.state.tracks:
            return

        track = self._track_at(target_index)
        if track is None:
            return

        if self.state.is_playing and self.state.playing_index == target_index:
            self.audio_backend.pause()
            self.state.is_playing = False
            return

        if self.state.playing_index != target_index and self.state.playing_index is not None:
            self.audio_backend.stop()

        if self.state.playing_index == target_index and not self.state.is_playing:
            self.audio_backend.resume()
        else:
            # Start or switch track.
            self.audio_backend.play(track)
            self.state.playing_index = target_index

        self.state.is_playing = True

    def _play_from_library_and_jump(self) -> None:
        # Always start playback from the selected track, stopping current if needed.
        track = self._track_at(self.state.selected_index)
        if track is None:
            return
        if self.state.playing_index is not None:
            self.audio_backend.stop()
        self.state.playing_index = self.state.selected_index
        self.audio_backend.play(track)
        self.state.is_playing = True
        self.state.current_screen = ScreenID.NOW_PLAYING

    # Selection helpers

    def _move_root_selection(self, delta: int) -> None:
        new_index = self.state.root_index + delta
        new_index = max(0, min(new_index, len(self._root_items) - 1))
        self.state.root_index = new_index

    def _move_selection(self, delta: int) -> None:
        if not self.state.tracks:
            self.state.selected_index = 0
            return

        new_index = self.state.selected_index + delta
        new_index = max(0, min(new_index, len(self.state.tracks) - 1))
        self.state.selected_index = new_index

    # State accessors

    def _enter_root_item(self) -> None:
        target = self._root_items[self.state.root_index]
        self.state.current_screen = target

    def _go_to_root(self, highlight: ScreenID) -> None:
        self.state.current_screen = ScreenID.ROOT
        self.state.root_index = self._root_index_for(highlight)

    def _root_index_for(self, item: ScreenID) -> int:
        try:
            return self._root_items.index(item)
        except ValueError:
            return 0

    def _root_label(self, item: ScreenID) -> str:
        if item == ScreenID.LIBRARY:
            return "Library"
        if item == ScreenID.NOW_PLAYING:
            return "Now Playing"
        if item == ScreenID.SETTINGS:
            return "Settings"
        return item.value

    def _track_at(self, index: Optional[int]) -> Optional[Track]:
        if index is None:
            return None
        if 0 <= index < len(self.state.tracks):
            return self.state.tracks[index]
        return None

    def _current_track(self) -> Optional[Track]:
        return self._track_at(self.state.playing_index)
