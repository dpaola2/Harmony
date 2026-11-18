/* DRV2605L setup follows the Adafruit DRV2605 library defaults (BSD licence):
 * internal trigger, ERM, open loop, effect library 1. */
#include "drv2605.h"
#include "slab_i2c.h"
#include "slab_pins.h"

#define ADDR SLAB_I2C_ADDR_DRV2605L

bool drv2605_detect(unsigned *id)
{
    uint8_t status = 0;
    if (slab_i2c_read(ADDR, DRV2605_REG_STATUS, &status, 1) != ESP_OK) return false;
    if (id) *id = drv2605_device_id(status);
    return drv2605_device_id(status) == DRV2605L_DEVICE_ID;
}

static esp_err_t update(uint8_t reg, uint8_t clear, uint8_t set)
{
    uint8_t v = 0;
    esp_err_t err = slab_i2c_read(ADDR, reg, &v, 1);
    if (err == ESP_OK) err = slab_i2c_write8(ADDR, reg, (uint8_t)((v & ~clear) | set));
    return err;
}

esp_err_t drv2605_setup_erm(void)
{
    esp_err_t err = slab_i2c_write8(ADDR, DRV2605_REG_MODE, 0x00);          /* out of standby, internal trigger */
    if (err == ESP_OK) err = slab_i2c_write8(ADDR, DRV2605_REG_LIBRARY, 1);  /* ERM library A */
    if (err == ESP_OK) err = update(DRV2605_REG_FEEDBACK, 0x80, 0x00);       /* N_ERM_LRA = 0: ERM */
    if (err == ESP_OK) err = update(DRV2605_REG_CONTROL3, 0x00, 0x20);       /* ERM open loop */
    if (err == ESP_OK) err = drv2605_standby();
    return err;
}

esp_err_t drv2605_play(uint8_t effect)
{
    esp_err_t err = slab_i2c_write8(ADDR, DRV2605_REG_MODE, 0x00);
    if (err == ESP_OK) err = slab_i2c_write8(ADDR, DRV2605_REG_WAVESEQ1, effect);
    if (err == ESP_OK) err = slab_i2c_write8(ADDR, DRV2605_REG_WAVESEQ2, 0);
    if (err == ESP_OK) err = slab_i2c_write8(ADDR, DRV2605_REG_GO, 1);
    return err;
}

esp_err_t drv2605_standby(void) { return slab_i2c_write8(ADDR, DRV2605_REG_MODE, 0x40); }
