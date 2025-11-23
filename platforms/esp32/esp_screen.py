"""ST7789V2 screen adapter for the ESP32 platform (Prototype 1)."""

import framebuf
import time
from machine import Pin, SPI


class ST7789:
    """Minimal ST7789V2 driver with a framebuffer blit helper."""

    def __init__(self, spi, cs, dc, rst, bl, width=240, height=280):
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

    def _write_cmd(self, cmd, data=None):
        self.cs.off()
        self.dc.off()
        self.spi.write(bytearray([cmd]))
        if data:
            self.dc.on()
            self.spi.write(data)
        self.cs.on()

    def _reset(self) -> None:
        self.rst.off()
        time.sleep_ms(50)
        self.rst.on()
        time.sleep_ms(50)

    def _init_panel(self) -> None:
        # Basic init sequence: 16-bit color, portrait, inversion on
        import time

        self._write_cmd(0x11)  # SLPOUT
        time.sleep_ms(120)

        self._write_cmd(0x3A, b"\x55")  # COLMOD: 16-bit color
        self._write_cmd(0x36, b"\x00")  # MADCTL: RGB, portrait
        self._write_cmd(0x21)  # INVON
        self._write_cmd(0x13)  # NORON
        self._write_cmd(0x29)  # DISPON
        time.sleep_ms(20)

    def _set_window(self, x0: int, y0: int, x1: int, y1: int) -> None:
        self._write_cmd(
            0x2A,
            bytes(
                [
                    (x0 >> 8) & 0xFF,
                    x0 & 0xFF,
                    (x1 >> 8) & 0xFF,
                    x1 & 0xFF,
                ]
            ),
        )
        self._write_cmd(
            0x2B,
            bytes(
                [
                    (y0 >> 8) & 0xFF,
                    y0 & 0xFF,
                    (y1 >> 8) & 0xFF,
                    y1 & 0xFF,
                ]
            ),
        )
        self._write_cmd(0x2C)  # MEMWRITE

    def blit(self, buf):
        """Write a full-screen RGB565 buffer to the panel."""
        self._set_window(0, 0, self.width - 1, self.height - 1)
        self.dc.on()
        self.cs.off()
        try:
            self.spi.write(buf)
        finally:
            self.cs.on()


class EspScreen:
    """
    Simple text-only renderer for the ST7789 using the core Screen protocol.

    - Uses an RGB565 framebuffer with `framebuf.text` for glyphs.
    - Color scheme: black background, white text.
    """

    def __init__(
        self,
        *,
        width=240,
        height=280,
        spi_id=2,
        baudrate=40_000_000,
        pin_clk=12,
        pin_mosi=11,
        pin_miso=13,
        pin_cs=9,
        pin_dc=8,
        pin_rst=18,
        pin_bl=17,
        x_padding=20,
        y_padding=40,
    ):
        spi = SPI(spi_id, baudrate=baudrate, sck=Pin(pin_clk), mosi=Pin(pin_mosi), miso=Pin(pin_miso))
        self.display = ST7789(
            spi=spi,
            cs=Pin(pin_cs, Pin.OUT),
            dc=Pin(pin_dc, Pin.OUT),
            rst=Pin(pin_rst, Pin.OUT),
            bl=Pin(pin_bl, Pin.OUT),
            width=width,
            height=height,
        )
        self.width = width
        self.height = height
        self._buf = bytearray(width * height * 2)
        self._fb = framebuf.FrameBuffer(self._buf, width, height, framebuf.RGB565)
        self.fg = 0x0010  # dark blue-ish text
        self.bg = 0xFFFF  # white
        self.x_padding = x_padding
        self.y_padding = y_padding
        self.clear()

    def clear(self) -> None:
        self._fb.fill(self.bg)

    def draw_text(self, x: int, y: int, text: str) -> None:
        # Treat x/y as character grid (like console renderer), not raw pixels.
        char_w = 8
        char_h = 10
        px = self.x_padding + x * char_w
        py = self.y_padding + y * char_h
        if py >= self.height - self.y_padding:
            return
        self._fb.text(text, px, py, self.fg)

    def refresh(self) -> None:
        self.display.blit(memoryview(self._buf))
