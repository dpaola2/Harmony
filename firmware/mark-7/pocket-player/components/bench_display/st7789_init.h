#pragma once
#include <stdint.h>
/* Adafruit #4311 full 240x320 panel, rotation 1 (MY|MV, RGB), no offsets.
 * Command basis: Adafruit_ST7789.cpp generic init and setRotation(1).
 * Use conservative delays. No ST7796-specific power/gamma commands.
 */
static const struct { uint8_t cmd, count, data[4]; unsigned delay_ms; } st7789_init[] = {
    {0x01,0,{0},150}, {0x11,0,{0},120}, {0x3a,1,{0x55},10},
    {0x36,1,{0xa0},0}, {0x21,0,{0},10}, {0x13,0,{0},10}, {0x29,0,{0},120}
};
