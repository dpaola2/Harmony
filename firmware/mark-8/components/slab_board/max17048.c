#include "max17048.h"
#include "slab_i2c.h"
#include "slab_pins.h"

esp_err_t max17048_read(max17048_reading_t *out)
{
    uint8_t vcell[2], soc[2], crate[2];
    uint16_t version = 0;
    esp_err_t err = slab_i2c_read16be(SLAB_I2C_ADDR_MAX17048, MAX17048_REG_VERSION, &version);
    if (err == ESP_OK) err = slab_i2c_read(SLAB_I2C_ADDR_MAX17048, MAX17048_REG_VCELL, vcell, 2);
    if (err == ESP_OK) err = slab_i2c_read(SLAB_I2C_ADDR_MAX17048, MAX17048_REG_SOC, soc, 2);
    if (err == ESP_OK) err = slab_i2c_read(SLAB_I2C_ADDR_MAX17048, MAX17048_REG_CRATE, crate, 2);
    if (err != ESP_OK) return err;
    max17048_parse(vcell, soc, crate, version, out);
    return max17048_version_ok(version) ? ESP_OK : ESP_ERR_INVALID_VERSION;
}

esp_err_t max17048_hibernate(bool force)
{
    return slab_i2c_write16be(SLAB_I2C_ADDR_MAX17048, MAX17048_REG_HIBRT,
                              force ? MAX17048_HIBRT_ALWAYS : MAX17048_HIBRT_DEFAULT);
}
