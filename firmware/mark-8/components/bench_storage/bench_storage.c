/* Mark-8 copy of firmware/mark-6/feather-player-bench/components/bench_storage/
 * bench_storage.c (October 9 working tree). Changes: VSPI (SPI3) with the slab
 * card pins, CONFIG_SLAB_SD_SPI_KHZ, the bus is freed on unmount, and
 * bench_storage_card() for the bring-up read test. */
#include <string.h>
#include "sdkconfig.h"
#include "bench_storage.h"
#include "esp_log.h"
#include "esp_check.h"
#include "slab_board.h"
#include "esp_vfs_fat.h"
#include "sdmmc_cmd.h"
#include "driver/spi_master.h"
#include "driver/sdspi_host.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#ifndef CONFIG_SLAB_SD_SPI_KHZ
#define CONFIG_SLAB_SD_SPI_KHZ 20000
#endif
#define SD_HOST SPI3_HOST

static sdmmc_card_t *card;
static bool bus_up;
static const char *TAG = "SD_SLAB";

esp_err_t __real_sdmmc_card_init(const sdmmc_host_t *host, sdmmc_card_t *out_card);

/* This uses an SD memory card, not SDIO. Reset it before IDF's CMD52 probe so
 * a card left powered across an ESP32 reset can re-enter SPI mode. Follow
 * IDF's two-CMD0 sequence: first without response, then with R1. */
esp_err_t __wrap_sdmmc_card_init(const sdmmc_host_t *host, sdmmc_card_t *out_card)
{
    if (host->flags & SDMMC_HOST_FLAG_SPI) {
        sdmmc_command_t reset = {
            .opcode = 0, .arg = 0, .flags = SCF_CMD_BC | SCF_RSP_R0,
            .timeout_ms = 1000,
        };
        (void)host->do_transaction(host->slot, &reset);
        vTaskDelay(pdMS_TO_TICKS(20));
        reset.flags |= SCF_RSP_R1;
        reset.error = ESP_OK;
        esp_err_t err = host->do_transaction(host->slot, &reset);
        if (err != ESP_OK) return err;
        if (reset.error != ESP_OK) return reset.error;
        vTaskDelay(pdMS_TO_TICKS(20));
        ESP_LOGI(TAG, "CARD_RESET_DONE before initialization");
    }
    return __real_sdmmc_card_init(host, out_card);
}

/* Fail closed even if a library accidentally tries to modify the card. */
esp_err_t __wrap_sdmmc_write_sectors(sdmmc_card_t *unused_card, const void *src,
                                   size_t start_sector, size_t sector_count)
{
    ESP_LOGE(TAG, "CARD_WRITE_BLOCKED sector=%u count=%u",
             (unsigned)start_sector, (unsigned)sector_count);
    return ESP_ERR_NOT_SUPPORTED;
}

sdmmc_card_t *bench_storage_card(void) { return card; }

esp_err_t bench_storage_mount(void)
{
    if (!slab_board_periph_powered()) return ESP_ERR_INVALID_STATE;
    if (card) return ESP_OK;
    ESP_LOGI(TAG, "READ_ONLY mount: SCK=5 MOSI=19 MISO=21 CS=25, VSPI %d kHz", CONFIG_SLAB_SD_SPI_KHZ);
    sdmmc_host_t host = SDSPI_HOST_DEFAULT();
    host.slot = SD_HOST;
    host.max_freq_khz = CONFIG_SLAB_SD_SPI_KHZ;
    spi_bus_config_t bus = {
        .mosi_io_num = SLAB_PIN_SD_MOSI, .miso_io_num = SLAB_PIN_SD_MISO, .sclk_io_num = SLAB_PIN_SD_SCK,
        .quadwp_io_num = -1, .quadhd_io_num = -1, .max_transfer_sz = 16384,
    };
    esp_err_t err = spi_bus_initialize(SD_HOST, &bus, SDSPI_DEFAULT_DMA);
    if (err != ESP_OK) return err;
    bus_up = true;
    sdspi_device_config_t slot = SDSPI_DEVICE_CONFIG_DEFAULT();
    slot.host_id = SD_HOST;
    slot.gpio_cs = SLAB_PIN_SD_CS;
    esp_vfs_fat_sdmmc_mount_config_t mount = {
        .format_if_mount_failed = false, .max_files = 4, .allocation_unit_size = 0,
    };
    err = esp_vfs_fat_sdspi_mount("/sd", &host, &slot, &mount, &card);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Mount failed: %s; no formatting attempted", esp_err_to_name(err));
        card = NULL;
        spi_bus_free(SD_HOST);
        bus_up = false;
        return err;
    }
    sdmmc_card_print_info(stdout, card);
    return ESP_OK;
}

void bench_storage_unmount(void)
{
    if (card) {
        esp_vfs_fat_sdcard_unmount("/sd", card);
        card = NULL;
        ESP_LOGI(TAG, "UNMOUNTED");
    }
    if (bus_up) { spi_bus_free(SD_HOST); bus_up = false; }
}
