from __future__ import annotations

from pathlib import Path

from platforms.pc.track_loader import load_tracks_from_dir


def test_load_tracks_from_dir_parses_artist_album_and_numbers(tmp_path: Path) -> None:
    # Artist/Album with numbered files
    album_dir = tmp_path / "Artist A" / "Album X"
    album_dir.mkdir(parents=True)
    (album_dir / "01 - First.mp3").write_bytes(b"")
    (album_dir / "Second.mp3").write_bytes(b"")

    # Artist with files but no album folder
    artist_root = tmp_path / "Artist B"
    artist_root.mkdir()
    (artist_root / "03 Track.mp3").write_bytes(b"")

    # File with no artist folder
    (tmp_path / "Loose.mp3").write_bytes(b"")

    tracks = load_tracks_from_dir(str(tmp_path))
    # Expect 4 tracks
    assert len(tracks) == 4

    # Validate Artist A / Album X entries
    t1 = next(t for t in tracks if t.title == "First")
    assert t1.artist == "Artist A"
    assert t1.album == "Album X"
    assert t1.track_number == 1

    t2 = next(t for t in tracks if t.title == "Second")
    assert t2.artist == "Artist A"
    assert t2.album == "Album X"
    assert t2.track_number is None

    t3 = next(t for t in tracks if t.title == "Track")
    assert t3.artist == "Artist B"
    assert t3.album is None
    assert t3.track_number == 3

    t4 = next(t for t in tracks if t.title == "Loose")
    assert t4.artist is None
    assert t4.album is None
