"""Silent, bounded VS1053 pushbutton check; no SD or display traffic."""

from machine import Pin, SPI
from time import sleep_ms, ticks_ms, ticks_diff


def button_probe(seconds=35, all_buttons=False):
    if not 5 <= seconds <= 60:
        raise ValueError("Use a 5..60-second observation window")
    mask = 0x7C if all_buttons else 4
    expected = [2, 3, 4, 5, 6] if all_buttons else [2, 2, 2]
    names = {2: "PLAY_PAUSE", 3: "NEXT", 4: "PREVIOUS",
             5: "VOLUME_UP", 6: "VOLUME_DOWN"}
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

    def gpio_read():
        write_register(7, 0xC018)
        return read_register(6) & 0xFF

    try:
        sleep_ms(20)
        print("BUTTON_PROBE_DREQ_RESET", dreq.value())
        reset.value(1)
        sleep_ms(100)
        print("BUTTON_PROBE_DREQ_RELEASED", dreq.value())
        statuses = [read_register(1) for _ in range(3)]
        print("BUTTON_PROBE_SCI_STATUS", [hex(value) for value in statuses])
        if any(((value >> 4) & 15) != 4 for value in statuses):
            raise RuntimeError("VS1053 identification failed")
        write_register(11, 0xFEFE)
        write_register(0, 0x4800)
        # GPIO_DDR=0 makes all eight pins inputs. The breakout has pulldowns.
        write_register(7, 0xC017)
        write_register(6, 0)
        write_register(7, 0xC017)
        if read_register(6) & 0xFF:
            raise RuntimeError("GPIO input-direction readback failed")
        initial = gpio_read()
        stable = candidate = initial & mask
        start = changed = ticks_ms()
        presses = releases = 0
        press_order = []
        simultaneous = False
        observed = initial
        print("BUTTON_READY", "PRESSED" if stable else "RELEASED", "gpio_bits", initial)
        while ticks_diff(ticks_ms(), start) < seconds * 1000:
            bits = gpio_read()
            observed |= bits
            value = bits & mask
            now = ticks_ms()
            if value != candidate:
                candidate = value
                changed = now
            elif candidate != stable and ticks_diff(now, changed) >= 30:
                changed_bits = stable ^ candidate
                stable = candidate
                simultaneous |= bool(stable and stable & (stable - 1))
                for gpio in range(2, 7):
                    bit = 1 << gpio
                    if changed_bits & bit:
                        pressed = bool(stable & bit)
                        if pressed:
                            presses += 1
                            press_order.append(gpio)
                        else:
                            releases += 1
                        print("BUTTON_EDGE", names[gpio], "GPIO", gpio,
                              "PRESSED" if pressed else "RELEASED",
                              "elapsed_ms", ticks_diff(now, start), "gpio_bits", bits)
                if presses >= len(expected) and releases >= len(expected) and not stable:
                    break
            sleep_ms(10)
        result = {"gpio": "2..6" if all_buttons else 2, "initial_gpio_bits": initial,
                  "observed_high_bits": observed, "presses": presses,
                  "releases": releases, "final_pressed": bool(stable),
                  "press_order": press_order, "expected_order": expected,
                  "simultaneous_inputs": simultaneous,
                  "passed": not bool(initial & mask) and press_order == expected
                            and releases == len(expected) and not stable and not simultaneous}
        print("BUTTON_PROBE_RESULT", result)
        return result
    finally:
        reset.value(0)
        cs.value(1)
        xdcs.value(1)
        sdcs.value(1)
        spi.deinit()
        print("BUTTON_PROBE_STOPPED")
