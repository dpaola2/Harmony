#include <string.h>
#include "driver/gpio.h"
#include "driver/uart.h"
#include "esp_mac.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

static const int pins[] = {32, 26, 33, 14, 13};

static void set_phase(char phase)
{
    /* Keep levels static until another explicit UART command or reset. */
    const char *keys = "rcdkm";
    for (unsigned i = 0; i < sizeof(pins) / sizeof(pins[0]); i++) {
        int level = phase == 'l' ? 0 : (phase == keys[i] ? 0 : 1);
        gpio_set_level(pins[i], level);
    }
    vTaskDelay(pdMS_TO_TICKS(20));
    bool mismatch = false;
    for (unsigned i = 0; i < sizeof(pins) / sizeof(pins[0]); i++) {
        int expected = phase == 'l' ? 0 : (phase == keys[i] ? 0 : 1);
        if (gpio_get_level(pins[i]) != expected) mismatch = true;
    }
    ESP_LOGI("SIGNAL_CHECK", "phase=%c PAD_READBACK RST32=%d CS26=%d DC33=%d SCK14=%d MOSI13=%d",
             phase, gpio_get_level(32), gpio_get_level(26), gpio_get_level(33),
             gpio_get_level(14), gpio_get_level(13));
    if (mismatch) {
        for (unsigned i = 0; i < sizeof(pins) / sizeof(pins[0]); i++)
            gpio_set_direction(pins[i], GPIO_MODE_INPUT);
        ESP_LOGE("SIGNAL_CHECK", "OUTPUT_MISMATCH: released all pins to inputs; stop and inspect wiring");
    }
}

void signal_check(void)
{
    uint8_t mac[6];
    const uint8_t expected[] = {0x5c, 0x01, 0x3b, 0x89, 0x24, 0x04};
    ESP_ERROR_CHECK(esp_read_mac(mac, ESP_MAC_WIFI_STA));
    if (memcmp(mac, expected, sizeof(mac))) {
        ESP_LOGE("SIGNAL_CHECK", "Wrong board; no GPIO changes made");
        return;
    }
    uint64_t mask = 0;
    for (unsigned i = 0; i < sizeof(pins) / sizeof(pins[0]); i++) mask |= 1ULL << pins[i];
    gpio_config_t cfg = {.pin_bit_mask = mask, .mode = GPIO_MODE_INPUT_OUTPUT};
    ESP_ERROR_CHECK(gpio_config(&cfg));
    ESP_ERROR_CHECK(uart_driver_install(UART_NUM_0, 256, 0, 0, NULL, 0));
    ESP_LOGI("SIGNAL_CHECK", "Static diagnostic, no display writes, SD or Bluetooth. Boot holds RST LOW.");
    ESP_LOGI("SIGNAL_CHECK", "Commands: r/c/d/k/m hold named pin low, others high; h all high; l all low.");
    set_phase('r');
    for (;;) {
        uint8_t ch;
        if (uart_read_bytes(UART_NUM_0, &ch, 1, pdMS_TO_TICKS(1000)) == 1 &&
            ch != 0 && strchr("rcdkmhl", ch)) set_phase(ch);
    }
}
