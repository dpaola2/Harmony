#include <string.h>
#include "sd_bench.h"
#include "album.h"
#include <stdio.h>
#include <sys/stat.h>
#include "mbedtls/sha256.h"
#include "trial_manifest.h"
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

esp_err_t sd_bench_mount(void)
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


static album_t playlist;
static FILE *song;
static uint8_t buffer[16384];
static size_t bytes_read;
static mbedtls_sha256_context hash;

esp_err_t sd_bench_verify_start(void)
{
    FILE *m3u=fopen("/sd/HARMONY/ALBUM.M3U","rb");
    if(!m3u) return ESP_FAIL;
    bool parsed=album_parse(m3u,&playlist);
    fclose(m3u);
    if(!parsed || playlist.count!=sizeof(expected_tracks)/sizeof(expected_tracks[0])) return ESP_ERR_INVALID_SIZE;
    for(unsigned i=0;i<playlist.count;i++){
        if(strcmp(playlist.tracks[i].path,expected_tracks[i].path)) return ESP_ERR_INVALID_ARG;
        char path[256];
        snprintf(path,sizeof path,"/sd/HARMONY/%s",playlist.tracks[i].path);
        struct stat info;
        if(stat(path,&info) || (size_t)info.st_size!=expected_tracks[i].bytes) return ESP_ERR_INVALID_SIZE;
        FILE *f=fopen(path,"rb");
        if(!f) return ESP_FAIL;
        size_t n=fread(buffer,1,512,f);
        bool ok=n==512 && !ferror(f);
        fclose(f);
        if(!ok) return ESP_FAIL;
        ESP_LOGI(TAG,"FILE_OK %u/%u bytes=%u %s",i+1,playlist.count,(unsigned)info.st_size,playlist.tracks[i].path);
    }
    ESP_LOGI(TAG,"PLAYLIST_PASS: all 45 paths, sizes and first 512 bytes readable");
    char path[256];
    snprintf(path,sizeof path,"/sd/HARMONY/%s",playlist.tracks[0].path);
    song=fopen(path,"rb");
    if(!song) return ESP_FAIL;
    bytes_read=0;
    mbedtls_sha256_init(&hash);
    if(mbedtls_sha256_starts(&hash,0)) {fclose(song);song=NULL;mbedtls_sha256_free(&hash);return ESP_FAIL;}
    return ESP_OK;
}
esp_err_t sd_bench_verify_step(bool *done,unsigned *percent)
{
    if(!song) return ESP_ERR_INVALID_STATE;
    *done=false;
    size_t n=fread(buffer,1,sizeof buffer,song);
    esp_err_t err=ESP_OK;
    if(ferror(song) || mbedtls_sha256_update(&hash,buffer,n)) err=ESP_FAIL;
    bytes_read+=n;
    *percent=(unsigned)(100*bytes_read/expected_tracks[0].bytes);
    if(err==ESP_OK && n==sizeof buffer) return ESP_OK;
    uint8_t digest[32];
    if(err==ESP_OK && (mbedtls_sha256_finish(&hash,digest) ||
        bytes_read!=expected_tracks[0].bytes || memcmp(digest,expected_first_sha256,32))) err=ESP_FAIL;
    fclose(song);song=NULL;mbedtls_sha256_free(&hash);
    *done=true;
    if(err==ESP_OK){
        char hex[65];
        for(unsigned i=0;i<32;i++) snprintf(hex+2*i,3,"%02x",digest[i]);
        ESP_LOGI(TAG,"SD_VERIFY_PASS: %u tracks; first song %u bytes SHA256=%s",playlist.count,(unsigned)bytes_read,hex);
    } else ESP_LOGE(TAG,"SD_VERIFY_FAIL at %u bytes",(unsigned)bytes_read);
    return err;
}
