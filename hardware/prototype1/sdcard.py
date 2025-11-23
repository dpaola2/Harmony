"""Minimal SPI SD card driver for MicroPython.

Drop alongside tests if your firmware does not include `sdcard`.
Based on the reference driver from micropython-lib.
"""

import time


class SDCard:
    def __init__(self, spi, cs, baudrate=5_000_000):
        self.spi = spi
        self.cs = cs
        self.cmdbuf = bytearray(6)
        self.dummybuf = bytearray(512)
        self.token = bytearray(1)
        self.sectors = None
        self.init_spi(baudrate)

        # Basic init sequence
        self._init_spi_mode()
        if not self._init_card():
            raise OSError("no sd card")

    def init_spi(self, baudrate):
        try:
            self.spi.init(baudrate=baudrate, polarity=0, phase=0)
        except AttributeError:
            pass
        self.cs.init(self.cs.OUT, value=1)

    def _init_spi_mode(self):
        # Send 80 clocks with CS high
        self.cs(1)
        for _ in range(10):
            self.spi.write(b"\xFF")

    def _cmd(self, cmd, arg, crc=0x95, read_len=0):
        buf = self.cmdbuf
        buf[0] = 0x40 | cmd
        buf[1] = (arg >> 24) & 0xFF
        buf[2] = (arg >> 16) & 0xFF
        buf[3] = (arg >> 8) & 0xFF
        buf[4] = arg & 0xFF
        buf[5] = crc

        self.cs(0)
        self.spi.write(buf)
        resp = 0xFF
        for _ in range(100):
            resp = self.spi.read(1)[0]
            if not (resp & 0x80):
                break
        data = b""
        if read_len:
            data = self.spi.read(read_len)
        self.cs(1)
        self.spi.write(b"\xFF")
        return resp, data

    def _cmd_nodata(self, cmd):
        self.cs(1)
        self.spi.write(b"\xFF")
        resp, _ = self._cmd(cmd, 0)
        self.cs(1)
        self.spi.write(b"\xFF")
        return resp

    def _init_card(self):
        r, _ = self._cmd(0, 0)
        if r != 1:
            return False

        r, r7 = self._cmd(8, 0x1AA, crc=0x87, read_len=4)
        if r not in (1, 5):
            return False
        for i in range(200):  # ~10s max with 50 ms sleeps
            r, _ = self._cmd(55, 0)
            r, _ = self._cmd(41, 0x40000000)
            if r == 0:
                break
            if i % 50 == 0:
                print("ACMD41 waiting...", i)
            time.sleep_ms(50)
        if r != 0:
            return False
        self._cmd(16, 512)
        return True

    def readblocks(self, block_num, buf):
        if block_num == 0:
            raise OSError("refusing to read block 0")
        if not self._init_card():
            raise OSError("no sd card")
        nblocks = len(buf) // 512
        for i in range(nblocks):
            self._read_block(block_num + i, memoryview(buf)[i * 512 : (i + 1) * 512])

    def writeblocks(self, block_num, buf):
        if block_num == 0:
            raise OSError("refusing to write block 0")
        if not self._init_card():
            raise OSError("no sd card")
        nblocks = len(buf) // 512
        for i in range(nblocks):
            self._write_block(block_num + i, memoryview(buf)[i * 512 : (i + 1) * 512])

    def _read_block(self, block_num, buf):
        self.cs(0)
        resp, _ = self._cmd(17, block_num)
        if resp != 0:
            self.cs(1)
            raise OSError("read error")
        while True:
            tok = self.spi.read(1)[0]
            if tok == 0xFE:
                break
        self.spi.readinto(buf)
        self.spi.read(2)
        self.cs(1)
        self.spi.write(b"\xFF")

    def _write_block(self, block_num, buf):
        self.cs(0)
        resp, _ = self._cmd(24, block_num)
        if resp != 0:
            self.cs(1)
            raise OSError("write error")
        self.spi.write(b"\xFE")
        self.spi.write(buf)
        self.spi.write(b"\xFF\xFF")
        resp = self.spi.read(1)[0]
        if (resp & 0x1F) != 0x05:
            self.cs(1)
            raise OSError("reject")
        while self.spi.read(1)[0] == 0:
            pass
        self.cs(1)
        self.spi.write(b"\xFF")

    def ioctl(self, op, arg):
        if op == 4:  # get number of blocks
            if self.sectors is None:
                self.sectors = 1024 * 1024  # dummy fallback
            return self.sectors
        return 0
