#include <stdatomic.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <inttypes.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/semphr.h"
#include "esp_heap_caps.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "bench_storage.h"
#include "mp3_reader.h"
#include "audio_player.h"
#include "playback.h"

#define PCM_BYTES (128 * 1024)
static SemaphoreHandle_t lock;
static StaticSemaphore_t lock_storage;
static playback_t player;
static album_t *album;
static atomic_uint_least32_t max_decode_us, contention_bytes;
static const char *TAG = "ALBUM";
/* The mutex protects RAM copies/state only. Never hold it over SD/decoder I/O,
 * logging, sleeps or display writes. The A2DP callback never waits for it. */
#define LOCK() xSemaphoreTake(lock, portMAX_DELAY)
#define UNLOCK() xSemaphoreGive(lock)

static void producer(void *arg)
{
    mp3_reader_t *reader = calloc(1, sizeof(*reader));
    int16_t *pcm = malloc(MINIMP3_MAX_SAMPLES_PER_FRAME * sizeof(int16_t));
    uint32_t generation = 0;
    size_t pending = 0, sent = 0;
    bool end = false;
    if (!reader || !pcm) {
        LOCK(); playback_end(&player, player.generation, true); UNLOCK();
        goto cleanup;
    }
    for (;;) {
        LOCK();
        playback_tick(&player);
        bool stopped = player.stopped;
        uint32_t requested = player.generation;
        unsigned track = player.track;
        UNLOCK();
        if (stopped) break;
        if (requested != generation) {
            mp3_reader_close(reader);
            generation = requested;
            pending = sent = 0;
            char path[ALBUM_PATH_MAX + 16];
            snprintf(path, sizeof(path), "/sd/HARMONY/%s", album->tracks[track].path);
            end = mp3_reader_open(reader, path) != 0;
            ESP_LOGI(TAG, "TRACK index=%u/%u file=%s generation=%"PRIu32,
                     track + 1, album->count, path, generation);
            if (end) {
                LOCK(); playback_end(&player, generation, true); UNLOCK();
                ESP_LOGE(TAG, "Track open failed; album stopped at this track");
            }
        }
        if (end) { vTaskDelay(pdMS_TO_TICKS(10)); continue; }
        if (sent == pending) {
            int64_t start = esp_timer_get_time();
            int count = mp3_reader_next(reader, pcm);
            uint32_t elapsed = (uint32_t)(esp_timer_get_time() - start);
            if (elapsed > atomic_load(&max_decode_us)) atomic_store(&max_decode_us, elapsed);
            if (count <= 0) {
                mp3_reader_close(reader);
                end = true;
                LOCK(); playback_end(&player, generation, count < 0); UNLOCK();
                ESP_LOGI(TAG, "TRACK_DECODE_END generation=%"PRIu32" failed=%d", generation, count < 0);
                continue;
            }
            for (int i = 0; i < count; ++i) pcm[i] /= 16; /* Fixed -24 dB. */
            pending = (size_t)count * sizeof(*pcm);
            sent = 0;
        }
        LOCK();
        size_t n = playback_push(&player, generation, (uint8_t *)pcm + sent, pending - sent);
        UNLOCK();
        sent += n;
        if (!n) vTaskDelay(pdMS_TO_TICKS(5));
    }
cleanup:
    if (reader) mp3_reader_close(reader);
    free(reader);
    free(pcm);
    bench_storage_unmount();
    vTaskDelete(NULL);
}

