"""Read-only Mark-5 SD test. Pass the pinned sdcard.SDCard class to probe()."""

from machine import Pin, SPI
from time import ticks_ms, ticks_us, ticks_diff
import hashlib
import os
import vfs


def probe(sdcard_class, spi_hz=1_320_000, chunk_bytes=2048):
    if spi_hz not in (1_320_000, 4_000_000) or chunk_bytes not in (512, 2048, 4096):
        raise ValueError("Use a validated bench speed and 512/2048/4096-byte reads")
    # Keep both VS1053 interfaces deselected throughout the storage test.
    cs = Pin(33, Pin.OUT, value=1)
    xdcs = Pin(26, Pin.OUT, value=1)
    reset = Pin(32, Pin.OUT, value=0)
    sdcs = Pin(25, Pin.OUT, value=1)
    spi = SPI(2, baudrate=100_000, polarity=0, phase=0,
              sck=Pin(18), mosi=Pin(23), miso=Pin(19))
    mounted = False
    try:
        sd = sdcard_class(spi, sdcs)
        print("SD_SECTORS", sd.sectors)
        vfs.mount(vfs.VfsFat(sd), "/sd", readonly=True)
        mounted = True
        spi.init(baudrate=spi_hz)
        path = "/sd/HARMONY/HIGHER.MP3"
        size = os.stat(path)[6]
        print("TRACK_BYTES", size)
        if size != 5070386:
            raise RuntimeError("Unexpected Higher file size")
        digest = hashlib.sha256()
        total = 0
        last_report = 0
        buf = bytearray(chunk_bytes)
        view = memoryview(buf)
        max_read_us = 0
        max_read_offset = 0
        read_us_total = 0
        read_count = 0
        reads_over_20ms = 0
        reads_over_50ms = 0
        reads_over_100ms = 0
        start = ticks_ms()
        with open(path, "rb") as track:
            while True:
                before = ticks_us()
                count = track.readinto(buf)
                duration = ticks_diff(ticks_us(), before)
                if not count:
                    break
                read_count += 1
                read_us_total += duration
                if duration > max_read_us:
                    max_read_us = duration
                    max_read_offset = total
                reads_over_20ms += duration >= 20000
                reads_over_50ms += duration >= 50000
                reads_over_100ms += duration >= 100000
                digest.update(view[:count])
                total += count
                if total - last_report >= 1024 * 1024:
                    print("READ_BYTES", total)
                    last_report = total
                if ticks_diff(ticks_ms(), start) > 180000:
                    raise RuntimeError("SD full-file read exceeded 180 seconds")
        elapsed = ticks_diff(ticks_ms(), start)
        actual = digest.digest().hex()
        print("SHA256", actual)
        if total != size or actual != "0fbc69ad617c28395ed4b6c62571ac63898a057309a872a73d4aad6a303ca6dd":
            raise RuntimeError("SD file differs from verified Mac copy")
        result = {"bytes": total, "elapsed_ms": elapsed,
                  "sha256": actual, "readonly": True,
                  "sdcs_gpio": 25, "spi": str(spi), "chunk_bytes": chunk_bytes,
                  "max_read_us": max_read_us, "max_read_offset": max_read_offset,
                  "mean_read_us": read_us_total // read_count,
                  "reads_over_20ms": reads_over_20ms,
                  "reads_over_50ms": reads_over_50ms,
                  "reads_over_100ms": reads_over_100ms}
        print("SD_PROBE_PASS", result)
        return result
    finally:
        try:
            if mounted:
                vfs.umount("/sd")
        finally:
            cs.value(1)
            xdcs.value(1)
            sdcs.value(1)
            reset.value(0)
            spi.deinit()
