"""Mark-5 VS1053 control-interface check; no SD access or audio playback.

Pin assignments: hardware/mark-5/bench-config.json.
SCI protocol and version field: Adafruit_VS1053_Library / VLSI VS1053b.
"""

from machine import Pin, SPI
from time import sleep_ms, ticks_ms, ticks_diff


def probe():
    reset = Pin(32, Pin.OUT, value=0)
    cs = Pin(33, Pin.OUT, value=1)
    xdcs = Pin(26, Pin.OUT, value=1)
    sdcs = Pin(25, Pin.OUT, value=1)
    dreq = Pin(4, Pin.IN)
    spi = SPI(2, baudrate=500_000, polarity=0, phase=0,
              sck=Pin(18), mosi=Pin(23), miso=Pin(19))

    def ready():
        start = ticks_ms()
        while not dreq.value():
            if ticks_diff(ticks_ms(), start) > 1500:
                raise RuntimeError("DREQ timeout: check GPIO4, RST and power wiring")
            sleep_ms(1)

    def read_register(address):
        ready()
        tx = bytes((3, address, 255, 255))
        rx = bytearray(4)
        cs.value(0)
        try:
            spi.write_readinto(tx, rx)
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

    try:
        sleep_ms(20)
        reset_dreq = dreq.value()
        print("DREQ_DURING_RESET", reset_dreq)
        reset.value(1)
        sleep_ms(100)
        ready()
        statuses = [read_register(1) for _ in range(3)]
        print("SCI_STATUS", [hex(v) for v in statuses])
        if any(((v >> 4) & 15) != 4 for v in statuses):
            raise RuntimeError("Unexpected chip version: check CS, SCLK, MOSI and MISO")
        if reset_dreq != 0:
            raise RuntimeError("DREQ did not go low during reset: check RST and DREQ")
        for volume in (0x6464, 0x5050):
            write_register(11, volume)
            actual = read_register(11)
            print("SCI_VOL", hex(actual))
            if actual != volume:
                raise RuntimeError("Volume register readback mismatch")
        result = {"version": 4, "status_reads": statuses,
                  "mode": read_register(0), "volume": read_register(11),
                  "dreq_gpio": 4, "spi_hz": 500_000}
        print("VS1053_PROBE_PASS", result)
        return result
    except Exception:
        reset.value(0)
        raise
    finally:
        cs.value(1)
        xdcs.value(1)
        sdcs.value(1)
        spi.deinit()


if __name__ == "__main__":
    probe()
