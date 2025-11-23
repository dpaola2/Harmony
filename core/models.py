class _Const:
    """Tiny helper to mimic Enum members without importing enum (MicroPython-friendly)."""

    def __init__(self, name, value=None):
        self.name = name
        self.value = value if value is not None else name

    def __repr__(self):
        return f"<{self.name}>"

    def __eq__(self, other):
        return isinstance(other, _Const) and self.name == getattr(other, "name", None)

    def __hash__(self):
        return hash(self.name)


class ButtonEvent:
    """Logical input events independent of hardware details."""

    UP = _Const("UP")
    DOWN = _Const("DOWN")
    LEFT = _Const("LEFT")
    RIGHT = _Const("RIGHT")
    SELECT = _Const("SELECT")
    BACK = _Const("BACK")
    PLAY_PAUSE = _Const("PLAY_PAUSE")
    VOLUME_UP = _Const("VOLUME_UP")
    VOLUME_DOWN = _Const("VOLUME_DOWN")


class ScreenID:
    """High-level screens used by the state machine."""

    ROOT = _Const("ROOT", "root")
    LIBRARY = _Const("LIBRARY", "library")
    NOW_PLAYING = _Const("NOW_PLAYING", "now_playing")
    SETTINGS = _Const("SETTINGS", "settings")


class LibraryLevel:
    """Navigation level within the Library drilldown."""

    ARTISTS = _Const("ARTISTS")
    ALBUMS = _Const("ALBUMS")
    TRACKS = _Const("TRACKS")


class Track:
    """Basic metadata for a track."""

    def __init__(self, id, title, artist, album, track_number, duration_secs, path):
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.track_number = track_number
        self.duration_secs = duration_secs
        self.path = path  # local file path on PC or device


class PlayerState:
    """State shared across screens and platform implementations."""

    def __init__(self, tracks=None):
        self.tracks = tracks or []
        # Root navigation
        self.root_index = 0  # which root menu item is highlighted
        self.current_screen = ScreenID.ROOT
        # Library drilldown navigation
        self.library_level = LibraryLevel.ARTISTS
        self.selected_artist_index = 0
        self.selected_album_index = 0
        self.selected_track_index = 0
        # Playback
        self.playing_index = None
        self.is_playing = False
        self.volume = 50  # 0-100
