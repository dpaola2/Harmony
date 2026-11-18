#include <string.h>
#include "sdkconfig.h"
#include "slab_i2c.h"
#include "slab_pins.h"
#include "driver/i2c_master.h"
#include "freertos/FreeRTOS.h"
#include "freertos/semphr.h"

#ifndef CONFIG_SLAB_I2C_HZ
#define CONFIG_SLAB_I2C_HZ 100000
#endif
#define TIMEOUT_MS 50
#define DEVICES 4

static i2c_master_bus_handle_t bus;
static struct { uint8_t addr; i2c_master_dev_handle_t dev; } devices[DEVICES];
static SemaphoreHandle_t lock;

uint32_t slab_i2c_hz(void) { return CONFIG_SLAB_I2C_HZ; }

esp_err_t slab_i2c_init(void)
{
    if (bus) return ESP_OK;
    if (!lock) lock = xSemaphoreCreateMutex();
    if (!lock) return ESP_ERR_NO_MEM;
    i2c_master_bus_config_t cfg = {.i2c_port = I2C_NUM_0, .sda_io_num = SLAB_PIN_I2C_SDA,
        .scl_io_num = SLAB_PIN_I2C_SCL, .clk_source = I2C_CLK_SRC_DEFAULT,
        .glitch_ignore_cnt = 7, .flags.enable_internal_pullup = false};
    return i2c_new_master_bus(&cfg, &bus);
}

void slab_i2c_deinit(void)
{
    if (!bus) return;
    for (unsigned i = 0; i < DEVICES; ++i)
        if (devices[i].dev) { i2c_master_bus_rm_device(devices[i].dev); devices[i].dev = NULL; devices[i].addr = 0; }
    i2c_del_master_bus(bus);
    bus = NULL;
}

static i2c_master_dev_handle_t device(uint8_t addr)
{
    for (unsigned i = 0; i < DEVICES; ++i) if (devices[i].dev && devices[i].addr == addr) return devices[i].dev;
    for (unsigned i = 0; i < DEVICES; ++i) {
        if (devices[i].dev) continue;
        i2c_device_config_t cfg = {.dev_addr_length = I2C_ADDR_BIT_LEN_7, .device_address = addr,
            .scl_speed_hz = CONFIG_SLAB_I2C_HZ};
        if (i2c_master_bus_add_device(bus, &cfg, &devices[i].dev) != ESP_OK) return NULL;
        devices[i].addr = addr;
        return devices[i].dev;
    }
    return NULL;
}

bool slab_i2c_probe(uint8_t addr)
{
    if (!bus) return false;
    xSemaphoreTake(lock, portMAX_DELAY);
    bool found = i2c_master_probe(bus, addr, TIMEOUT_MS) == ESP_OK;
    xSemaphoreGive(lock);
    return found;
}

esp_err_t slab_i2c_read(uint8_t addr, uint8_t reg, uint8_t *buf, size_t n)
{
    if (!bus) return ESP_ERR_INVALID_STATE;
    xSemaphoreTake(lock, portMAX_DELAY);
    i2c_master_dev_handle_t dev = device(addr);
    esp_err_t err = dev ? i2c_master_transmit_receive(dev, &reg, 1, buf, n, TIMEOUT_MS) : ESP_ERR_NO_MEM;
    xSemaphoreGive(lock);
    return err;
}

esp_err_t slab_i2c_write(uint8_t addr, uint8_t reg, const uint8_t *buf, size_t n)
{
    if (!bus) return ESP_ERR_INVALID_STATE;
    if (n > 15) return ESP_ERR_INVALID_SIZE;
    uint8_t out[16];
    out[0] = reg;
    memcpy(out + 1, buf, n);
    xSemaphoreTake(lock, portMAX_DELAY);
    i2c_master_dev_handle_t dev = device(addr);
    esp_err_t err = dev ? i2c_master_transmit(dev, out, n + 1, TIMEOUT_MS) : ESP_ERR_NO_MEM;
    xSemaphoreGive(lock);
    return err;
}

esp_err_t slab_i2c_write8(uint8_t addr, uint8_t reg, uint8_t value) { return slab_i2c_write(addr, reg, &value, 1); }

esp_err_t slab_i2c_read16be(uint8_t addr, uint8_t reg, uint16_t *value)
{
    uint8_t b[2];
    esp_err_t err = slab_i2c_read(addr, reg, b, 2);
    if (err == ESP_OK) *value = (uint16_t)(b[0] << 8 | b[1]);
    return err;
}

esp_err_t slab_i2c_write16be(uint8_t addr, uint8_t reg, uint16_t value)
{
    uint8_t b[2] = {(uint8_t)(value >> 8), (uint8_t)value};
    return slab_i2c_write(addr, reg, b, 2);
}
