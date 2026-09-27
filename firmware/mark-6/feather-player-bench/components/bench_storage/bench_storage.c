#include <string.h>
#include "bench_storage.h"
#include "esp_log.h"
#include "esp_check.h"
#include "carrier_board.h"
#include "esp_vfs_fat.h"
#include "sdmmc_cmd.h"
#include "driver/spi_master.h"
#include "driver/sdspi_host.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

static sdmmc_card_t *card;
static const char *TAG = "SD_BENCH";

esp_err_t __real_sdmmc_card_init(const sdmmc_host_t *host, sdmmc_card_t *out_card);

/* This bench uses an SD memory card, not SDIO. Reset it before IDF's CMD52
 * probe so a card left powered across an ESP32 reset can re-enter SPI mode.
 * Follow IDF's two-CMD0 sequence: first without response, then with R1.
 */
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

esp_err_t bench_storage_mount(void)
{
    if (!carrier_board_ready()) return ESP_ERR_INVALID_STATE;
    ESP_LOGI(TAG, "READ_ONLY mount: SCK=14 MOSI=27 MISO=21 CS=25, shared SPI2 4MHz");
    sdmmc_host_t host = SDSPI_HOST_DEFAULT();
    host.slot = SPI2_HOST;
    host.max_freq_khz = 4000;
    spi_bus_config_t bus = {
        .mosi_io_num = CARRIER_TFT_MOSI, .miso_io_num = CARRIER_SD_MISO, .sclk_io_num = CARRIER_TFT_SCK,
        .quadwp_io_num = -1, .quadhd_io_num = -1, .max_transfer_sz = 16384,
    };
    esp_err_t err = spi_bus_initialize(host.slot, &bus, SDSPI_DEFAULT_DMA);
    if (err != ESP_OK) return err;
    sdspi_device_config_t slot = SDSPI_DEVICE_CONFIG_DEFAULT();
    slot.host_id = host.slot;
    slot.gpio_cs = CARRIER_SD_CS;
    esp_vfs_fat_sdmmc_mount_config_t mount = {
        .format_if_mount_failed = false, .max_files = 4, .allocation_unit_size = 0,
    };
    err = esp_vfs_fat_sdspi_mount("/sd", &host, &slot, &mount, &card);
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Mount failed: %s; no formatting attempted", esp_err_to_name(err));
        spi_bus_free(host.slot);
        return err;
    }
    sdmmc_card_print_info(stdout, card);
    return ESP_OK;
}

void bench_storage_unmount(void)
{
    if (card) {
        ESP_ERROR_CHECK(esp_vfs_fat_sdcard_unmount("/sd", card));
        card = NULL;
        /* LCD still owns a device on SPI2; leave the shared bus initialized. */
        ESP_LOGI(TAG, "UNMOUNTED");
    }
}
