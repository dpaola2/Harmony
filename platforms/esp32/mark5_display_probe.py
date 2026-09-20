"""Static Mark-5 display check, using the pinned st7789py driver and 8x16 font.

Call display_probe(driver_module, font_module) only after display wiring is
confirmed. The screen stays visible after SPI is released. No audio or SD I/O.
"""

from machine import Pin, SoftSPI


def display_probe(driver, font):
    # Keep the existing audio circuit silent and its SD card deselected.
    Pin(32, Pin.OUT, value=0)
    Pin(33, Pin.OUT, value=1)
    Pin(26, Pin.OUT, value=1)
    Pin(25, Pin.OUT, value=1)

    cs = Pin(21, Pin.OUT, value=1)
    dc = Pin(22, Pin.OUT, value=0)
    reset = Pin(27, Pin.OUT, value=1)
    spi = SoftSPI(baudrate=250_000, polarity=0, phase=0,
              sck=Pin(14), mosi=Pin(13), miso=Pin(35))
    # GPIO35 is only the unused controller input; no MISO wire is fitted.
    try:
        screen = driver.ST7789(spi, 135, 240, reset=reset, dc=dc, cs=cs,
                               rotation=1, color_order=driver.BGR)
        if screen.width != 240 or screen.height != 135:
            raise RuntimeError("Unexpected display geometry")
        screen.fill(driver.BLACK)
        screen.rect(0, 0, 240, 135, driver.WHITE)
        screen.text(font, "HARMONY", 8, 8, driver.WHITE, driver.BLACK)
        screen.text(font, "DISPLAY TEST", 8, 26, driver.WHITE, driver.BLACK)
        for x, color in ((4, driver.RED), (82, driver.GREEN), (160, driver.BLUE)):
            screen.fill_rect(x, 50, 76, 40, color)
        for x, label in ((38, "R"), (116, "G"), (194, "B")):
            screen.text(font, label, x, 94, driver.WHITE, driver.BLACK)
        screen.text(font, "240 x 135", 80, 114, driver.WHITE, driver.BLACK)
        print("DISPLAY_DRAW_COMPLETED", {"width": screen.width,
              "height": screen.height, "rotation": 1, "spi": str(spi)})
        print("VISUAL_CHECK_REQUIRED: upright text, complete white border, red/green/blue bars")
    finally:
        cs.value(1)
        spi.deinit()
