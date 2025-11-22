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
        self.set_volume_calls: list[int] = []

    def play(self, track: Track) -> None:
        self.play_calls.append(track)

    def stop(self) -> None:
        self.stop_calls += 1

    def pause(self) -> None:
        self.pause_calls += 1

    def resume(self) -> None:
        self.resume_calls += 1

    def set_volume(self, level: int) -> None:
        self.set_volume_calls.append(level)


def _make_app() -> tuple[PlayerApp, DummyAudioBackend, DummyScreen, list[Track]]:
    tracks = [
        Track(
            id="1",
            title="Alpha One",
            artist="Artist A",
            album="Album X",
            track_number=1,
            duration_secs=180,
            path="/music/a1.mp3",
        ),
        Track(
            id="2",
            title="Alpha Two",
            artist="Artist A",
            album="Album X",
            track_number=2,
            duration_secs=200,
            path="/music/a2.mp3",
        ),
        Track(
            id="3",
            title="Beta One",
            artist="Artist B",
            album="Album Y",
            track_number=None,
            duration_secs=190,
            path="/music/b1.mp3",
        ),
    ]
    state = PlayerState(tracks=tracks)
    screen = DummyScreen()
    audio = DummyAudioBackend()
    app = PlayerApp(state=state, screen=screen, audio_backend=audio)
    return app, audio, screen, tracks


def test_root_navigation_and_enter_library() -> None:
    app, _, _, _ = _make_app()
    assert app.state.current_screen == ScreenID.ROOT
    assert app.state.root_index == 0  # Library highlighted

    app.handle_button(ButtonEvent.DOWN)
    assert app.state.root_index == 1  # Now Playing
    app.handle_button(ButtonEvent.UP)
    assert app.state.root_index == 0

    app.handle_button(ButtonEvent.RIGHT)  # enter Library (Artists)
    assert app.state.current_screen == ScreenID.LIBRARY
    assert app.state.library_level.name == "ARTISTS"


def test_artists_and_albums_navigation() -> None:
    app, _, _, _ = _make_app()
    app.handle_button(ButtonEvent.RIGHT)  # into Library

    # Two artists: Artist A, Artist B
    app.handle_button(ButtonEvent.DOWN)
    app.handle_button(ButtonEvent.DOWN)  # clamp at end
    assert app.state.selected_artist_index == 1

    app.handle_button(ButtonEvent.SELECT)  # enter albums for Artist B
    assert app.state.library_level.name == "ALBUMS"
    # Artist B has one album; back up to artists
    app.handle_button(ButtonEvent.BACK)
    assert app.state.library_level.name == "ARTISTS"


def test_album_to_tracks_and_play_jump() -> None:
    app, audio, _, tracks = _make_app()
    app.handle_button(ButtonEvent.RIGHT)  # Library -> Artists
    app.handle_button(ButtonEvent.SELECT)  # enter Artist A albums
    app.handle_button(ButtonEvent.SELECT)  # enter tracks for Album X

    assert app.state.library_level.name == "TRACKS"
    # Album X has two tracks, track_number ordering respected
    app.handle_button(ButtonEvent.SELECT)  # play first track and jump

    assert app.state.current_screen == ScreenID.NOW_PLAYING
    assert app.state.is_playing is True
    assert app.state.playing_index == 0
    assert audio.play_calls[-1] == tracks[0]


def test_play_pause_within_tracks_without_leaving_library() -> None:
    app, audio, _, _ = _make_app()
    app.handle_button(ButtonEvent.RIGHT)  # Library
    app.handle_button(ButtonEvent.SELECT)  # Artist A albums
    app.handle_button(ButtonEvent.SELECT)  # Album X tracks

    app.handle_button(ButtonEvent.PLAY_PAUSE)  # play
    assert app.state.current_screen == ScreenID.LIBRARY
    assert app.state.is_playing is True

    app.handle_button(ButtonEvent.PLAY_PAUSE)  # pause
    assert app.state.is_playing is False
    assert audio.pause_calls == 1

    app.handle_button(ButtonEvent.PLAY_PAUSE)  # resume
    assert app.state.is_playing is True
    assert audio.resume_calls == 1


def test_back_traversal_tracks_to_root() -> None:
    app, _, _, _ = _make_app()
    app.handle_button(ButtonEvent.RIGHT)  # Library
    app.handle_button(ButtonEvent.SELECT)  # Artist A albums
    app.handle_button(ButtonEvent.SELECT)  # Album X tracks

    app.handle_button(ButtonEvent.BACK)  # to albums
    assert app.state.library_level.name == "ALBUMS"
    app.handle_button(ButtonEvent.BACK)  # to artists
    assert app.state.library_level.name == "ARTISTS"
    app.handle_button(ButtonEvent.BACK)  # to root
    assert app.state.current_screen == ScreenID.ROOT
    assert app.state.root_index == 0


def test_settings_enter_and_back() -> None:
    app, _, _, _ = _make_app()
    app.handle_button(ButtonEvent.DOWN)
    app.handle_button(ButtonEvent.DOWN)
    assert app.state.root_index == 2
    app.handle_button(ButtonEvent.SELECT)
    assert app.state.current_screen == ScreenID.SETTINGS

    app.handle_button(ButtonEvent.LEFT)
    assert app.state.current_screen == ScreenID.ROOT
    assert app.state.root_index == 2


def test_empty_library_behaves() -> None:
    state = PlayerState(tracks=[])
    screen = DummyScreen()
    audio = DummyAudioBackend()
    app = PlayerApp(state=state, screen=screen, audio_backend=audio)

    app.handle_button(ButtonEvent.RIGHT)  # enter Library
    assert app.state.library_level.name == "ARTISTS"
    app.handle_button(ButtonEvent.SELECT)  # no artists, stay put
    assert app.state.library_level.name == "ARTISTS"

    app.handle_button(ButtonEvent.PLAY_PAUSE)
    assert not audio.play_calls


def test_volume_changes_clamp_and_call_backend() -> None:
    app, audio, _, _ = _make_app()
    assert app.state.volume == 50

    app.handle_button(ButtonEvent.VOLUME_UP)
    assert app.state.volume == 55
    assert audio.set_volume_calls[-1] == 55

    # Big increase beyond 100
    for _ in range(15):
        app.handle_button(ButtonEvent.VOLUME_UP)
    assert app.state.volume == 100
    assert audio.set_volume_calls[-1] == 100

    # Decrease below 0
    for _ in range(25):
        app.handle_button(ButtonEvent.VOLUME_DOWN)
    assert app.state.volume == 0
    assert audio.set_volume_calls[-1] == 0
