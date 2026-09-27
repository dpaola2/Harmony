import json

from core.models import Track
from core.ui_prototype import PrototypeUI


def tracks():
    return [Track("a", "First", "Artist A", "Shared", 1, 10, "/a.mp3"),
            Track("b", "Second", "Artist A", "Shared", 2, 20, "/b.mp3"),
            Track("c", "Another", "Artist B", "Shared", 1, 30, "/c.mp3")]


def open_album(ui):
    for index in (0, 0, 0, 0):
        ui.action("row", index)


def start(ui, index=0):
    open_album(ui)
    return ui.action("row", index)


def test_empty_library_and_root_boundaries_are_safe_and_serializable():
    ui = PrototypeUI([])
    ui.action("back")
    assert ui.action("rotate", -99)["selected"] == 0
    assert ui.action("rotate", 99)["selected"] == 3
    ui.action("row", 0)
    view = ui.action("row", 0)
    assert view["rows"] == []
    ui.action("select")
    assert ui.action("play_pause")["queue_count"] == 0
    json.dumps(ui.snapshot())


def test_back_restores_album_and_exact_highlight_after_playing():
    ui = PrototypeUI(tracks())
    view = start(ui, 1)
    assert view["track"]["title"] == "Second"
    assert view["queue_count"] == 2
    assert view["queue_position"] == 2
    view = ui.action("back")
    assert view["title"] == "Shared"
    assert view["selected"] == 1
    assert view["rows"][1]["playing"] is True
    assert ui.action("back")["title"] == "Artist A"


def test_browsing_does_not_replace_queue_or_interrupt_audio():
    ui = PrototypeUI(tracks())
    start(ui)
    ui.action("home")
    ui.action("row", 0)
    ui.action("row", 0)
    ui.action("row", 1)
    ui.action("row", 0)
    view = ui.action("next")
    assert view["subtitle"] == "Artist B"
    assert view["track"]["title"] == "Second"
    assert view["queue_count"] == 2
    assert view["playing"]
    assert view["rows"][0]["playing"] is False


def test_pause_and_volume_only_change_expected_state():
    ui = PrototypeUI(tracks())
    start(ui)
    assert ui.action("rotate", 1000)["volume"] == 100
    assert ui.action("rotate", -1000)["volume"] == 0
    assert ui.action("select")["playing"] is False
    assert ui.action("tick", 5)["elapsed"] == 0
    assert ui.action("play_pause")["playing"] is True
    assert ui.action("tick", 5)["elapsed"] == 5
    ui.action("back")
    view = ui.action("rotate", 1)
    assert view["volume"] == 0 and view["selected"] == 1


def test_tick_crosses_track_boundary_and_stops_at_queue_end():
    ui = PrototypeUI(tracks())
    start(ui)
    view = ui.action("tick", 12)
    assert view["track"]["title"] == "Second" and view["elapsed"] == 2
    view = ui.action("tick", 100)
    assert not view["playing"] and view["elapsed"] == 20
    assert ui.action("play_pause")["elapsed"] == 0


def test_repeat_all_and_one_apply_to_automatic_playback():
    ui = PrototypeUI(tracks())
    start(ui)
    ui.action("home")
    ui.action("row", 3)
    ui.action("row", 0)  # all
    view = ui.action("tick", 31)
    assert view["queue_position"] == 1 and view["elapsed"] == 1
    ui.action("row", 0)  # one
    view = ui.action("tick", 10)
    assert view["queue_position"] == 1 and view["elapsed"] == 1
    assert ui.action("next")["queue_position"] == 2


def test_duplicate_album_names_remain_distinct_and_disc_order_is_preserved():
    library = tracks()
    library[0].disc_number = 2
    library[1].disc_number = 1
    ui = PrototypeUI(library)
    ui.action("row", 0)
    view = ui.action("row", 1)
    assert [r["detail"] for r in view["rows"]] == ["Artist A", "Artist B"]
    view = ui.action("row", 0)
    assert [r["label"] for r in view["rows"]] == ["Second", "First"]


def test_trial_playlist_preserves_input_order_and_all_tracks():
    ui = PrototypeUI(tracks())
    ui.action("row", 0)
    ui.action("row", 3)
    ui.action("row", 0)
    view = ui.action("row", 2)
    assert view["track"]["title"] == "Another"
    assert view["queue_count"] == 3 and view["queue_position"] == 3


def open_saved_speaker(ui):
    ui.action("home")
    ui.action("row", 2)
    ui.action("row", 0)
    ui.action("row", 0)


def test_disconnect_keeps_bond_pauses_and_reconnect_requires_resume():
    ui = PrototypeUI(tracks())
    start(ui)
    open_saved_speaker(ui)
    view = ui.action("row", 0)
    assert view["receiver"] is None and not view["playing"]
    assert "Forget device" in [row["label"] for row in view["rows"]]
    assert not ui.action("play_pause")["playing"]
    view = ui.action("row", 0)
    assert view["receiver"] == "SoundCore 2" and not view["playing"]
    assert ui.action("play_pause")["playing"]


def test_forget_confirmation_cancel_then_confirm_removes_saved_device():
    ui = PrototypeUI(tracks())
    start(ui)
    open_saved_speaker(ui)
    view = ui.action("row", 1)
    assert view["title"] == "Forget device?" and view["selected"] == 0
    view = ui.action("select")  # cancel is default
    assert view["receiver"] == "SoundCore 2"
    ui.action("row", 1)
    view = ui.action("row", 1)
    assert view["title"] == "Saved devices" and view["rows"] == []
    assert view["receiver"] is None and not view["playing"]


def test_discovery_and_pairing_only_change_receiver_after_explicit_selection():
    ui = PrototypeUI(tracks())
    ui.action("row", 2)
    view = ui.action("row", 1)
    assert "Demo discovery" in view["notice"]
    view = ui.action("row", 1)
    assert view["receiver"] == "SoundCore 2"
    assert view["rows"][0]["label"] == "Pair and connect"
    view = ui.action("row", 0)
    assert view["receiver"] == "Living Room Speaker"
    ui.action("back")
    ui.action("back")
    view = ui.action("row", 0)
    assert len(view["rows"]) == 2


def test_unknown_metadata_has_readable_fallbacks():
    ui = PrototypeUI([Track("x", " ", "", None, None, None, "/x.mp3")])
    view = start(ui)
    assert view["track"] == {"title": "Untitled", "artist": "Unknown Artist",
                            "album": "Unknown Album", "duration": None}
    assert ui.action("tick", 4)["elapsed"] == 4


def test_unknown_duration_pause_resume_preserves_elapsed():
    ui = PrototypeUI([Track("x", None, None, None, None, None, "/x.mp3"),
                      Track("y", "Named", None, None, None, None, "/y.mp3")])
    start(ui)
    ui.action("tick", 4)
    ui.action("play_pause")
    assert ui.action("play_pause")["elapsed"] == 4
