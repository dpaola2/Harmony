/* Diagnostic reader for the factory-assembled Adafruit #6310 (seesaw ID 5740).
 * Register protocol: pinned Adafruit_seesaw source in ../reference.
 * This stage logs inputs; it does not alter playback or implement navigation.
 */
#include <inttypes.h>
#include "carrier_controls.h"
#include "carrier_board.h"
#include "driver/i2c_master.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

static i2c_master_bus_handle_t bus;
static i2c_master_dev_handle_t device;
#define TRY(x) do { esp_err_t e = (x); if (e != ESP_OK) return e; } while (0)

static esp_err_t read_register(uint8_t base, uint8_t reg, uint32_t *value)
{
    if (!carrier_board_ready()) return ESP_ERR_INVALID_STATE;
    const uint8_t address[] = {base, reg};
    uint8_t data[4];
    /* Seesaw needs a STOP and processing delay before the separate read. */
    TRY(i2c_master_transmit(device, address, sizeof(address), 100));
    vTaskDelay(pdMS_TO_TICKS(2));
    TRY(i2c_master_receive(device, data, sizeof(data), 100));
    *value = ((uint32_t)data[0] << 24) | ((uint32_t)data[1] << 16) |
             ((uint32_t)data[2] << 8) | data[3];
    return ESP_OK;
}

static void controls_task(void *unused)
{
    const char *names[] = {"SELECT", "UP", "LEFT", "DOWN", "RIGHT"};
    uint32_t previous_position = 0, previous_buttons = 0x3e;
    bool first = true;
    while (carrier_board_ready()) {
        uint32_t position, buttons;
        esp_err_t err = read_register(0x11, 0x30, &position);
        if (err == ESP_OK) err = read_register(0x01, 0x04, &buttons);
        if (err != ESP_OK) {
            ESP_LOGE("ANO", "Input diagnostic stopped: %s", esp_err_to_name(err));
            break;
        }
        if (first || position != previous_position)
            ESP_LOGI("ANO", "RAW_POSITION=%" PRId32, (int32_t)position);
        for (unsigned i = 0; i < 5; ++i) {
            uint32_t mask = 1U << (i + 1);
            if ((buttons ^ previous_buttons) & mask)
                ESP_LOGI("ANO", "%s %s", names[i], buttons & mask ? "released" : "pressed");
        }
        first = false;
        previous_position = position;
        previous_buttons = buttons;
        vTaskDelay(pdMS_TO_TICKS(20));
    }
    i2c_master_bus_rm_device(device);
    i2c_del_master_bus(bus);
    vTaskDelete(NULL);
}

esp_err_t carrier_controls_start(void)
{
    if (!carrier_board_ready()) return ESP_ERR_INVALID_STATE;
    i2c_master_bus_config_t cfg = {.i2c_port = I2C_NUM_0,
        .sda_io_num = CARRIER_I2C_SDA, .scl_io_num = CARRIER_I2C_SCL,
        .clk_source = I2C_CLK_SRC_DEFAULT, .glitch_ignore_cnt = 7,
        .flags.enable_internal_pullup = false};
    TRY(i2c_new_master_bus(&cfg, &bus));
    i2c_device_config_t dev = {.dev_addr_length = I2C_ADDR_BIT_LEN_7,
        .device_address = 0x49, .scl_speed_hz = 100000};
    esp_err_t err = i2c_master_bus_add_device(bus, &dev, &device);
    if (err != ESP_OK) { i2c_del_master_bus(bus); return err; }
    uint32_t version = 0;
    err = read_register(0x00, 0x02, &version);
    if (err == ESP_OK && (version >> 16) != 5740) err = ESP_ERR_INVALID_VERSION;
    /* Input mode, pull enabled, then pull-up for seesaw pins 1..5. */
    const uint8_t registers[] = {0x03, 0x0b, 0x05};
    for (unsigned i = 0; i < sizeof(registers) && err == ESP_OK; ++i) {
        const uint8_t cmd[] = {0x01, registers[i], 0, 0, 0, 0x3e};
        err = i2c_master_transmit(device, cmd, sizeof(cmd), 100);
        vTaskDelay(pdMS_TO_TICKS(2));
    }
    if (err == ESP_OK && xTaskCreatePinnedToCore(controls_task, "ano_diag", 3072,
                                               NULL, 1, NULL, 0) != pdPASS)
        err = ESP_ERR_NO_MEM;
    if (err != ESP_OK) { i2c_master_bus_rm_device(device); i2c_del_master_bus(bus); }
    return err;
}
