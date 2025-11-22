from __future__ import annotations

from core.player_app import PlayerApp
from core.models import ButtonEvent, PlayerState, ScreenID, Track


class DummyScreen:
    def __init__(self) -> None:
        self.draw_calls = []

    def clear(self) -> None:
        self.draw_calls.clear()

    def draw_text(self, x: int, y: int, text: str) -> None:
        self.draw_calls.append((x, y, text))

    def refresh(self) -> None:
        pass


class DummyAudioBackend:
    def __init__(self) -> None:
        self.play_calls: list[Track] = []
        self.stop_calls = 0
        self.pause_calls = 0
        self.resume_calls = 0

    def play(self, track: Track) -> None:
        self.play_calls.append(track)

    def stop(self) -> None:
        self.stop_calls += 1

    def pause(self) -> None:
        self.pause_calls += 1

    def resume(self) -> None:
        self.resume_calls += 1


def _make_app(track_count: int = 3) -> tuple[PlayerApp, DummyAudioBackend, DummyScreen, list[Track]]:
    tracks = [
        Track(id=str(i), title=f"Song {i}", artist="Artist", duration_secs=180, path=f"/music/song{i}.mp3")
        for i in range(track_count)
    ]
    state = PlayerState(tracks=tracks)
    screen = DummyScreen()
    audio = DummyAudioBackend()
    app = PlayerApp(state=state, screen=screen, audio_backend=audio)
    return app, audio, screen, tracks


def test_root_navigation_and_enter_library() -> None:
    app, _, _, _ = _make_app(track_count=2)
    assert app.state.current_screen == ScreenID.ROOT
    assert app.state.root_index == 0  # Library highlighted

    app.handle_button(ButtonEvent.DOWN)
    assert app.state.root_index == 1  # Now Playing
    app.handle_button(ButtonEvent.UP)
    assert app.state.root_index == 0

    app.handle_button(ButtonEvent.RIGHT)  # enter Library
    assert app.state.current_screen == ScreenID.LIBRARY


def test_library_selection_clamps() -> None:
    app, _, _, _ = _make_app(track_count=2)
    app.handle_button(ButtonEvent.RIGHT)  # enter Library

    app.handle_button(ButtonEvent.DOWN)
    assert app.state.selected_index == 1
    app.handle_button(ButtonEvent.DOWN)
    assert app.state.selected_index == 1  # clamps

    app.handle_button(ButtonEvent.UP)
    assert app.state.selected_index == 0
    app.handle_button(ButtonEvent.UP)
    assert app.state.selected_index == 0  # clamps


def test_library_play_pause_stays_in_library() -> None:
    app, audio, _, tracks = _make_app()
    app.handle_button(ButtonEvent.RIGHT)  # enter Library

    app.handle_button(ButtonEvent.PLAY_PAUSE)  # play
    assert app.state.current_screen == ScreenID.LIBRARY
    assert app.state.is_playing is True
    assert app.state.playing_index == 0
    assert audio.play_calls[-1] == tracks[0]

    app.handle_button(ButtonEvent.PLAY_PAUSE)  # pause
    assert app.state.is_playing is False
    assert audio.pause_calls == 1

    app.handle_button(ButtonEvent.PLAY_PAUSE)  # resume
    assert app.state.is_playing is True
    assert audio.resume_calls == 1


def test_library_select_plays_and_jumps_to_now_playing() -> None:
    app, audio, _, tracks = _make_app()
    app.handle_button(ButtonEvent.RIGHT)  # enter Library
    app.handle_button(ButtonEvent.SELECT)  # play + jump

    assert app.state.current_screen == ScreenID.NOW_PLAYING
    assert app.state.is_playing is True
    assert app.state.playing_index == 0
    assert audio.play_calls[-1] == tracks[0]


def test_left_back_in_library_returns_to_root() -> None:
    app, _, _, _ = _make_app()
    app.handle_button(ButtonEvent.RIGHT)  # enter Library
    app.handle_button(ButtonEvent.BACK)

    assert app.state.current_screen == ScreenID.ROOT
    assert app.state.root_index == 0  # Library highlighted


def test_now_playing_controls_and_return() -> None:
    app, audio, _, tracks = _make_app()
    # Start playback via Library
    app.handle_button(ButtonEvent.RIGHT)
    app.handle_button(ButtonEvent.SELECT)
    assert app.state.current_screen == ScreenID.NOW_PLAYING
    assert app.state.is_playing is True

    app.handle_button(ButtonEvent.PLAY_PAUSE)  # pause
    assert app.state.is_playing is False
    assert audio.pause_calls == 1

    app.handle_button(ButtonEvent.PLAY_PAUSE)  # resume
    assert app.state.is_playing is True
    assert audio.resume_calls == 1
    assert audio.play_calls[-1] == tracks[0]

    app.handle_button(ButtonEvent.BACK)
    assert app.state.current_screen == ScreenID.ROOT
    assert app.state.root_index == 1  # Now Playing highlighted


def test_settings_enter_and_back() -> None:
    app, _, _, _ = _make_app()
    # Move to Settings in root and enter
    app.handle_button(ButtonEvent.DOWN)
    app.handle_button(ButtonEvent.DOWN)
    assert app.state.root_index == 2
    app.handle_button(ButtonEvent.SELECT)
    assert app.state.current_screen == ScreenID.SETTINGS

    app.handle_button(ButtonEvent.LEFT)
    assert app.state.current_screen == ScreenID.ROOT
    assert app.state.root_index == 2


def test_empty_tracks_no_crash_and_selection_resets() -> None:
    state = PlayerState(tracks=[])
    screen = DummyScreen()
    audio = DummyAudioBackend()
    app = PlayerApp(state=state, screen=screen, audio_backend=audio)

    app.handle_button(ButtonEvent.RIGHT)  # enter Library
    app.handle_button(ButtonEvent.DOWN)
    assert app.state.selected_index == 0

    app.handle_button(ButtonEvent.PLAY_PAUSE)
    assert app.state.is_playing is False
    assert not audio.play_calls
