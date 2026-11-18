#include <string.h>
#include "slab_cal.h"
#include "nvs.h"

#define NAMESPACE "slab_cal"
#define VERSION 1

bool slab_cal_load(slab_cal_t *out)
{
    nvs_handle_t h;
    if (nvs_open(NAMESPACE, NVS_READONLY, &h) != ESP_OK) return false;
    uint8_t version = 0;
    size_t size = sizeof(*out);
    slab_cal_t cal;
    bool ok = nvs_get_u8(h, "version", &version) == ESP_OK && version == VERSION &&
              nvs_get_blob(h, "cal", &cal, &size) == ESP_OK && size == sizeof(cal);
    nvs_close(h);
    if (!ok) return false;
    for (unsigned i = 0; i < SLAB_CAL_ELECTRODES; ++i)
        if (!cal.touch[i] || cal.release[i] >= cal.touch[i]) return false;
    *out = cal;
    return true;
}

esp_err_t slab_cal_save(const slab_cal_t *cal)
{
    nvs_handle_t h;
    esp_err_t err = nvs_open(NAMESPACE, NVS_READWRITE, &h);
    if (err != ESP_OK) return err;
    err = nvs_set_blob(h, "cal", cal, sizeof(*cal));
    if (err == ESP_OK) err = nvs_set_u8(h, "version", VERSION);
    if (err == ESP_OK) err = nvs_commit(h);
    nvs_close(h);
    return err;
}
