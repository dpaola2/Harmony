"""Bounded Mark-5 bench player. Inject the pinned driver/font/SD and core classes.

Starts silent, mounts SD read-only, and requires PLAY to begin. Audio, display,
and input use the verified bench wiring; core transport has no hardware imports.
No boot script is installed by this module.
"""

from machine import Pin, SPI, SoftSPI
from time import sleep_ms, ticks_ms, ticks_diff
import gc
import hashlib
import vfs
import json
import os


class Mark5Audio:
    def __init__(self, sdcard_class):
        self.reset = Pin(32, Pin.OUT, value=0)
        self.cs = Pin(33, Pin.OUT, value=1)
        self.xdcs = Pin(26, Pin.OUT, value=1)
        self.sdcs = Pin(25, Pin.OUT, value=1)
        self.dreq = Pin(4, Pin.IN)
        self.spi = SPI(2, baudrate=500_000, polarity=0, phase=0,
                       sck=Pin(18), mosi=Pin(23), miso=Pin(19))
        self.active = self.mounted = self.playing = self.ended = False
        self.file = None
        self.volume = 58
        self.buf = bytearray(2048)
        self.view = memoryview(self.buf)
        self.packets = [self.view[n:n + 32] for n in range(0, 2048, 32)]
        self.tx = bytearray(4)
        self.rx = bytearray(4)
        self.offset = self.count = self.sent = 0
        try:
            self.reset_decoder()
            sd = sdcard_class(self.spi, self.sdcs)
            vfs.mount(vfs.VfsFat(sd), "/sd", readonly=True)
            self.mounted = True
            self.spi.init(baudrate=1_320_000)
        except BaseException:
            self.close()
            raise

    def ready(self):
        start = ticks_ms()
        while not self.dreq.value():
            if ticks_diff(ticks_ms(), start) > 1500:
                raise RuntimeError("Audio DREQ timeout")
            sleep_ms(1)

    def read(self, address):
        self.ready()
        self.tx[0], self.tx[1], self.tx[2], self.tx[3] = 3, address, 255, 255
        self.cs.value(0)
        try:
            self.spi.write_readinto(self.tx, self.rx)
        finally:
            self.cs.value(1)
        self.ready()
        return (self.rx[2] << 8) | self.rx[3]

    def write(self, address, value):
        self.ready()
        self.tx[0], self.tx[1] = 2, address
        self.tx[2], self.tx[3] = value >> 8, value & 255
        self.cs.value(0)
        try:
            self.spi.write(self.tx)
        finally:
            self.cs.value(1)
        self.ready()

    def reset_decoder(self):
        self.spi.init(baudrate=500_000)
        self.reset.value(0)
        sleep_ms(20)
        self.reset.value(1)
        sleep_ms(100)
        if ((self.read(1) >> 4) & 15) != 4:
            raise RuntimeError("VS1053 identification failed")
        self.active = True
        self.write(11, 0xFEFE)
        self.write(0, 0x4800)
        self.write(3, 0x8800)
        self.write(2, 0)
        self.write(7, 0xC017)
        self.write(6, 0)
        self.spi.init(baudrate=1_320_000)

    def buttons(self):
        self.write(7, 0xC018)
        return self.read(6) & 0x7C

    def set_volume(self, level):
        self.volume = max(0, min(100, level))
        # Bench range: mute at zero, approximately -60..-20 dB otherwise.
        # Level 58 reproduces Dave's chosen -37 dB listening setting.
        attenuation = int(120 - self.volume * 0.8 + 0.5)
        value = 0xFEFE if self.volume == 0 else (attenuation << 8) | attenuation
        if self.active:
            self.write(11, value)

    def play(self, track):
        self.stop()
        self.reset_decoder()
        self.file = open(track.path, "rb")
        self.track = track
        self.offset = self.count = self.sent = 0
        self.digest = hashlib.sha256()
        self.ended = False
        self.set_volume(self.volume)
        self.playing = True

    def pause(self):
        # Stop feeding; already buffered audio drains briefly, without discarding
        # file bytes or resetting the decoder. Resume continues the same stream.
        self.playing = False

    def resume(self):
        if self.file is not None and not self.ended:
            self.playing = True

    def stop(self):
        self.playing = False
        if self.active:
            self.write(11, 0xFEFE)
        if self.file is not None:
            self.file.close()
            self.file = None

    def send(self, packet):
        self.ready()
        self.xdcs.value(0)
        try:
            self.spi.write(packet)
        finally:
            self.xdcs.value(1)

    def finish(self):
        decoded_seconds = self.read(4)
        self.write(7, 0x1E06)
        fill = bytes((self.read(6) & 255,)) * 32
        for _ in range(65):
            self.send(fill)
        self.write(0, self.read(0) | 8)
        for _ in range(64):
            self.send(fill)
            if not self.read(0) & 8:
                break
        else:
            raise RuntimeError("Audio EOF cancellation timeout")
        if self.read(8) or self.read(9):
            raise RuntimeError("Audio EOF registers did not clear")
        checksum = self.digest.digest().hex()
        expected_size = getattr(self.track, "expected_bytes", None)
        expected_hash = getattr(self.track, "expected_sha256", None)
        if ((expected_size is not None and self.sent != expected_size)
                or (expected_hash is not None and checksum != expected_hash)):
            self.stop()
            raise RuntimeError("Track data checksum or size mismatch: " + self.track.title)
        print("TRACK_EOF", self.track.id, self.sent, checksum)
        self.last_completion = {"id": self.track.id, "bytes": self.sent,
                                "sha256": checksum, "decode_seconds": decoded_seconds}
        self.stop()
        self.ended = True

    def pump(self):
        if not self.playing:
            return
        for _ in range(8):
            if not self.dreq.value():
                return
            if self.offset >= self.count:
                self.count = self.file.readinto(self.buf)
                self.offset = 0
                if not self.count:
                    self.finish()
                    return
                self.digest.update(self.view[:self.count])
            end = min(self.offset + 32, self.count)
            packet = self.packets[self.offset // 32] if end - self.offset == 32 else self.view[self.offset:end]
            self.send(packet)
            self.sent += end - self.offset
            self.offset = end

    def close(self):
        try:
            self.stop()
        finally:
            self.reset.value(0)
            self.cs.value(1)
            self.xdcs.value(1)
            self.sdcs.value(1)
            try:
                if self.mounted:
                    vfs.umount("/sd")
                    self.mounted = False
            finally:
                self.active = False
                self.spi.deinit()


class Mark5Screen:
    def __init__(self, driver, font):
        self.font = font
        self.driver = driver
        self.cs = Pin(21, Pin.OUT, value=1)
        self.spi = SoftSPI(baudrate=250_000, polarity=0, phase=0,
                       sck=Pin(14), mosi=Pin(13), miso=Pin(35))
        try:
            self.tft = driver.ST7789(self.spi, 135, 240,
                reset=Pin(27, Pin.OUT, value=1), dc=Pin(22, Pin.OUT, value=0),
                cs=self.cs, rotation=1, color_order=driver.BGR)
            self.lines = [" " * 28] * 6
            self.targets = self.lines[:]
        except BaseException:
            self.close()
            raise

    def draw(self, player, elapsed):
        track = player.track
        lines = ["HARMONY  %d/%d" % (player.index + 1, len(player.tracks)),
                 track.title, track.artist + " / " + track.album,
                 "%s %d:%02d / %d:%02d" % (player.status, elapsed // 60, elapsed % 60,
                                           track.duration_secs // 60, track.duration_secs % 60),
                 "Volume %d / 100" % player.volume, player.last_action]
        for i, text in enumerate(lines):
            text = text[:28]
            self.targets[i] = text + " " * (28 - len(text))

    def step(self):
        # One opaque 8x16 glyph per loop keeps each display transfer short.
        # Audio pumping and button polling run between glyphs, even on SoftSPI.
        for row in range(6):
            old, target = self.lines[row], self.targets[row]
            if old == target:
                continue
            for col in range(28):
                if old[col] != target[col]:
                    y = (4, 24, 44, 66, 88, 110)[row]
                    color = self.driver.CYAN if row == 0 else self.driver.WHITE
                    self.tft.text(self.font, target[col], 6 + col * 8, y,
                                  color, self.driver.BLACK)
                    self.lines[row] = old[:col] + target[col] + old[col + 1:]
                    return True
        return False

    def close(self):
        self.cs.value(1)
        self.spi.deinit()


def run_player(sdcard_class, driver, font, transport_class, track_class, seconds=180,
               manifest_path=None, album_loader=None, stop_on_album_end=False,
               volume=58, autoplay=False):
    if not 15 <= seconds <= 7200:
        raise ValueError("Use a bounded 15..7200-second bench session")
    audio = screen = None
    events = []
    completed_tracks = []
    completed_details = []
    try:
        audio = Mark5Audio(sdcard_class)
        if manifest_path is None:
            tracks = [track_class("higher", "Higher", "Creed", "Human Clay", 9, 317,
                                  "/sd/HARMONY/HIGHER.MP3")]
        else:
            if album_loader is None:
                raise ValueError("Album loader required")
            if os.stat(manifest_path)[6] > 65536:
                raise ValueError("Album manifest is too large")
            with open(manifest_path) as source:
                tracks = album_loader(json.load(source), manifest_path.rsplit("/", 1)[0], track_class)
            for track in tracks:
                if os.stat(track.path)[6] != track.expected_bytes:
                    raise ValueError("Missing or incomplete track: " + track.title)
        screen = Mark5Screen(driver, font)
        player = transport_class(tracks, audio, volume=volume)
        stable = candidate = audio.buttons()
        if stable:
            raise RuntimeError("Release all buttons before starting the player")
        actions = ((4, "play_pause"), (8, "next"), (16, "previous"),
                   (32, "volume_up"), (64, "volume_down"))
        screen.draw(player, 0)
        while screen.step():
            pass
        gc.collect()
        start = changed = last_poll = last_draw = ticks_ms()
        last_report = start
        print("PLAYER_READY", "silent until PLAY", "volume", player.volume,
              "session_seconds", seconds, "tracks", len(tracks))
        if autoplay:
            player.handle("play_pause")
            screen.draw(player, 0)
            print("AUTOPLAY", player.track.title, "volume", player.volume)
        while ticks_diff(ticks_ms(), start) < seconds * 1000:
            audio.pump()
            # Consume EOF before buttons can change the transport state.
            if audio.ended:
                completed_tracks.append(player.track.id)
                completed_details.append(audio.last_completion)
                audio.ended = False
                player.finished()
                print("ALBUM_ADVANCE", player.index + 1, player.status, player.track.title)
                screen.draw(player, audio.read(4))
                if player.status == "Ended" and stop_on_album_end:
                    break
            now = ticks_ms()
            if ticks_diff(now, last_poll) >= 40:
                bits = audio.buttons()
                last_poll = now
                if bits != candidate:
                    candidate = bits
                    changed = now
                elif candidate != stable and ticks_diff(now, changed) >= 30:
                    pressed = candidate & ~stable
                    stable = candidate
                    for mask, event in actions:
                        if pressed & mask:
                            player.handle(event)
                            events.append(event)
                            print("CONTROL", event, player.status, "volume", player.volume,
                                  "track", player.index + 1, player.track.title)
                            screen.draw(player, 0 if player.status == "Ready" else audio.read(4))
            if ticks_diff(now, last_draw) >= 500:
                screen.draw(player, 0 if player.status == "Ready" else audio.read(4))
                last_draw = now
            if ticks_diff(now, last_report) >= 30000:
                print("PLAYER_PROGRESS", player.status, "decode_seconds", audio.read(4),
                      "sent_bytes", audio.sent, "track", player.index + 1,
                      "heap_free", gc.mem_free())
                last_report = now
            screen.step()
            sleep_ms(1)
        result = {"events": events, "final_status": player.status,
                  "volume": player.volume, "sent_bytes_current_track": audio.sent,
                  "decode_seconds_current_track": audio.read(4),
                  "completed_tracks": completed_tracks, "track_count": len(tracks),
                  "completed_details": completed_details}
        audio.stop()
        if player.status != "Ended":
            player.status = "Stopped"
            player.last_action = "Bench test finished"
        screen.draw(player, result["decode_seconds_current_track"])
        while screen.step():
            pass
        print("PLAYER_SESSION_COMPLETED", result)
        return result
    finally:
        try:
            if audio is not None:
                audio.close()
        finally:
            if screen is not None:
                screen.close()
            print("PLAYER_STOPPED")
