#pragma once
/* ST7365P init for the DLC-T2.7DDS#1 (320 x 320 IPS).
 * Source: hardware/mark-8/slab-rev-a/reference/DLC-T2.7DDS1-initial-code.txt,
 * in the vendor's order, with one change: COLMOD (0x3A) is 0x55 (16-bit
 * RGB565, SPEC 9) where the vendor writes 0x77 (24-bit). MADCTL (0x36) is a
 * config value; its default is the vendor's 0x48. No TE command (0x35): the
 * tear output stays off (touch rule 2). tests/verify.py compares this table
 * with the vendor file. */
#include <stdint.h>
#include "sdkconfig.h"

#ifndef CONFIG_SLAB_LCD_MADCTL
#define CONFIG_SLAB_LCD_MADCTL 0x48
#endif

typedef struct { uint8_t cmd, len; uint8_t data[14]; uint16_t delay_ms; } st7365p_cmd_t;

#define ST7365P_RESET_LOW_MS  10
#define ST7365P_RESET_WAIT_MS 120   /* vendor: HW_Reset(); Delay(120); */
#define ST7365P_COLMOD_VENDOR 0x77
#define ST7365P_COLMOD_RGB565 0x55

static const st7365p_cmd_t st7365p_init_cmds[] = {
    {0x11, 0, {0}, 120},                                     /* sleep out */
    {0x36, 1, {CONFIG_SLAB_LCD_MADCTL}, 0},                  /* memory access control */
    {0x3A, 1, {ST7365P_COLMOD_RGB565}, 0},                   /* pixel format (vendor 0x77) */
    {0xF0, 1, {0xC3}, 0},                                    /* command set control: enable part 1 */
    {0xF0, 1, {0x96}, 0},                                    /* enable part 2 */
    {0xB4, 1, {0x01}, 0},
    {0xB9, 2, {0x02, 0xE0}, 0},
    {0xB7, 1, {0xC6}, 0},
    {0xC0, 2, {0x80, 0x16}, 0},
    {0xC1, 1, {0x1D}, 0},
    {0xC2, 1, {0xA7}, 0},
    {0xC5, 1, {0x14}, 0},
    {0xE8, 8, {0x40, 0x8A, 0x00, 0x00, 0x29, 0x19, 0xA5, 0x33}, 0},
    {0xE0, 14, {0xF0, 0x09, 0x11, 0x06, 0x08, 0x15, 0x3C, 0x44, 0x50, 0x38, 0x12, 0x14, 0x2F, 0x34}, 0},
    {0xE1, 14, {0xF0, 0x15, 0x1A, 0x10, 0x0D, 0x08, 0x3B, 0x43, 0x4F, 0x36, 0x14, 0x12, 0x2D, 0x32}, 0},
    {0xF0, 1, {0x3C}, 0},                                    /* command set control: disable */
    {0xF0, 1, {0x69}, 120},
    {0x21, 0, {0}, 0},                                       /* display inversion on (IPS) */
    {0x29, 0, {0}, 0},                                       /* display on */
};
