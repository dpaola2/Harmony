#include "bench_display.h"
#include "carrier_board.h"
#include "driver/gpio.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

void app_main(void)
{
    ESP_LOGI("LCD_BENCH", "Standalone LCD on Feather 3V; no carrier, SD, touch, controls or radios");
    esp_err_t err = carrier_board_init();
    if (err != ESP_OK) {
        ESP_LOGE("LCD_BENCH", "Identity/capacity check failed: %s; outputs remain disabled", esp_err_to_name(err));
        return;
    }
    err = bench_display_init();
    if (err == ESP_OK) err = bench_display_probe();
    if (err != ESP_OK) {
        gpio_set_level(CARRIER_TFT_LITE, 0);
        ESP_LOGE("LCD_BENCH", "Display write failed: %s", esp_err_to_name(err));
        return;
    }
    ESP_LOGI("LCD_BENCH", "DISPLAY_WRITE_COMPLETE; confirm text, white border and red/green/blue blocks visually");
    // Static image, with a serial heartbeat to expose resets during the check.
    for (unsigned seconds = 10; ; seconds += 10) {
        vTaskDelay(pdMS_TO_TICKS(10000));
        ESP_LOGI("LCD_BENCH", "Display test running: %u seconds after drawing", seconds);
    }
}
