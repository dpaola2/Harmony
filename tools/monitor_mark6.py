#!/usr/bin/env python3
"""Record the Mark-6 UART without toggling reset lines or changing GPIOs."""
import argparse
from datetime import datetime
from pathlib import Path
import time
import serial

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--port', required=True)
parser.add_argument('--seconds', type=int, default=100)
parser.add_argument('--log', type=Path)
args = parser.parse_args()
log_path = args.log or Path.home() / 'Downloads/harmony-mark6-backups' / (
    'tone-%s.log' % datetime.now().strftime('%Y%m%d-%H%M%S'))
port = serial.Serial()
port.port, port.baudrate, port.timeout = args.port, 115200, .2
port.dtr = port.rts = False
with log_path.open('xb') as log:
    try:
        port.open()
        deadline = time.monotonic() + args.seconds
        while time.monotonic() < deadline:
            data = port.read(max(1, port.in_waiting))
            if data:
                log.write(data)
                log.flush()
                print(data.decode(errors='replace'), end='', flush=True)
    finally:
        port.close()
        print('\nLOG', log_path)
