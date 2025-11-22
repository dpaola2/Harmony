from __future__ import annotations

from typing import List, Optional

from .library import Library, UNKNOWN_ALBUM, UNKNOWN_ARTIST
from .interfaces import AudioBackend, Screen
from .models import ButtonEvent, LibraryLevel, PlayerState, ScreenID, Track


class PlayerApp:
    """Hardware-agnostic state machine for the MP3 player."""

    def __init__(self, state: PlayerState, screen: Screen, audio_backend: AudioBackend) -> None:
        self.state = state
        self.screen = screen
        self.audio_backend = audio_backend
        self.library = Library(state.tracks)
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
        level = self.state.library_level
        if level == LibraryLevel.ARTISTS:
            if event == ButtonEvent.UP:
                self._move_artist_selection(-1)
            elif event == ButtonEvent.DOWN:
                self._move_artist_selection(1)
            elif event in (ButtonEvent.SELECT, ButtonEvent.RIGHT):
                self._enter_albums()
            elif event in (ButtonEvent.LEFT, ButtonEvent.BACK):
                self._go_to_root(ScreenID.LIBRARY)
        elif level == LibraryLevel.ALBUMS:
            if event == ButtonEvent.UP:
                self._move_album_selection(-1)
            elif event == ButtonEvent.DOWN:
                self._move_album_selection(1)
            elif event in (ButtonEvent.SELECT, ButtonEvent.RIGHT):
                self._enter_tracks()
            elif event in (ButtonEvent.LEFT, ButtonEvent.BACK):
                self.state.library_level = LibraryLevel.ARTISTS
                self.state.selected_album_index = 0
                self.state.selected_track_index = 0
        elif level == LibraryLevel.TRACKS:
            if event == ButtonEvent.UP:
                self._move_track_selection(-1)
            elif event == ButtonEvent.DOWN:
                self._move_track_selection(1)
            elif event in (ButtonEvent.SELECT, ButtonEvent.RIGHT):
                self._play_selected_track_and_jump()
            elif event == ButtonEvent.PLAY_PAUSE:
                self._play_pause_selected_track()
            elif event in (ButtonEvent.LEFT, ButtonEvent.BACK):
                self.state.library_level = LibraryLevel.ALBUMS
                self.state.selected_track_index = 0

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
        level = self.state.library_level
        if level == LibraryLevel.ARTISTS:
            self._render_artists()
        elif level == LibraryLevel.ALBUMS:
            self._render_albums()
        elif level == LibraryLevel.TRACKS:
            self._render_tracks()

    def _render_artists(self) -> None:
        artists = self.library.artists()
        self.screen.draw_text(0, 0, "Artists")
        if not artists:
            self.screen.draw_text(0, 1, "(no tracks)")
            return
        for idx, artist in enumerate(artists):
            prefix = ">" if idx == self.state.selected_artist_index else " "
            self.screen.draw_text(0, idx + 1, f"{prefix} {artist}")

    def _render_albums(self) -> None:
        artist = self._current_artist_label()
        albums = self._albums_for_artist(artist)
        self.screen.draw_text(0, 0, f"Albums - {artist}")
        if not albums:
            self.screen.draw_text(0, 1, "(no albums)")
            return
        for idx, album in enumerate(albums):
            prefix = ">" if idx == self.state.selected_album_index else " "
            self.screen.draw_text(0, idx + 1, f"{prefix} {album}")

    def _render_tracks(self) -> None:
        artist = self._current_artist_label()
        album = self._current_album_label(artist)
        tracks = self._tracks_for_album(artist, album)
        self.screen.draw_text(0, 0, f"{artist} / {album}")
        if not tracks:
            self.screen.draw_text(0, 1, "(no tracks)")
            return
        for idx, track_idx in enumerate(tracks):
            track = self.state.tracks[track_idx]
            prefix = ">" if idx == self.state.selected_track_index else " "
            self.screen.draw_text(0, idx + 1, f"{prefix} {track.title}")

    def _render_now_playing(self) -> None:
        self.screen.draw_text(0, 0, "Now Playing")
        track = self._current_track()
        if not track:
            self.screen.draw_text(0, 1, "(nothing playing)")
            return

        status = "Playing" if self.state.is_playing else "Paused"
        artist = track.artist if track.artist else UNKNOWN_ARTIST
        self.screen.draw_text(0, 1, f"{track.title} - {artist}")
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

    def _play_selected_track_and_jump(self) -> None:
        idx = self._current_track_index_from_library()
        if idx is None:
            return
        self._start_playback(idx, jump_to_now_playing=True)

    def _play_pause_selected_track(self) -> None:
        idx = self._current_track_index_from_library()
        if idx is None:
            return
        self._toggle_play_pause_on_index(idx)

    def _start_playback(self, target_index: int, jump_to_now_playing: bool) -> None:
        if self.state.playing_index is not None and self.state.playing_index != target_index:
            self.audio_backend.stop()
        track = self._track_at(target_index)
        if track is None:
            return
        self.audio_backend.play(track)
        self.state.playing_index = target_index
        self.state.is_playing = True
        if jump_to_now_playing:
            self.state.current_screen = ScreenID.NOW_PLAYING
            self.state.root_index = self._root_index_for(ScreenID.NOW_PLAYING)

    # Selection helpers

    def _move_root_selection(self, delta: int) -> None:
        new_index = self.state.root_index + delta
        new_index = max(0, min(new_index, len(self._root_items) - 1))
        self.state.root_index = new_index

    def _move_artist_selection(self, delta: int) -> None:
        artists = self.library.artists()
        if not artists:
            self.state.selected_artist_index = 0
            return
        new_index = self.state.selected_artist_index + delta
        new_index = max(0, min(new_index, len(artists) - 1))
        self.state.selected_artist_index = new_index

    def _move_album_selection(self, delta: int) -> None:
        artist = self._current_artist_label()
        albums = self._albums_for_artist(artist)
        if not albums:
            self.state.selected_album_index = 0
            return
        new_index = self.state.selected_album_index + delta
        new_index = max(0, min(new_index, len(albums) - 1))
        self.state.selected_album_index = new_index
        self.state.selected_track_index = 0  # reset track selection when album changes

    def _move_track_selection(self, delta: int) -> None:
        artist = self._current_artist_label()
        album = self._current_album_label(artist)
        tracks = self._tracks_for_album(artist, album)
        if not tracks:
            self.state.selected_track_index = 0
            return
        new_index = self.state.selected_track_index + delta
        new_index = max(0, min(new_index, len(tracks) - 1))
        self.state.selected_track_index = new_index

    # State accessors

    def _enter_root_item(self) -> None:
        target = self._root_items[self.state.root_index]
        self.state.current_screen = target
        if target == ScreenID.LIBRARY:
            self.state.library_level = LibraryLevel.ARTISTS
            self.state.selected_album_index = 0
            self.state.selected_track_index = 0

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

    def _enter_albums(self) -> None:
        artists = self.library.artists()
        if not artists:
            return
        self.state.library_level = LibraryLevel.ALBUMS
        self.state.selected_album_index = 0
        self.state.selected_track_index = 0

    def _enter_tracks(self) -> None:
        artist = self._current_artist_label()
        albums = self._albums_for_artist(artist)
        if not albums:
            return
        self.state.library_level = LibraryLevel.TRACKS
        self.state.selected_track_index = 0

    def _current_artist_label(self) -> str:
        artists = self.library.artists()
        if not artists:
            return UNKNOWN_ARTIST
        idx = max(0, min(self.state.selected_artist_index, len(artists) - 1))
        return artists[idx]

    def _albums_for_artist(self, artist: str) -> List[str]:
        return self.library.albums_for_artist(artist)

    def _current_album_label(self, artist: str) -> str:
        albums = self._albums_for_artist(artist)
        if not albums:
            return UNKNOWN_ALBUM
        idx = max(0, min(self.state.selected_album_index, len(albums) - 1))
        return albums[idx]

    def _tracks_for_album(self, artist: str, album: str) -> List[int]:
        return self.library.tracks_for(artist, album)

    def _current_track_index_from_library(self) -> Optional[int]:
        artist = self._current_artist_label()
        album = self._current_album_label(artist)
        tracks = self._tracks_for_album(artist, album)
        if not tracks:
            return None
        idx = max(0, min(self.state.selected_track_index, len(tracks) - 1))
        return tracks[idx]

    def _track_at(self, index: Optional[int]) -> Optional[Track]:
        if index is None:
            return None
        if 0 <= index < len(self.state.tracks):
            return self.state.tracks[index]
        return None

    def _current_track(self) -> Optional[Track]:
        return self._track_at(self.state.playing_index)
