#include <inttypes.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include "esp_flash.h"
#include "esp_heap_caps.h"
#include "esp_log.h"
#include "esp_mac.h"
#include "esp_psram.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

static const char *TAG = "memory_diag";
static const uint8_t expected_mac[6] = {0x14, 0x33, 0x5c, 0x99, 0x1a, 0x28};

static uint32_t pattern(size_t i, unsigned pass)
{
    switch (pass) {
    case 0: return 0;
    case 1: return UINT32_MAX;
    case 2: return 0xaaaaaaaa;
    case 3: return 0x55555555;
    case 4: return (uint32_t)i * 0x9e3779b1u ^ 0xa5a5a5a5u;
    default: return ~((uint32_t)i * 0x9e3779b1u ^ 0xa5a5a5a5u);
    }
}

static bool test_block(const char *name, size_t bytes, uint32_t caps)
{
    volatile uint32_t *data = heap_caps_malloc(bytes, caps);
    if (!data) {
        ESP_LOGE(TAG, "FAIL %s allocation: %u bytes", name, (unsigned)bytes);
        return false;
    }
    size_t words = bytes / sizeof(uint32_t);
    ESP_LOGI(TAG, "TEST %s: %u bytes, 6 patterns x 3 rounds", name, (unsigned)bytes);
    for (unsigned round = 0; round < 3; round++) {
        for (unsigned pass = 0; pass < 6; pass++) {
            for (size_t i = 0; i < words; i++) data[i] = pattern(i, pass);
            vTaskDelay(1);
            for (size_t i = 0; i < words; i++) {
                uint32_t got = data[i], want = pattern(i, pass);
                if (got != want) {
                    ESP_LOGE(TAG, "FAIL %s round=%u pass=%u word=%u expected=%08" PRIx32 " actual=%08" PRIx32,
                             name, round, pass, (unsigned)i, want, got);
                    heap_caps_free((void *)data);
                    return false;
                }
            }
            vTaskDelay(1);
        }
        ESP_LOGI(TAG, "PASS %s round %u/3", name, round + 1);
    }
    heap_caps_free((void *)data);
    return true;
}

void app_main(void)
{
    uint8_t mac[6];
    uint32_t flash_size = 0;
    ESP_LOGI(TAG, "Standalone diagnostic; no carrier GPIO, radios, SD or display initialized");
    if (esp_read_mac(mac, ESP_MAC_WIFI_STA) != ESP_OK || memcmp(mac, expected_mac, sizeof mac)) {
        ESP_LOGE(TAG, "FAIL identity mismatch; stopping");
        return;
    }
    ESP_LOGI(TAG, "Identity matched 14:33:5c:99:1a:28");
    if (esp_flash_get_size(NULL, &flash_size) != ESP_OK || flash_size != 8 * 1024 * 1024) {
        ESP_LOGE(TAG, "FAIL flash capacity: %u", (unsigned)flash_size);
        return;
    }
    size_t psram_size = esp_psram_get_size();
    ESP_LOGI(TAG, "Flash=%u bytes; PSRAM=%u bytes", (unsigned)flash_size, (unsigned)psram_size);
    if (!esp_psram_is_initialized() || psram_size != 2 * 1024 * 1024) {
        ESP_LOGE(TAG, "FAIL expected 2 MiB initialized PSRAM");
        return;
    }
    uint32_t external_caps = MALLOC_CAP_SPIRAM | MALLOC_CAP_8BIT;
    size_t largest = heap_caps_get_largest_free_block(external_caps);
    if (largest < 1024 * 1024 + 4096) {
        ESP_LOGE(TAG, "FAIL insufficient PSRAM test coverage: %u", (unsigned)largest);
        return;
    }
    size_t test_bytes = (largest - 4096) & ~(size_t)3;
    bool external_ok = test_block("PSRAM", test_bytes, external_caps);
    bool internal_ok = test_block("internal RAM", 64 * 1024, MALLOC_CAP_INTERNAL | MALLOC_CAP_8BIT);
    bool heap_ok = heap_caps_check_integrity_all(true);
    if (!external_ok || !internal_ok || !heap_ok) {
        ESP_LOGE(TAG, "DIAGNOSTIC FAIL external=%d internal=%d heap=%d", external_ok, internal_ok, heap_ok);
        return;
    }
    ESP_LOGI(TAG, "DIAGNOSTIC PASS: identity, capacities, PSRAM patterns, internal RAM patterns, heap integrity");
    ESP_LOGI(TAG, "Flash capacity/readback only; no destructive whole-flash test. Carrier and radio operation untested.");
}
