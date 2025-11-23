"""Prototype 1 demo entrypoint for ESP32-S3 + ST7789V2."""

import time

import esp_audio_backend
import esp_screen
from core import models
from core import player_app


def sample_tracks():
    """Mock library for demo mode."""
    return [
        models.Track(
            id="1",
            title="Song One",
            artist="Artist A",
            album="Album X",
            track_number=1,
            duration_secs=180,
            path="/sd/artist_a/album_x/song1.mp3",
        ),
        models.Track(
            id="2",
            title="Song Two",
            artist="Artist A",
            album="Album X",
            track_number=2,
            duration_secs=200,
            path="/sd/artist_a/album_x/song2.mp3",
        ),
        models.Track(
            id="3",
            title="Song Three",
            artist="Artist B",
            album="Album Y",
            track_number=None,
            duration_secs=210,
            path="/sd/artist_b/album_y/song3.mp3",
        ),
    ]


def demo_sequence():
    """
    A short, loopable script of button events that walks through the UI:
    - Enter Library (artists -> albums -> tracks)
    - Play first track (auto-jumps to Now Playing)
    - Pause/resume, back to root
    - Enter Settings stub and return
    - Enter Now Playing from root, then back
    """
    return [
        models.ButtonEvent.RIGHT,  # enter Library
        models.ButtonEvent.SELECT,  # Artist A albums
        models.ButtonEvent.SELECT,  # Album X tracks
        models.ButtonEvent.SELECT,  # Play track 1 and jump to Now Playing
        models.ButtonEvent.PLAY_PAUSE,  # Pause
        models.ButtonEvent.PLAY_PAUSE,  # Resume
        models.ButtonEvent.LEFT,  # Back to root (Now Playing highlighted)
        models.ButtonEvent.UP,  # highlight Library again
        models.ButtonEvent.SELECT,  # back into Library
        models.ButtonEvent.DOWN,  # Artist B
        models.ButtonEvent.SELECT,  # Artist B albums
        models.ButtonEvent.SELECT,  # album -> tracks
        models.ButtonEvent.DOWN,  # move to second track (if present)
        models.ButtonEvent.LEFT,  # back to albums
        models.ButtonEvent.LEFT,  # back to artists
        models.ButtonEvent.LEFT,  # back to root
        models.ButtonEvent.DOWN,  # move highlight to Settings
        models.ButtonEvent.DOWN,  # clamp at Settings
        models.ButtonEvent.SELECT,  # enter Settings
        models.ButtonEvent.LEFT,  # back to root
        models.ButtonEvent.UP,  # highlight Now Playing
        models.ButtonEvent.SELECT,  # open Now Playing view
        models.ButtonEvent.LEFT,  # back to root
    ]


def run_demo_loop(app, delay_sec=1.0):
    seq = demo_sequence()
    idx = 0
    while True:
        event = seq[idx]
        print("DEMO event:", event)
        app.handle_button(event)
        idx = (idx + 1) % len(seq)
        time.sleep(delay_sec)


def main():
    print("Starting demo UI…")
    state = models.PlayerState(tracks=sample_tracks())
    screen = esp_screen.EspScreen()
    audio = esp_audio_backend.EspAudioBackend()
    app = player_app.PlayerApp(state=state, screen=screen, audio_backend=audio)
    app.render()
    run_demo_loop(app, delay_sec=1.0)


if __name__ == "__main__":
    main()
