"""Bounded VS1053 internal tone, optionally comparing idle/active SD.

VS1053b datasheet v1.33 section 10.12.1 specifies 16-byte test commands.
Run from RAM; no boot script or card writes. Listen for repetitive clicks.
"""

from machine import Pin, SPI
from time import sleep_ms, ticks_ms, ticks_diff
import vfs


def tone_probe(seconds=15, volume_db=-50, sdcard_class=None):
    if not 1 <= seconds <= 30 or not -60 <= volume_db <= -40:
        raise ValueError("Use 1..30 seconds at -60..-40 dB")
    reset = Pin(32, Pin.OUT, value=0)
    cs = Pin(33, Pin.OUT, value=1)
    xdcs = Pin(26, Pin.OUT, value=1)
    sdcs = Pin(25, Pin.OUT, value=1)
    dreq = Pin(4, Pin.IN)
    spi = SPI(2, baudrate=500_000, polarity=0, phase=0,
              sck=Pin(18), mosi=Pin(23), miso=Pin(19))
    initialized = False
    mounted = False
    track = None

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

    def command(data):
        ready()
        xdcs.value(0)
        try:
            spi.write(data)
        finally:
            xdcs.value(1)

    try:
        sleep_ms(20)
        reset.value(1)
        sleep_ms(100)
        if ((read_register(1) >> 4) & 15) != 4:
            raise RuntimeError("VS1053 identification failed")
        write_register(11, 0xFEFE)
        initialized = True
        write_register(0, 0x4820)  # SM_SDINEW, SM_LINE1, SM_TESTS.
        write_register(3, 0x8800)
        write_register(2, 0)
        if sdcard_class is not None:
            sd = sdcard_class(spi, sdcs)
            vfs.mount(vfs.VfsFat(sd), "/sd", readonly=True)
            mounted = True
            spi.init(baudrate=1_320_000)
            track = open("/sd/HARMONY/HIGHER.MP3", "rb")
            read_buf = bytearray(2048)
        attenuation = int(-volume_db * 2)
        volume = (attenuation << 8) | attenuation
        write_register(11, volume)
        if read_register(11) != volume:
            raise RuntimeError("Volume readback failed")
        sleep_ms(500)
        print("TONE_START", "500 Hz", "seconds", seconds, "volume_db", volume_db)
        # FsIdx=2 (32000 Hz), S=2: 32000*2/128 = 500 Hz.
        command(bytes((0x53, 0xEF, 0x6E, 0x42)) + bytes(12))
        sleep_ms(seconds * 1000)
        if track is not None:
            print("TONE_SD_ACTIVE", "one 2048-byte read every 500 ms", "seconds", seconds)
            start = ticks_ms()
            reads = 0
            while ticks_diff(ticks_ms(), start) < seconds * 1000:
                before = ticks_ms()
                if track.readinto(read_buf) != len(read_buf):
                    raise RuntimeError("Incomplete diagnostic card read")
                reads += 1
                sleep_ms(max(0, 500 - ticks_diff(ticks_ms(), before)))
            print("TONE_SD_IDLE_AGAIN", "reads", reads, "seconds", seconds)
            sleep_ms(seconds * 1000)
        write_register(11, 0xFEFE)
        command(b"Exit" + bytes(12))
        print("TONE_COMMANDS_COMPLETED", "listening verdict required")
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
                if track is not None:
                    track.close()
            finally:
                try:
                    if mounted:
                        vfs.umount("/sd")
                finally:
                    spi.deinit()
                    print("TONE_STOPPED")
