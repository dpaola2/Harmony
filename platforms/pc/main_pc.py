from __future__ import annotations

import argparse

from core.player_app import PlayerApp
from core.models import ButtonEvent, PlayerState, Track
from .console_screen import ConsoleScreen
from .keyboard_input import read_event
from .pc_audio_backend import PcAudioBackend
from .track_loader import load_tracks_from_dir


KEY_HINT = "w/s: up/down | a: left | d: right | space/enter: select | p: play/pause | b/q: back | x: quit"


def sample_tracks() -> list[Track]:
    return [
        Track(
            id="1",
            title="Song One",
            artist="Artist A",
            album="Album X",
            track_number=1,
            duration_secs=180,
            path="/music/song1.mp3",
        ),
        Track(
            id="2",
            title="Song Two",
            artist="Artist A",
            album="Album X",
            track_number=2,
            duration_secs=200,
            path="/music/song2.mp3",
        ),
        Track(
            id="3",
            title="Song Three",
            artist="Artist B",
            album="Album Y",
            track_number=None,
            duration_secs=210,
            path="/music/song3.mp3",
        ),
    ]


def main() -> None:
    parser = argparse.ArgumentParser(description="PC simulator for the MP3 player")
    parser.add_argument("--music-dir", type=str, default=None, help="Optional directory of audio files to load")
    args = parser.parse_args()

    tracks = load_tracks_from_dir(args.music_dir) if args.music_dir else sample_tracks()
    if not tracks:
        tracks = sample_tracks()

    state = PlayerState(tracks=tracks)
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
