from __future__ import annotations

from core.player_app import PlayerApp
from core.models import ButtonEvent, PlayerState, Track
from .console_screen import ConsoleScreen
from .keyboard_input import read_event
from .pc_audio_backend import PcAudioBackend


KEY_HINT = "w/s: up/down | a: left | d: right | space/enter: select | p: play/pause | b/q: back | x: quit"


def sample_tracks() -> list[Track]:
    return [
        Track(id="1", title="Song One", artist="Artist A", duration_secs=180, path="/music/song1.mp3"),
        Track(id="2", title="Song Two", artist="Artist B", duration_secs=200, path="/music/song2.mp3"),
        Track(id="3", title="Song Three", artist="Artist C", duration_secs=210, path="/music/song3.mp3"),
    ]


def main() -> None:
    state = PlayerState(tracks=sample_tracks())
    screen = ConsoleScreen()
    audio = PcAudioBackend()
    app = PlayerApp(state=state, screen=screen, audio_backend=audio)

    app.render()
    print(KEY_HINT)
    while True:
        event, should_quit = read_event()
        if should_quit:
            break
        if event is None:
            continue

        app.handle_button(event)
        print(KEY_HINT)


if __name__ == "__main__":
    main()
