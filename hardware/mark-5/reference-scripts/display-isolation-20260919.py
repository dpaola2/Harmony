from machine import Pin, SPI, SoftSPI
from time import sleep_ms

def display_isolation():
    Pin(32, Pin.OUT, value=0)
    Pin(33, Pin.OUT, value=1)
    Pin(26, Pin.OUT, value=1)
    Pin(25, Pin.OUT, value=1)
    # Release the hardware peripheral before testing identical pins with SoftSPI.
    old = SPI(1, baudrate=1000000, sck=Pin(14), mosi=Pin(13), miso=Pin(35))
    old.deinit()
    cs = Pin(21, Pin.OUT, value=1)
    dc = Pin(22, Pin.OUT, value=0)
    rst = Pin(27, Pin.OUT, value=1)
    spi = SoftSPI(baudrate=250000, polarity=0, phase=0,
                  sck=Pin(14), mosi=Pin(13), miso=Pin(35))
    def command(value, data=None):
        cs.value(0)
        try:
            dc.value(0)
            spi.write(bytes((value,)))
            if data is not None:
                dc.value(1)
                spi.write(data)
        finally:
            cs.value(1)
    try:
        rst.value(0)
        sleep_ms(100)
        rst.value(1)
        sleep_ms(150)
        command(0x01)
        sleep_ms(150)
        command(0x11)
        sleep_ms(150)
        command(0x3A, b'\x55')
        command(0x36, b'\x00')
        command(0x21)
        command(0x13)
        command(0x29)
        sleep_ms(100)
        command(0x2A, b'\x00\x00\x00\xef')
        command(0x2B, b'\x00\x00\x01\x3f')
        # Fill the entire controller RAM, avoiding any panel-offset assumptions.
        cs.value(0)
        dc.value(0)
        spi.write(b'\x2c')
        dc.value(1)
        white = b'\xff' * 512
        for _ in range(300):
            spi.write(white)
        cs.value(1)
        print('DISPLAY_ISOLATION_SENT', '250 kHz SoftSPI; entire 240x320 GRAM white')
        print('DISPLAY_PIN_LEVELS', 'RST', rst.value(), 'CS', cs.value(), 'DC', dc.value())
    finally:
        cs.value(1)
        spi.deinit()

display_isolation()
