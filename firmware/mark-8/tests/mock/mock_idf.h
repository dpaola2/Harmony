/* Minimal ESP-IDF stand-ins for host tests of the slab sources. */
#pragma once
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
typedef int esp_err_t;
#define ESP_OK 0
#define ESP_FAIL -1
#define ESP_ERR_NO_MEM 0x101
#define ESP_ERR_INVALID_ARG 0x102
#define ESP_ERR_INVALID_STATE 0x103
#define ESP_ERR_INVALID_SIZE 0x104
#define ESP_ERR_TIMEOUT 0x107
static inline const char *esp_err_to_name(esp_err_t e) { return e ? "ERR" : "ESP_OK"; }
#define ESP_LOGI(...) ((void)0)
#define ESP_LOGW(...) ((void)0)
#define ESP_LOGE(...) ((void)0)
#define pdMS_TO_TICKS(x) (x)
#define portMAX_DELAY 0xffffffffU
void vTaskDelay(unsigned ticks);
/* GPIO */
#define GPIO_MODE_INPUT 1
#define GPIO_MODE_OUTPUT 2
#define GPIO_PULLUP_DISABLE 0
#define GPIO_PULLDOWN_DISABLE 0
#define GPIO_INTR_DISABLE 0
typedef struct { uint64_t pin_bit_mask; int mode, pull_up_en, pull_down_en, intr_type; } gpio_config_t;
esp_err_t gpio_config(const gpio_config_t *cfg);
esp_err_t gpio_set_level(int pin, int level);
/* SPI master */
#define SPI2_HOST 1
#define SPI3_HOST 2
#define SPI_DMA_CH_AUTO 3
#define SPI_TRANS_USE_TXDATA (1u << 2)
typedef void *spi_device_handle_t;
typedef struct {
    uint32_t flags;
    size_t length;
    union { const void *tx_buffer; uint8_t tx_data[4]; };
} spi_transaction_t;
typedef struct { int mosi_io_num, miso_io_num, sclk_io_num, quadwp_io_num, quadhd_io_num, max_transfer_sz; } spi_bus_config_t;
#define SPI_DEVICE_HALFDUPLEX (1u << 4)
typedef struct { int clock_speed_hz, mode, spics_io_num, queue_size; uint32_t flags; } spi_device_interface_config_t;
esp_err_t spi_bus_initialize(int host, const spi_bus_config_t *cfg, int dma);
esp_err_t spi_bus_free(int host);
esp_err_t spi_bus_add_device(int host, const spi_device_interface_config_t *cfg, spi_device_handle_t *out);
esp_err_t spi_bus_remove_device(spi_device_handle_t dev);
esp_err_t spi_device_polling_transmit(spi_device_handle_t dev, spi_transaction_t *t);
esp_err_t spi_device_queue_trans(spi_device_handle_t dev, spi_transaction_t *t, uint32_t wait);
esp_err_t spi_device_get_trans_result(spi_device_handle_t dev, spi_transaction_t **t, uint32_t wait);
/* Heap */
#define MALLOC_CAP_DMA (1u << 3)
#define MALLOC_CAP_INTERNAL (1u << 11)
#define MALLOC_CAP_SPIRAM (1u << 10)
#define MALLOC_CAP_8BIT (1u << 2)
void *heap_caps_malloc(size_t size, uint32_t caps);
void heap_caps_free(void *p);
