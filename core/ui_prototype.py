"""Deterministic desktop interaction model; no audio or Bluetooth hardware I/O."""

from .library import Library, UNKNOWN_ALBUM, UNKNOWN_ARTIST


def _text(value, fallback):
    return value.strip() if value and value.strip() else fallback


class PrototypeUI:
    """A menu stack and playback queue kept independent of one another.

    Bluetooth actions simulate outcomes. Volume, bonds, and navigation last only
    for this instance. The native ESP-IDF player does not use this class.
    """

    def __init__(self, tracks):
        self.tracks = list(tracks)
        self.library = Library(self.tracks)
        self.stack = [{"screen": "root", "selected": 0, "data": None}]
        self.queue = []
        self.queue_index = 0
        self.playing = False
        self.elapsed = 0.0
        self.volume = 25
        self.repeat = "Off"
        self.notice = "Desktop prototype: audio and Bluetooth are simulated."
        self.devices = {
            "soundcore": {"name": "SoundCore 2", "address": "…35:43", "saved": True},
            "demo": {"name": "Living Room Speaker", "address": "DEMO 02", "saved": False},
        }
        self.connected = "soundcore"

    @property
    def frame(self):
        return self.stack[-1]

    def _push(self, screen, data=None):
        self.stack.append({"screen": screen, "selected": 0, "data": data})

    def _current_track(self):
        return self.tracks[self.queue[self.queue_index]] if self.queue else None

    def _track_order(self, index):
        track = self.tracks[index]
        return (getattr(track, "disc_number", 1),
                track.track_number if track.track_number is not None else 10_000_000,
                _text(track.title, "Untitled"))

    def _album_tracks(self, artist, album):
        return sorted(self.library.album_index.get((artist, album), []), key=self._track_order)

    def _row(self, label, detail="", target=None, data=None, playing=False):
        return {"label": label, "detail": detail, "playing": playing,
                "chevron": target is not None, "target": target, "data": data}

    def _rows(self):
        screen, data = self.frame["screen"], self.frame["data"]
        row = self._row
        if screen == "root":
            return [row("Music", "%d songs" % len(self.tracks), "music"),
                    row("Now Playing", "Your current queue", "playing"),
                    row("Bluetooth", "Simulated devices", "bluetooth"),
                    row("Settings", "Prototype preferences", "settings")]
        if screen == "music":
            return [row(label, "", target) for label, target in
                    [("Artists", "artists"), ("Albums", "albums"),
                     ("Songs", "songs"), ("Playlists", "playlists")]]
        if screen == "artists":
            return [row(artist, ("%d album" % len(self.library.albums_for_artist(artist))) +
                        ("s" if len(self.library.albums_for_artist(artist)) != 1 else ""),
                        "artist", artist) for artist in self.library.artists()]
        if screen in ("artist", "albums"):
            albums = ([(data, album) for album in self.library.albums_for_artist(data)]
                      if screen == "artist" else
                      sorted(self.library.album_index, key=lambda pair: (pair[1], pair[0])))
            return [row(album, artist, "album", (artist, album)) for artist, album in albums]
        if screen in ("songs", "album", "playlist"):
            indices = self._visible_tracks()
            current = self.queue[self.queue_index] if self.queue else None
            return [row(_text(self.tracks[index].title, "Untitled"),
                        _text(self.tracks[index].artist, UNKNOWN_ARTIST),
                        "start", index, index == current) for index in indices]
        if screen == "playlists":
            return [row("Trial run", "%d songs" % len(self.tracks), "playlist", "Trial run")]
        if screen == "bluetooth":
            return [row("Saved devices", "Simulated pairings", "saved"),
                    row("Find devices", "Simulated discovery", "discovery")]
        if screen in ("saved", "discovery"):
            return [row(device["name"],
                        ("Connected · " if key == self.connected else "") + device["address"],
                        "device", key) for key, device in self.devices.items()
                    if screen == "discovery" or device["saved"]]
        if screen == "device":
            device = self.devices[data]
            connected = data == self.connected
            choices = [row("Disconnect" if connected else
                           ("Connect" if device["saved"] else "Pair and connect"),
                           "Simulated", "disconnect" if connected else "connect", data)]
            if device["saved"]:
                choices.append(row("Forget device", "Remove this simulated pairing", "forget", data))
            return choices
        if screen == "confirm_forget":
            return [row("Cancel", "Keep saved device", "cancel"),
                    row("Forget " + self.devices[data]["name"],
                        "Remove local simulated pairing", "confirm", data)]
        if screen == "settings":
            return [row("Repeat", self.repeat, "repeat"),
                    row("Shuffle", "Deferred", "deferred", "Shuffle"),
                    row("Display timeout", "Deferred", "deferred", "Display timeout")]
        return []

    def _visible_tracks(self):
        screen, data = self.frame["screen"], self.frame["data"]
        if screen == "album":
            return self._album_tracks(*data)
        if screen == "playlist":
            return list(range(len(self.tracks)))
        if screen == "songs":
            return sorted(range(len(self.tracks)),
                          key=lambda index: (_text(self.tracks[index].title, "Untitled"), index))
        return []

    def _activate(self, item):
        target, data = item["target"], item["data"]
        if target == "start":
            self.queue = self._visible_tracks()
            self.queue_index = self.queue.index(data)
            self.elapsed = 0.0
            self.playing = self.connected is not None
            if not self.playing:
                self.notice = "Connect a simulated speaker, then press play."
            self._push("playing")
        elif target == "connect":
            self.devices[data]["saved"] = True
            self.connected = data
            self.notice = "Simulated connection to " + self.devices[data]["name"]
        elif target == "disconnect":
            self.connected = None
            self.playing = False
            self.notice = "Disconnected. Pairing kept; playback paused."
        elif target == "forget":
            self._push("confirm_forget", data)
        elif target == "cancel":
            self.stack.pop()
        elif target == "confirm":
            self.devices[data]["saved"] = False
            if self.connected == data:
                self.connected = None
                self.playing = False
            self.stack.pop()  # confirmation
            self.stack.pop()  # device actions
            self.frame["selected"] = min(self.frame["selected"], max(0, len(self._rows()) - 1))
            self.notice = "Local simulated pairing removed. Receiver records are unchanged."
        elif target == "repeat":
            modes = ["Off", "All", "One"]
            self.repeat = modes[(modes.index(self.repeat) + 1) % len(modes)]
        elif target == "deferred":
            self.notice = data + " is planned and is not implemented in this prototype."
        elif target:
            self._push(target, data)
            if target == "discovery":
                self.notice = "Demo discovery results; no Bluetooth scan is running."

    def _toggle_playback(self):
        if not self.queue:
            self.notice = "Choose a song from Music to start a queue."
        elif self.connected is None:
            self.notice = "Connect a simulated speaker, then press play."
        else:
            duration = self._current_track().duration_secs
            if not self.playing and duration and self.elapsed >= duration:
                self.elapsed = 0.0
            self.playing = not self.playing

    def _skip(self, direction, automatic=False):
        if not self.queue:
            return
        if automatic and self.repeat == "One":
            self.elapsed = 0.0
            return
        position = self.queue_index + direction
        if position >= len(self.queue):
            if self.repeat == "All":
                position = 0
            else:
                self.playing = False
                self.elapsed = float(self._current_track().duration_secs or 0)
                return
        if position < 0:
            position = len(self.queue) - 1 if self.repeat == "All" else 0
        self.queue_index = position
        self.elapsed = 0.0

    def _tick(self, seconds):
        remaining = max(0.0, min(float(seconds), 86400.0))
        while remaining > 0 and self.playing and self.queue:
            duration = self._current_track().duration_secs
            if not duration or duration <= 0:
                self.elapsed += remaining
                break
            advance = min(remaining, max(0.0, duration - self.elapsed))
            self.elapsed += advance
            remaining -= advance
            if self.elapsed >= duration:
                self._skip(1, automatic=True)

    def action(self, name, value=None):
        """Apply one logical control action and return its resulting snapshot."""
        if name != "tick":
            self.notice = ""
        if name == "rotate":
            delta = int(value or 0)
            if self.frame["screen"] == "playing":
                self.volume = max(0, min(100, self.volume + delta))
            else:
                self.frame["selected"] = max(0, min(max(0, len(self._rows()) - 1),
                                                     self.frame["selected"] + delta))
        elif name in ("select", "row"):
            if self.frame["screen"] == "playing":
                self._toggle_playback()
            else:
                rows = self._rows()
                if name == "row":
                    self.frame["selected"] = max(0, min(max(0, len(rows) - 1), int(value or 0)))
                if rows:
                    self._activate(rows[self.frame["selected"]])
        elif name == "back":
            if len(self.stack) > 1:
                self.stack.pop()
        elif name == "home":
            self.stack = self.stack[:1]
        elif name == "play_pause":
            self._toggle_playback()
        elif name in ("previous", "next"):
            self._skip(-1 if name == "previous" else 1)
        elif name == "tick":
            self._tick(value or 0)
        else:
            raise ValueError("Unknown prototype action: " + name)
        return self.snapshot()

    def snapshot(self):
        screen, data = self.frame["screen"], self.frame["data"]
        titles = {"root": "Harmony", "music": "Music", "artists": "Artists",
                  "albums": "Albums", "songs": "Songs", "playlists": "Playlists",
                  "playing": "Now Playing", "bluetooth": "Bluetooth", "saved": "Saved devices",
                  "discovery": "Find devices", "settings": "Settings", "confirm_forget": "Forget device?"}
        title = titles.get(screen, "Harmony")
        if screen == "artist" or screen == "playlist":
            title = data
        elif screen == "album":
            title = data[1]
        elif screen == "device":
            title = self.devices[data]["name"]
        rows = [{key: item[key] for key in ("label", "detail", "playing", "chevron")}
                for item in self._rows()]
        subtitle = "Bluetooth simulated" if screen in (
            "bluetooth", "saved", "discovery", "device", "confirm_forget") else "Desktop prototype"
        if screen == "album":
            subtitle = data[0]
        if not rows and screen != "playing":
            subtitle = "No saved devices. Use Find devices." if screen == "saved" else "No music in this view."
        track = self._current_track()
        return {"title": title, "subtitle": subtitle,
                "kind": "playing" if screen == "playing" else "list",
                "rows": rows, "selected": self.frame["selected"],
                "track": {"title": _text(track.title, "Untitled"),
                          "artist": _text(track.artist, UNKNOWN_ARTIST),
                          "album": _text(track.album, UNKNOWN_ALBUM),
                          "duration": track.duration_secs} if track else None,
                "playing": self.playing, "elapsed": self.elapsed, "volume": self.volume,
                "receiver": self.devices[self.connected]["name"] if self.connected else None,
                "queue_position": self.queue_index + 1 if self.queue else 0,
                "queue_count": len(self.queue), "notice": self.notice}
