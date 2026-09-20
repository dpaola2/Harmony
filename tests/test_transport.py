from core.transport import Transport


class Audio:
    def __init__(self):
        self.calls = []

    def play(self, track):
        self.calls.append(("play", track))

    def pause(self):
        self.calls.append(("pause",))

    def resume(self):
        self.calls.append(("resume",))

    def set_volume(self, level):
        self.calls.append(("volume", level))


def test_first_play_starts_and_resume_preserves_track():
    audio = Audio()
    player = Transport(["a", "b"], audio)
    player.handle("play_pause")
    player.handle("play_pause")
    assert player.status == "Paused"
    player.handle("play_pause")
    assert audio.calls[1:] == [("play", "a"), ("pause",), ("resume",)]
    assert player.status == "Playing"


def test_skip_wraps_and_keeps_paused_state():
    audio = Audio()
    player = Transport(["a", "b"], audio)
    player.handle("previous")
    assert player.track == "b"
    assert player.status == "Ready"
    assert audio.calls == [("volume", 58)]
    player.handle("play_pause")
    player.handle("play_pause")
    player.handle("next")
    assert player.track == "a"
    assert player.status == "Paused"
    assert audio.calls[-2:] == [("play", "a"), ("pause",)]


def test_single_track_next_and_previous_restart_while_playing():
    audio = Audio()
    player = Transport(["a"], audio)
    for event in ("play_pause", "next", "previous"):
        player.handle(event)
    assert audio.calls[1:] == [("play", "a")] * 3
    assert player.status == "Playing"


def test_end_then_play_restarts_instead_of_resuming_eof():
    audio = Audio()
    player = Transport(["a"], audio)
    player.handle("play_pause")
    player.finished()
    player.handle("play_pause")
    assert audio.calls[-1] == ("play", "a")
    assert player.status == "Playing"


def test_volume_bounds_and_empty_library():
    audio = Audio()
    player = Transport([], audio, volume=98)
    player.handle("volume_up")
    assert player.volume == 100
    for _ in range(25):
        player.handle("volume_down")
    assert player.volume == 0
    for event in ("play_pause", "next", "previous"):
        player.handle(event)
    assert player.track is None
    assert player.status == "Ready"
    assert all(call[0] == "volume" for call in audio.calls)


def test_album_advances_in_order_then_stops_without_wrapping():
    audio = Audio()
    player = Transport(["a", "b", "c"], audio, volume=43)
    player.handle("play_pause")
    player.finished()
    assert player.track == "b"
    assert player.status == "Playing"
    player.finished()
    assert player.track == "c"
    player.finished()
    assert player.status == "Ended"
    assert audio.calls == [("volume", 43), ("play", "a"), ("play", "b"), ("play", "c")]
    player.finished()
    assert player.status == "Ended"
    player.handle("play_pause")
    assert player.track == "a"
    assert audio.calls[-1] == ("play", "a")


def test_eof_outside_playing_does_not_start_music():
    audio = Audio()
    player = Transport(["a", "b"], audio)
    player.finished()
    assert player.status == "Ready"
    player.handle("play_pause")
    player.handle("play_pause")
    player.finished()
    assert player.status == "Paused"
    assert player.track == "a"


def test_skipping_while_playing_keeps_volume_and_continues_album():
    audio = Audio()
    player = Transport(["a", "b", "c"], audio)
    player.handle("play_pause")
    player.handle("volume_up")
    player.handle("next")
    assert player.track == "b"
    assert player.status == "Playing"
    player.finished()
    assert player.track == "c"
    assert player.volume == 63
