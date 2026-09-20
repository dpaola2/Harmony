import pytest

from core.album import tracks_from_manifest
from core.models import Track


def entry(number, disc=1):
    return dict(file="%02d-%02d.MP3" % (disc, number), title="Song %d" % number,
                artist="Artist", album="Album", number=number, disc=disc,
                duration_secs=120, bytes=1920000, sha256="a" * 64)


def test_manifest_sorts_disc_and_track_and_preserves_metadata():
    tracks = tracks_from_manifest({"version": 1, "tracks": [entry(1, 2), entry(10), entry(2)]},
                                 "/sd/HARMONY/ALBUM", Track)
    assert [(t.disc_number, t.track_number) for t in tracks] == [(1, 2), (1, 10), (2, 1)]
    assert tracks[0].path == "/sd/HARMONY/ALBUM/01-02.MP3"
    assert tracks[0].title == "Song 2"
    assert tracks[0].expected_bytes == 1920000


@pytest.mark.parametrize("field,value", [("file", "../escape.mp3"), ("file", "/other.mp3"),
    ("file", "song.wav"), ("number", 0), ("duration_secs", -1), ("bytes", 0),
    ("sha256", "bad"), ("title", " ")])
def test_invalid_manifest_rejected(field, value):
    item = entry(1)
    item[field] = value
    with pytest.raises(ValueError):
        tracks_from_manifest({"version": 1, "tracks": [item]}, "/sd/album", Track)


def test_duplicate_tracks_and_empty_album_rejected():
    for entries in ([], [entry(1), entry(1)]):
        with pytest.raises(ValueError):
            tracks_from_manifest({"version": 1, "tracks": entries}, "/sd/album", Track)


@pytest.mark.parametrize("manifest", [None, {"version": 2, "tracks": [entry(1)]},
    {"version": 1, "tracks": [None]}])
def test_malformed_manifest_fails_before_track_loading(manifest):
    with pytest.raises(ValueError):
        tracks_from_manifest(manifest, "/sd/album", Track)
