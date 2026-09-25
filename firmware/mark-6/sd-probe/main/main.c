#include <stdio.h>
#include <dirent.h>
#include <string.h>
#include "esp_log.h"
#include "esp_timer.h"
#include "mbedtls/sha256.h"
#include "bench_storage.h"

void app_main(void)
{
    if (bench_storage_mount() != ESP_OK) return;
    DIR *dir = opendir("/sd/HARMONY");
    if (dir) {
        struct dirent *entry;
        while ((entry = readdir(dir))) ESP_LOGI("SD_PROBE", "HARMONY/%s", entry->d_name);
        closedir(dir);
    }
    FILE *f = fopen("/sd/HARMONY/HIGHER.MP3", "rb");
    if (!f) {
        ESP_LOGE("SD_PROBE", "HIGHER.MP3 not found");
        bench_storage_unmount();
        return;
    }
    static unsigned char buf[16384];
    unsigned char hash[32];
    mbedtls_sha256_context ctx;
    mbedtls_sha256_init(&ctx);
    ESP_ERROR_CHECK(mbedtls_sha256_starts(&ctx, 0));
    size_t total = 0, n;
    int64_t start = esp_timer_get_time();
    while ((n = fread(buf, 1, sizeof(buf), f))) {
        ESP_ERROR_CHECK(mbedtls_sha256_update(&ctx, buf, n));
        total += n;
    }
    int failed = ferror(f);
    fclose(f);
    ESP_ERROR_CHECK(mbedtls_sha256_finish(&ctx, hash));
    mbedtls_sha256_free(&ctx);
    char hex[65];
    for (int i = 0; i < 32; i++) sprintf(hex + 2*i, "%02x", hash[i]);
    double seconds = (esp_timer_get_time() - start) / 1000000.0;
    ESP_LOGI("SD_PROBE", "bytes=%u seconds=%.3f bytes_per_second=%.0f sha256=%s",
             (unsigned)total, seconds, total / seconds, hex);
    const char *expected = "0fbc69ad617c28395ed4b6c62571ac63898a057309a872a73d4aad6a303ca6dd";
    if (!failed && total == 5070386 && !strcmp(hex, expected)) {
        ESP_LOGI("SD_PROBE", "SD_READ_TEST_PASSED");
    } else {
        ESP_LOGE("SD_PROBE", "SD_READ_TEST_FAILED io_error=%d", failed);
    }
    bench_storage_unmount();
}
