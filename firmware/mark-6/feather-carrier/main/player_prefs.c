#include "player_prefs.h"
#include <string.h>
#ifdef ESP_PLATFORM
#include "nvs.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/semphr.h"
#include "esp_log.h"
static StaticSemaphore_t mutex_storage;
static SemaphoreHandle_t mutex;
static uint32_t revision, saved_revision;
static bool available;
#define LOCK() xSemaphoreTake(mutex, portMAX_DELAY)
#define UNLOCK() xSemaphoreGive(mutex)
#else
static bool available = true;
#define LOCK() ((void)0)
#define UNLOCK() ((void)0)
#endif
static player_prefs_t value;
static void validate(player_prefs_t *p)
{
    if (p->version != 1) { memset(p, 0, sizeof(*p)); p->version = 1; p->volume = PLAYER_VOLUME_DEFAULT; }
    if (p->volume > 100) p->volume = PLAYER_VOLUME_DEFAULT;
    if (p->repeat > 2) p->repeat = 0;
    if (p->timeout_seconds != 0 && p->timeout_seconds != 30 && p->timeout_seconds != 60 && p->timeout_seconds != 120) p->timeout_seconds = 0;
    p->track_path[sizeof(p->track_path)-1] = 0;
}
#ifdef ESP_PLATFORM
static void save_task(void *unused)
{
    uint32_t observed = 0;
    for (;;) {
        vTaskDelay(pdMS_TO_TICKS(2000));
        LOCK(); uint32_t rev = revision; player_prefs_t copy = value; UNLOCK();
        /* Save after settings stop changing; avoid a flash write per detent. */
        if (rev == saved_revision || rev != observed) { observed = rev; continue; }
        nvs_handle_t handle;
        esp_err_t err = nvs_open("harmony_ui", NVS_READWRITE, &handle);
        if (err == ESP_OK) {
            err = nvs_set_blob(handle, "prefs", &copy, sizeof(copy));
            if (err == ESP_OK) err = nvs_commit(handle);
            nvs_close(handle);
        }
        LOCK(); available = err == ESP_OK; UNLOCK();
        if (err == ESP_OK) saved_revision = rev;
        else ESP_LOGW("PREFS", "Preferences not saved: %s", esp_err_to_name(err));
    }
}
#endif
void player_prefs_init(void)
{
#ifdef ESP_PLATFORM
    if (mutex) return;
    mutex = xSemaphoreCreateMutexStatic(&mutex_storage);
    nvs_handle_t handle;
    available = nvs_open("harmony_ui", NVS_READWRITE, &handle) == ESP_OK;
    if (available) {
        size_t size = sizeof(value);
        if (nvs_get_blob(handle, "prefs", &value, &size) != ESP_OK || size != sizeof(value)) memset(&value, 0, sizeof(value));
        nvs_close(handle);
    }
#endif
    validate(&value);
    if (value.volume > PLAYER_VOLUME_START_MAX) value.volume = PLAYER_VOLUME_START_MAX;
#ifdef ESP_PLATFORM
    if (xTaskCreatePinnedToCore(save_task, "player_prefs", 4096, NULL, 1, NULL, 0) != pdPASS) available = false;
#endif
}
player_prefs_t player_prefs_get(void) { LOCK(); player_prefs_t p = value; UNLOCK(); return p; }
void player_prefs_update(const player_prefs_t *p)
{
    player_prefs_t next = *p; validate(&next);
    LOCK();
    if (memcmp(&next, &value, sizeof(value))) {
        value = next;
#ifdef ESP_PLATFORM
        ++revision;
#endif
    }
    UNLOCK();
}
bool player_prefs_available(void) { LOCK(); bool ok = available; UNLOCK(); return ok; }
