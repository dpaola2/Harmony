#include "mpr121.h"
#include "slab_i2c.h"
#include "slab_pins.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "driver/gpio.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#define ADDR SLAB_I2C_ADDR_MPR121
static const char *TAG = "MPR121";

esp_err_t mpr121_start(const mpr121_settings_t *s)
{
    esp_err_t err = slab_i2c_write8(ADDR, MPR121_REG_SOFT_RESET, MPR121_SOFT_RESET_VALUE);
    vTaskDelay(pdMS_TO_TICKS(2));
    uint8_t v = 0;
    if (err == ESP_OK) err = slab_i2c_read(ADDR, MPR121_REG_AFE2, &v, 1);
    if (err != ESP_OK) return err;
    if (v != MPR121_AFE2_RESET_VALUE) {
        ESP_LOGE(TAG, "Reset check: 0x5D = 0x%02x, expected 0x%02x", v, MPR121_AFE2_RESET_VALUE);
        return ESP_ERR_INVALID_RESPONSE;
    }
    mpr121_reg_t table[48];
    size_t n = mpr121_config_table(s, table, 48);
    if (n > 48) return ESP_ERR_INVALID_SIZE;
    for (size_t i = 0; i < n && err == ESP_OK; ++i) err = slab_i2c_write8(ADDR, table[i].reg, table[i].value);
    for (size_t i = 0; i < n && err == ESP_OK; ++i) {
        err = slab_i2c_read(ADDR, table[i].reg, &v, 1);
        if (err == ESP_OK && v != table[i].value) {
            ESP_LOGE(TAG, "Readback 0x%02x = 0x%02x, wrote 0x%02x", table[i].reg, v, table[i].value);
            err = ESP_ERR_INVALID_RESPONSE;
        }
    }
    if (err == ESP_OK) err = slab_i2c_write8(ADDR, MPR121_REG_ECR, MPR121_ECR_RUN);
    if (err != ESP_OK) return err;
    /* Autoconfig runs on entry to run mode; give it a few scan periods. */
    vTaskDelay(pdMS_TO_TICKS(100));
    uint8_t oor[2];
    err = slab_i2c_read(ADDR, MPR121_REG_OOR_STATUS, oor, 2);
    if (err != ESP_OK) return err;
    uint16_t bits = (uint16_t)(oor[0] | oor[1] << 8);
    if (bits & 0x8000) { ESP_LOGE(TAG, "Autoconfig failed (ACFF), OOR 0x%04x", bits); return ESP_FAIL; }
    if (bits & 0x01FF) ESP_LOGW(TAG, "Electrodes out of range after autoconfig: 0x%03x", bits & 0x1FF);
    /* Keep the learned charge settings and baselines across later stop and resume. */
    err = slab_i2c_write8(ADDR, MPR121_REG_ECR, MPR121_ECR_STOP);
    if (err == ESP_OK) err = slab_i2c_write8(ADDR, MPR121_REG_ACCR0, MPR121_ACCR0_KEEP);
    if (err == ESP_OK) err = slab_i2c_write8(ADDR, MPR121_REG_ECR, MPR121_ECR_RESUME);
    return err;
}

esp_err_t mpr121_read_frame(mpr121_frame_t *out)
{
    uint8_t raw[MPR121_FRAME_BYTES];
    esp_err_t err = slab_i2c_read(ADDR, MPR121_REG_TOUCH_STATUS, raw, sizeof(raw));
    if (err == ESP_OK) mpr121_parse(raw, out);
    return err;
}

esp_err_t mpr121_stop(void) { return slab_i2c_write8(ADDR, MPR121_REG_ECR, MPR121_ECR_STOP); }
esp_err_t mpr121_resume(void) { return slab_i2c_write8(ADDR, MPR121_REG_ECR, MPR121_ECR_RESUME); }

esp_err_t mpr121_set_thresholds(const uint8_t touch[MPR121_ELECTRODES], const uint8_t release[MPR121_ELECTRODES])
{
    esp_err_t err = mpr121_stop();
    for (unsigned i = 0; i < MPR121_ELECTRODES && err == ESP_OK; ++i) {
        err = slab_i2c_write8(ADDR, MPR121_REG_TOUCH_TH0 + 2 * i, touch[i]);
        if (err == ESP_OK) err = slab_i2c_write8(ADDR, MPR121_REG_TOUCH_TH0 + 2 * i + 1, release[i]);
    }
    esp_err_t resume = mpr121_resume();
    return err == ESP_OK ? resume : err;
}

esp_err_t mpr121_sleep(bool run_slowly, unsigned esi_ms)
{
    esp_err_t err = mpr121_stop();
    if (err != ESP_OK || !run_slowly) return err;
    /* SFI 4 samples, slow ESI: about 3 + 26 x 16 / ESI uA from the datasheet's 29 uA at 16 ms. */
    err = slab_i2c_write8(ADDR, MPR121_REG_AFE2, mpr121_afe2_value(0, esi_ms));
    if (err == ESP_OK) err = slab_i2c_write8(ADDR, MPR121_REG_ACCR0, MPR121_ACCR0_KEEP);
    if (err == ESP_OK) err = mpr121_resume();
    /* Clear any pending status so TOUCH_IRQ is high when the ESP32 sleeps. */
    uint8_t status[2];
    if (err == ESP_OK) err = slab_i2c_read(ADDR, MPR121_REG_TOUCH_STATUS, status, 2);
    return err;
}

bool mpr121_wait_untouched(unsigned timeout_ms)
{
    int64_t end = esp_timer_get_time() + (int64_t)timeout_ms * 1000;
    for (;;) {
        uint8_t status[2];
        if (slab_i2c_read(ADDR, MPR121_REG_TOUCH_STATUS, status, 2) != ESP_OK) return false;
        if (!((status[0] | status[1] << 8) & 0x1FF)) return true;
        /* Reading the status released TOUCH_IRQ; the next status change pulls it low. */
        while (gpio_get_level(SLAB_PIN_TOUCH_IRQ) != 0) {
            if (esp_timer_get_time() > end) return false;
            vTaskDelay(pdMS_TO_TICKS(10));
        }
    }
}
