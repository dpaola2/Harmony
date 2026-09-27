#pragma once
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
typedef int esp_err_t;
#define ESP_OK 0
#define ESP_ERR_INVALID_ARG 1
#define ESP_ERR_INVALID_STATE 2
#define ESP_ERR_INVALID_SIZE 3
#define ESP_ERR_TIMEOUT 4
#define DMA_ATTR
#define ESP_LOGI(...) ((void)0)
#define ESP_LOGE(...) ((void)0)
#define ESP_MAC_WIFI_STA 0
#define CONFIG_CARRIER_EXPECTED_MAC "58:aa:bb:cc:dd:ee"
#define pdMS_TO_TICKS(x) (x)
#define GPIO_MODE_INPUT 1
#define GPIO_MODE_OUTPUT 2
#define GPIO_PULLUP_DISABLE 0
#define GPIO_PULLDOWN_DISABLE 0
#define SPI2_HOST 2
#define SPI_DMA_CH_AUTO 1
typedef struct {uint64_t pin_bit_mask; int mode, pull_up_en, pull_down_en;} gpio_config_t;
typedef void *spi_device_handle_t;
typedef struct {size_t length; const void *tx_buffer;} spi_transaction_t;
typedef struct {int mosi_io_num, miso_io_num, sclk_io_num, quadwp_io_num,
    quadhd_io_num, max_transfer_sz;} spi_bus_config_t;
typedef struct {int clock_speed_hz, mode, spics_io_num, queue_size;} spi_device_interface_config_t;
esp_err_t gpio_config(const gpio_config_t *cfg);
esp_err_t gpio_set_level(int pin, int level);
esp_err_t gpio_set_direction(int pin, int direction);
int gpio_get_level(int pin);
esp_err_t esp_read_mac(uint8_t mac[6], int kind);
esp_err_t esp_flash_get_size(void *chip, uint32_t *size);
size_t esp_psram_get_size(void);
void vTaskDelay(unsigned ticks);
esp_err_t spi_bus_initialize(int host, const spi_bus_config_t *cfg, int dma);
esp_err_t spi_bus_add_device(int host, const spi_device_interface_config_t *cfg, spi_device_handle_t *out);
esp_err_t spi_device_transmit(spi_device_handle_t dev, spi_transaction_t *t);

#define portMAX_DELAY 0xffffffffU
esp_err_t spi_device_acquire_bus(spi_device_handle_t device, unsigned wait);
void spi_device_release_bus(spi_device_handle_t device);
