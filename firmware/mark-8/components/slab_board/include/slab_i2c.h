#pragma once
/* Shared I2C bus: MAX17048 0x36, DRV2605L 0x5A, MPR121 0x5B.
 * I2C_SDA and I2C_SCL run 0.1 mm behind the touch electrodes (hardware README
 * "Touch-wheel re-route"). In the player, only the wheel task touches this
 * bus, and only right after TOUCH_IRQ falls or with the MPR121 stopped. */
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include "esp_err.h"

esp_err_t slab_i2c_init(void);
void slab_i2c_deinit(void);
uint32_t slab_i2c_hz(void);
bool slab_i2c_probe(uint8_t addr);
esp_err_t slab_i2c_read(uint8_t addr, uint8_t reg, uint8_t *buf, size_t n);
esp_err_t slab_i2c_write(uint8_t addr, uint8_t reg, const uint8_t *buf, size_t n);
esp_err_t slab_i2c_write8(uint8_t addr, uint8_t reg, uint8_t value);
esp_err_t slab_i2c_read16be(uint8_t addr, uint8_t reg, uint16_t *value);
esp_err_t slab_i2c_write16be(uint8_t addr, uint8_t reg, uint16_t value);
