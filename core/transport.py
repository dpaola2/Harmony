"""Portable five-button transport for a now-playing screen."""


class Transport:
    def __init__(self, tracks, audio_backend, volume=58):
        self.tracks = tracks
        self.audio = audio_backend
        self.index = 0
        self.status = "Ready"
        self.volume = max(0, min(100, volume))
        self.last_action = "Press PLAY"
        self.audio.set_volume(self.volume)

    @property
    def track(self):
        return self.tracks[self.index] if self.tracks else None

    def handle(self, event):
        if event in ("volume_up", "volume_down"):
            delta = 5 if event == "volume_up" else -5
            self.volume = max(0, min(100, self.volume + delta))
            self.audio.set_volume(self.volume)
            self.last_action = "Volume up" if delta > 0 else "Volume down"
        elif self.track is None:
            return
        elif event == "play_pause":
            if self.status == "Playing":
                self.audio.pause()
                self.status = "Paused"
            elif self.status == "Paused":
                self.audio.resume()
                self.status = "Playing"
            else:
                if self.status == "Ended":
                    self.index = 0
                self.audio.play(self.track)
                self.status = "Playing"
            self.last_action = self.status
        elif event in ("next", "previous"):
            self.index = (self.index + (1 if event == "next" else -1)) % len(self.tracks)
            if self.status in ("Playing", "Paused"):
                paused = self.status == "Paused"
                self.audio.play(self.track)
                if paused:
                    self.audio.pause()
            else:
                self.status = "Ready"
            self.last_action = "Next" if event == "next" else "Previous"

    def finished(self):
        if self.status != "Playing" or self.track is None:
            return
        if self.index + 1 < len(self.tracks):
            self.index += 1
            self.audio.play(self.track)
            self.last_action = "Next track"
        else:
            self.status = "Ended"
            self.last_action = "Album finished"
