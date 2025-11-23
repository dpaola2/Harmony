"""Minimal ST7789V2 smoke test for ESP32-S3 (Prototype 1).

Fills the 240x280 panel with a solid color to confirm wiring. Assumes pins:
    CLK=12, DIN=11, CS=9, DC=8, RST=18, BL=17 (tie BL high if not used).
Run with:
    mpremote connect /dev/tty.usbmodem* run display_test.py
"""

import time

from machine import Pin, SPI


class ST7789:
    def __init__(self, spi: SPI, cs: Pin, dc: Pin, rst: Pin, bl: Pin, width: int = 240, height: int = 280):
        self.spi = spi
        self.cs = cs
        self.dc = dc
        self.rst = rst
        self.bl = bl
        self.width = width
        self.height = height

        self.cs.init(Pin.OUT, value=1)
        self.dc.init(Pin.OUT, value=0)
        self.rst.init(Pin.OUT, value=1)
        self.bl.init(Pin.OUT, value=1)

        self._reset()
        self._init_panel()

    def _write_cmd(self, cmd: int, data: bytes | None = None) -> None:
        self.cs.off()
        self.dc.off()
        self.spi.write(bytearray([cmd]))
        if data:
            self.dc.on()
            self.spi.write(data)
        self.cs.on()

    def _write_data(self, data: bytes) -> None:
        self.cs.off()
        self.dc.on()
        self.spi.write(data)
        self.cs.on()

    def _reset(self) -> None:
        self.rst.off()
        time.sleep_ms(50)
        self.rst.on()
        time.sleep_ms(50)

    def _init_panel(self) -> None:
        self._write_cmd(0x11)  # SLPOUT
        time.sleep_ms(120)

        self._write_cmd(0x3A, b"\x55")  # COLMOD: 16-bit color
        self._write_cmd(0x36, b"\x00")  # MADCTL: RGB, portrait
        self._write_cmd(0x21)  # INVON
        self._write_cmd(0x13)  # NORON
        self._write_cmd(0x29)  # DISPON
        time.sleep_ms(20)

    def _set_window(self, x0: int, y0: int, x1: int, y1: int) -> None:
        # Column address set (16-bit big-endian per register spec)
        self._write_cmd(
            0x2A,
            bytes([
                (x0 >> 8) & 0xFF,
                x0 & 0xFF,
                (x1 >> 8) & 0xFF,
                x1 & 0xFF,
            ]),
        )
        # Row address set
        self._write_cmd(
            0x2B,
            bytes([
                (y0 >> 8) & 0xFF,
                y0 & 0xFF,
                (y1 >> 8) & 0xFF,
                y1 & 0xFF,
            ]),
        )
        self._write_cmd(0x2C)  # MEMWRITE

    def fill(self, color565: int) -> None:
        self._set_window(0, 0, self.width - 1, self.height - 1)

        hi = (color565 >> 8) & 0xFF
        lo = color565 & 0xFF
        chunk = bytearray(512)
        for i in range(0, len(chunk), 2):
            chunk[i] = hi
            chunk[i + 1] = lo

        pixels = self.width * self.height
        self.dc.on()
        self.cs.off()
        try:
            while pixels > 0:
                batch = min(pixels, len(chunk) // 2)
                self.spi.write(memoryview(chunk)[: batch * 2])
                pixels -= batch
        finally:
            self.cs.on()


def main() -> None:
    spi = SPI(2, baudrate=40_000_000, sck=Pin(12), mosi=Pin(11), miso=Pin(13))
    display = ST7789(
        spi=spi,
        cs=Pin(9, Pin.OUT),
        dc=Pin(8, Pin.OUT),
        rst=Pin(18, Pin.OUT),
        bl=Pin(17, Pin.OUT),
    )

    print("Filling screen red…")
    display.fill(0xF800)
    time.sleep(1)
    print("Filling screen green…")
    display.fill(0x07E0)
    time.sleep(1)
    print("Filling screen blue…")
    display.fill(0x001F)
    time.sleep(1)
    print("Done.")


if __name__ == "__main__":
    main()
