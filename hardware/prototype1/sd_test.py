"""Simple SD card smoke test for ESP32-S3 (Prototype 1).

Wire your SPI SD breakout to free GPIOs (set pins below), list `/sd`, unmount.
Copy to the board and run with:
    mpremote connect /dev/tty.usbmodem* run sd_test.py
"""

import os
import sys
import time

import machine


def main() -> int:
    # SoftSPI SD test on dedicated pins (display disconnected). If your board
    # lacks these pins, adjust sck/mosi/miso below to any free GPIOs.
    # Update these pins to match your wiring.
    spi = machine.SoftSPI(
        baudrate=1_000_000,
        polarity=0,
        phase=0,
        sck=machine.Pin(4),
        mosi=machine.Pin(5),
        miso=machine.Pin(6),
    )
    cs = machine.Pin(10, machine.Pin.OUT)

    try:
        import sdcard  # type: ignore
    except ImportError:
        print("sdcard.py missing on board; copy hardware/prototype1/sdcard.py")
        return 1

    try:
        sd = sdcard.SDCard(spi, cs)
    except Exception as exc:  # noqa: BLE001
        print("SDCard init failed; check wiring/pins")
        sys.print_exception(exc)
        return 1

    try:
        vfs_mount = "/sd"
        os.mount(sd, vfs_mount)
        print("Mounted", vfs_mount)
        print("Root entries:", os.listdir(vfs_mount))
    except Exception as exc:  # noqa: BLE001
        sys.print_exception(exc)
        return 1
    finally:
        try:
            os.umount(vfs_mount)
            print("Unmounted", vfs_mount)
        except Exception:
            pass
        try:
            spi.deinit()
        except Exception:
            pass
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