bool audio_player_prepare(void)
{
    if (lock || bench_storage_mount() != ESP_OK) return false;
    album = calloc(1, sizeof(*album));
    uint8_t *storage = heap_caps_malloc(PCM_BYTES, MALLOC_CAP_SPIRAM | MALLOC_CAP_8BIT);
    if (!album || !storage) goto fail;
    FILE *file = fopen("/sd/HARMONY/ALBUM.M3U", "rb");
    if (file) {
        bool ok = album_parse(file, album);
        fclose(file);
        if (!ok) { ESP_LOGE(TAG, "Invalid/empty ALBUM.M3U"); goto fail; }
    } else if (errno == ENOENT) {
        album->count = 1;
        strcpy(album->tracks[0].path, "HIGHER.MP3");
        strcpy(album->tracks[0].title, "Higher");
        ESP_LOGI(TAG, "No ALBUM.M3U: using the original Higher fixture");
    } else goto fail;
    playback_init(&player, storage, PCM_BYTES, album->count);
    lock = xSemaphoreCreateMutexStatic(&lock_storage);
    if (!lock) goto fail;
    if (xTaskCreatePinnedToCore(producer, "mp3_decode", 24576, NULL, 5, NULL, 1) != pdPASS) {
        vSemaphoreDelete(lock); lock = NULL; goto fail;
    }
    int64_t deadline = esp_timer_get_time() + 10000000;
    for (;;) {
        LOCK(); bool ready = !player.buffering, failed = player.failed; UNLOCK();
        if (failed) { audio_player_stop(); return false; }
        if (ready) return true;
        if (esp_timer_get_time() >= deadline) { audio_player_stop(); return false; }
        vTaskDelay(pdMS_TO_TICKS(10));
    }
fail:
    free(album); album = NULL;
    free(storage);
    bench_storage_unmount();
    return false;
}

int32_t audio_player_read(uint8_t *data, int32_t len)
{
    if (!data || len <= 0) return 0;
    memset(data, 0, len);
    if (!lock) return len;
    if (xSemaphoreTake(lock, 0) != pdTRUE) {
        atomic_fetch_add(&contention_bytes, (uint32_t)len);
        return len;
    }
    playback_read(&player, data, (size_t)len);
    UNLOCK();
    return len;
}
void audio_player_connected(bool connected)
{
    if (!lock) return;
    LOCK(); player.connected = connected; UNLOCK();
}
void audio_player_browse(int delta)
{
    if (!lock) return;
    LOCK(); playback_browse(&player, delta); UNLOCK();
}
void audio_player_step(int delta)
{
    if (!lock) return;
    LOCK(); playback_step(&player, delta); UNLOCK();
}
void audio_player_activate(void)
{
    if (!lock) return;
    LOCK(); playback_activate(&player); UNLOCK();
}
bool audio_player_finished(void)
{
    if (!lock) return false;
    LOCK(); bool value = player.finished; UNLOCK(); return value;
}
void audio_player_stop(void)
{
    if (!lock) return;
    LOCK(); player.stopped = true; player.queued = 0; UNLOCK();
}
audio_player_snapshot_t audio_player_snapshot(void)
{
    audio_player_snapshot_t s = {0};
    if (!lock) return s;
    LOCK();
    s = (audio_player_snapshot_t){.consumed_frames = player.consumed_frames,
        .generation = player.generation, .track = player.track, .selection = player.selection,
        .count = player.count, .finished = player.finished, .stopped = player.stopped,
        .failed = player.failed, .paused = player.paused, .connected = player.connected,
        .buffering = player.buffering};
    strcpy(s.title, album->tracks[player.track].title);
    strcpy(s.selected_title, album->tracks[player.selection].title);
    UNLOCK();
    return s;
}
void audio_player_log(void)
{
    if (!lock) return;
    LOCK(); playback_t p = player; UNLOCK();
    ESP_LOGI(TAG, "PLAYBACK track=%u/%u frames=%"PRIu32" total=%"PRIu64" queued=%u underrun=%"PRIu64" contention=%"PRIu32" max_decode_us=%"PRIu32" done=%d failed=%d paused=%d connected=%d",
        p.track + 1, p.count, p.consumed_frames, p.total_frames, (unsigned)p.queued,
        p.underrun_bytes, atomic_load(&contention_bytes), atomic_load(&max_decode_us),
        p.finished, p.failed, p.paused, p.connected);
}
