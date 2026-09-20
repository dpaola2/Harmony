"""Low-volume Mark-5 playback check using the pinned SDCard class.

No automatic startup, filesystem writes, or UI. Each run resets the decoder
and ends muted with reset asserted. SCI/SDI protocol follows the VS1053b
datasheet; the selected upstream driver remains the full-player reference.
"""

from machine import Pin, SPI
from time import sleep_ms, ticks_ms, ticks_us, ticks_diff
import vfs
import hashlib
import gc


def playback_probe(sdcard_class, seconds=30, volume_db=-40, preload=False,
                   spi_hz=1_320_000, chunk_bytes=2048):
    if (seconds is not None and not 1 <= seconds <= 60) or not -60 <= volume_db <= -20:
        raise ValueError("Use 1..60 seconds or None for the full track, at -60..-20 dB")
    if preload and (seconds is None or seconds > 30):
        raise ValueError("RAM comparison is limited to a 1..30-second excerpt")
    if spi_hz not in (1_320_000, 4_000_000) or chunk_bytes not in (512, 2048):
        raise ValueError("Use a validated bench speed and 512/2048-byte reads")
    reset = Pin(32, Pin.OUT, value=0)
    cs = Pin(33, Pin.OUT, value=1)
    xdcs = Pin(26, Pin.OUT, value=1)
    sdcs = Pin(25, Pin.OUT, value=1)
    dreq = Pin(4, Pin.IN)
    spi = SPI(2, baudrate=500_000, polarity=0, phase=0,
              sck=Pin(18), mosi=Pin(23), miso=Pin(19))
    mounted = False
    initialized = False

    def ready():
        start = ticks_ms()
        while not dreq.value():
            if ticks_diff(ticks_ms(), start) > 1500:
                raise RuntimeError("Decoder DREQ timeout")
            sleep_ms(1)

    def read_register(address):
        ready()
        rx = bytearray(4)
        cs.value(0)
        try:
            spi.write_readinto(bytes((3, address, 255, 255)), rx)
        finally:
            cs.value(1)
        ready()
        return (rx[2] << 8) | rx[3]

    def write_register(address, value):
        ready()
        cs.value(0)
        try:
            spi.write(bytes((2, address, value >> 8, value & 255)))
        finally:
            cs.value(1)
        ready()

    def send_data(data):
        ready()
        xdcs.value(0)
        try:
            spi.write(data)
        finally:
            xdcs.value(1)

    def finish_track():
        # VS1053b normal EOF procedure, also used by the pinned upstream driver.
        write_register(7, 0x1E06)
        fill = bytes((read_register(6) & 255,)) * 32
        for _ in range(65):
            send_data(fill)  # 2080 end-fill bytes drain the decoder.
        write_register(0, read_register(0) | 0x08)
        for _ in range(64):
            send_data(fill)
            if not read_register(0) & 0x08:
                break
        else:
            raise RuntimeError("Decoder did not complete end-of-track cancellation")
        if read_register(8) or read_register(9):
            raise RuntimeError("Decoder HDAT registers did not clear at EOF")

    try:
        sleep_ms(20)
        reset.value(1)
        sleep_ms(100)
        ready()
        if ((read_register(1) >> 4) & 15) != 4:
            raise RuntimeError("VS1053 identification failed")
        write_register(11, 0xFEFE)
        initialized = True
        write_register(0, 0x4800)  # SM_SDINEW and SM_LINE1, no test mode.
        write_register(3, 0x8800)  # Decoder clock multiplier 3.5.
        sleep_ms(1)
        if read_register(3) != 0x8800:
            raise RuntimeError("Decoder clock readback failed")
        write_register(2, 0)  # Flat bass/treble.
        sd = sdcard_class(spi, sdcs)
        vfs.mount(vfs.VfsFat(sd), "/sd", readonly=True)
        mounted = True
        # 4 MHz remains below the SCI-read limit after CLOCKF is set to 3.5x.
        # Validate full-file SD checksums at the selected rate before playback.
        spi.init(baudrate=spi_hz)
        attenuation = int(-volume_db * 2)
        volume = (attenuation << 8) | attenuation
        with open("/sd/HARMONY/HIGHER.MP3", "rb") as track:
            if preload:
                # This specific track is 128 kbps CBR. Include decoder prefetch
                # and header headroom, loading while the output remains muted.
                gc.collect()
                preload_buf = bytearray(int((seconds + 3) * 16000))
                if track.readinto(preload_buf) != len(preload_buf):
                    raise RuntimeError("Incomplete RAM excerpt")
                preload_view = memoryview(preload_buf)
                preload_offset = 0
                print("RAM_EXCERPT_READY", len(preload_buf),
                      "sha256", hashlib.sha256(preload_buf).digest().hex())
            write_register(11, volume)
            if read_register(11) != volume:
                raise RuntimeError("Volume readback failed")
            buf = bytearray(chunk_bytes)
            view = memoryview(buf)
            packets = [view[n:n + 32] for n in range(0, len(buf), 32)]
            gc.collect()
            total = 0
            eof = False
            max_read_us = 0
            reads_over_20ms = 0
            reads_over_50ms = 0
            digest = hashlib.sha256()
            start = ticks_ms()
            report_interval = 30000 if seconds is None else 5000
            report_at = report_interval
            limit_ms = 390000 if seconds is None else seconds * 1000
            print("PLAYBACK_START", "full track" if seconds is None else seconds,
                  "volume_db", volume_db, "preload", preload)
            while ticks_diff(ticks_ms(), start) < limit_ms:
                if preload:
                    count = min(len(buf), len(preload_buf) - preload_offset)
                    view = preload_view[preload_offset:preload_offset + count]
                    preload_offset += count
                else:
                    before = ticks_us()
                    count = track.readinto(buf)
                    read_us = ticks_diff(ticks_us(), before)
                    max_read_us = max(max_read_us, read_us)
                    reads_over_20ms += read_us >= 20000
                    reads_over_50ms += read_us >= 50000
                if not count:
                    if preload:
                        raise RuntimeError("RAM excerpt exhausted before requested duration")
                    eof = True
                    break
                digest.update(view[:count])
                for offset in range(0, count, 32):
                    ready()
                    if ticks_diff(ticks_ms(), start) >= limit_ms:
                        break
                    end = min(offset + 32, count)
                    if not preload and end - offset == 32:
                        send_data(packets[offset // 32])
                    else:
                        send_data(view[offset:end])
                    total += end - offset
                elapsed = ticks_diff(ticks_ms(), start)
                if elapsed >= report_at:
                    print("PLAYBACK_PROGRESS", elapsed, total,
                          "decode_seconds", read_register(4))
                    report_at += report_interval
            result = {"sent_bytes": total, "elapsed_ms": ticks_diff(ticks_ms(), start),
                      "decode_seconds": read_register(4), "volume_db": volume_db,
                      "hdat1": read_register(9), "spi": str(spi), "eof": eof,
                      "preloaded": preload, "chunk_bytes": chunk_bytes,
                      "max_read_us": max_read_us,
                      "reads_over_20ms": reads_over_20ms,
                      "reads_over_50ms": reads_over_50ms}
            if result["decode_seconds"] == 0:
                raise RuntimeError("No decoded audio reported")
            if seconds is None:
                if not eof or total != 5070386:
                    raise RuntimeError("Full track did not reach the expected EOF")
                result["sha256"] = digest.digest().hex()
                if result["sha256"] != "0fbc69ad617c28395ed4b6c62571ac63898a057309a872a73d4aad6a303ca6dd":
                    raise RuntimeError("Track data checksum mismatch during playback")
                finish_track()
                result["end_of_track_drained"] = True
                result["total_elapsed_ms"] = ticks_diff(ticks_ms(), start)
            print("PLAYBACK_FEED_PASS", result)
            return result
    finally:
        try:
            if initialized:
                write_register(11, 0xFEFE)
        finally:
            reset.value(0)
            cs.value(1)
            xdcs.value(1)
            sdcs.value(1)
            try:
                if mounted:
                    vfs.umount("/sd")
            finally:
                spi.deinit()
            print("PLAYBACK_STOPPED")
