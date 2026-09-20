#!/usr/bin/env python3
"""Load the Mark-5 player into RAM over USB. No flash or card writes.

Use --transition-test for the three short, muted test tracks. Normal runs start
silent until PLAY, stop after the album or time limit, and log to the Mac.
Requires pyserial and the pinned sources in platforms/esp32/mark5_vendor.
"""

import argparse
import ast
from datetime import datetime
from pathlib import Path
import time

import serial
from serial.tools import list_ports


ROOT = Path(__file__).resolve().parents[1]
VENDOR = ROOT / "platforms/esp32/mark5_vendor"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", default="/sd/HARMONY/HUMANCLAY/album.json")
    parser.add_argument("--seconds", type=int, default=4500)
    parser.add_argument("--transition-test", action="store_true")
    parser.add_argument("--log", type=Path)
    args = parser.parse_args()
    if not 15 <= args.seconds <= 7200:
        parser.error("--seconds must be 15..7200")
    if args.transition_test:
        args.manifest = "/sd/HARMONY/TESTALBM/album.json"
        args.seconds = 30
    log_path = args.log or Path.home() / "Downloads/harmony-mark5-backups" / (
        "album-%s.log" % datetime.now().strftime("%Y%m%d-%H%M%S"))
    log_path.parent.mkdir(parents=True, exist_ok=True)
    ports = [p.device for p in list_ports.comports() if p.vid == 0x1A86 and p.pid == 0x7523]
    if len(ports) != 1:
        raise RuntimeError("Expected one WROVER USB port, found: " + repr(ports))
    port = serial.Serial()
    port.port, port.baudrate, port.timeout = ports[0], 115200, .2
    port.dtr = port.rts = False
    identity_verified = False
    with log_path.open("xb") as log:
        def until(marker, timeout=8):
            data = bytearray()
            deadline = time.monotonic() + timeout
            while time.monotonic() < deadline:
                chunk = port.read(max(1, port.in_waiting))
                if chunk:
                    data.extend(chunk)
                    log.write(chunk)
                    log.flush()
                    print(chunk.decode(errors="replace"), end="", flush=True)
                if data.endswith(marker):
                    return bytes(data)
            raise TimeoutError("Device response timeout")

        def run(code, timeout=20):
            for offset in range(0, len(code), 96):
                port.write(code[offset:offset + 96])
                time.sleep(.015)
            port.write(b"\x04")
            response = until(b"\x04>", timeout)
            if not response.startswith(b"OK"):
                raise RuntimeError("Unexpected raw REPL response")
            output, error = response[2:].split(b"\x04", 2)[:2]
            if error.strip():
                raise RuntimeError(error.decode(errors="replace"))
            return output

        try:
            port.open()
            time.sleep(3)
            port.read(port.in_waiting)
            port.write(b"\x03\x03")
            time.sleep(.5)
            port.read(port.in_waiting)
            port.write(b"\x01")
            if b"raw REPL" not in until(b">"):
                raise RuntimeError("Raw REPL unavailable")
            identity = run(b"import machine\nprint(machine.unique_id().hex())\n")
            if b"5c013b538f70" not in identity:
                raise RuntimeError("Unexpected device identity; no GPIO changes made")
            identity_verified = True
            run(b"import gc\ngc.collect()\n")
            run((VENDOR / "sdcard.py").read_bytes())
            for name, filename in (("mark5_st7789", "st7789py.py"), ("mark5_font", "vga1_8x16.py")):
                source = "import micropython\nfrom micropython import const\n" + (VENDOR / filename).read_text()
                code = ("_bench_globals = {'__name__': " + repr(name) + "}\nexec(" + repr(source)
                        + ", _bench_globals)\n" + name + " = type(" + repr(name)
                        + ", (), _bench_globals)\n")
                run(code.encode())
            for filename in ("models.py", "transport.py", "album.py"):
                run((ROOT / "core" / filename).read_bytes())
            invocation = ("\nrun_player(SDCard, mark5_st7789, mark5_font, Transport, Track, "
                "seconds=%d, manifest_path=%r, album_loader=tracks_from_manifest, "
                "stop_on_album_end=True, volume=%d, autoplay=%r)\n"
                % (args.seconds, args.manifest, 0 if args.transition_test else 58, args.transition_test))
            output = run((ROOT / "platforms/esp32/mark5_player.py").read_bytes()
                         + invocation.encode(), timeout=args.seconds + 90)
            text = output.decode()
            result_line = next(line for line in text.splitlines() if line.startswith("PLAYER_SESSION_COMPLETED "))
            result = ast.literal_eval(result_line.split(" ", 1)[1])
            if "PLAYER_STOPPED" not in text:
                raise RuntimeError("Device cleanup not confirmed")
            if args.transition_test:
                if (result["completed_tracks"] != ["01-01.MP3", "01-02.MP3", "01-03.MP3"]
                        or result["final_status"] != "Ended" or result["events"]
                        or any(t["decode_seconds"] < 1 for t in result["completed_details"])):
                    raise RuntimeError("Automatic album transition check failed")
                print("TRANSITION_TEST_PASSED")
            port.write(b"\x02")
            until(b">>> ")
        except BaseException:
            if port.is_open and identity_verified:
                # Interrupt the device so run_player's finally block cleans up.
                port.write(b"\x03\x03")
            raise
        finally:
            port.close()
            print("LOG", log_path)


if __name__ == "__main__":
    main()
