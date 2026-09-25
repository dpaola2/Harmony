/* HX8357D initd table from Adafruit_HX8357_Library, commit
 * bca58c0024f64e48e7c6a623e3cd8147ec19e10e.
 * Copyright Adafruit Industries. See ../../reference/Adafruit_HX8357.cpp
 * for the original BSD attribution and source. Delay encoding is 5 ms units.
 */
#pragma once
#include <stdint.h>
static const uint8_t hx8357_init[] = {
        0x01,
        0x80 + 100 / 5, // Soft reset, then delay 10 ms
        0xB9,
        3,
        0xFF,
        0x83,
        0x57,
        0xFF,
        0x80 + 500 / 5, // No command, just delay 300 ms
        0xB3,
        4,
        0x80,
        0x00,
        0x06,
        0x06, // 0x80 enables SDO pin (0x00 disables)
        0xB6,
        1,
        0x25, // -1.52V
        0xB0,
        1,
        0x68, // Normal mode 70Hz, Idle mode 55 Hz
        0xCC,
        1,
        0x05, // BGR, Gate direction swapped
        0xB1,
        6,
        0x00, // Not deep standby
        0x15, // BT
        0x1C, // VSPR
        0x1C, // VSNR
        0x83, // AP
        0xAA, // FS
        0xC0,
        6,
        0x50, // OPON normal
        0x50, // OPON idle
        0x01, // STBA
        0x3C, // STBA
        0x1E, // STBA
        0x08, // GEN
        0xB4,
        7,
        0x02, // NW 0x02
        0x40, // RTN
        0x00, // DIV
        0x2A, // DUM
        0x2A, // DUM
        0x0D, // GDON
        0x78, // GDOFF
        0xE0,
        34,
        0x02,
        0x0A,
        0x11,
        0x1d,
        0x23,
        0x35,
        0x41,
        0x4b,
        0x4b,
        0x42,
        0x3A,
        0x27,
        0x1B,
        0x08,
        0x09,
        0x03,
        0x02,
        0x0A,
        0x11,
        0x1d,
        0x23,
        0x35,
        0x41,
        0x4b,
        0x4b,
        0x42,
        0x3A,
        0x27,
        0x1B,
        0x08,
        0x09,
        0x03,
        0x00,
        0x01,
        0x3A,
        1,
        0x55, // 16 bit
        0x36,
        1,
        0xC0,
        0x35,
        1,
        0x00, // TW off
        0x44,
        2,
        0x00,
        0x02,
        0x11,
        0x80 + 150 / 5, // Exit Sleep, then delay 150 ms
        0x29,
        0x80 + 50 / 5, // Main screen turn on, delay 50 ms
        0,             // END OF COMMAND LIST
};
