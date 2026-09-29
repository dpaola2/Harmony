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

_Static_assert((int)AUDIO_REPEAT_ALL == (int)PLAYBACK_REPEAT_ALL &&
               (int)AUDIO_REPEAT_ONE == (int)PLAYBACK_REPEAT_ONE, "repeat enum mismatch");
#define PCM_BYTES (128 * 1024)
static SemaphoreHandle_t lock;
static StaticSemaphore_t lock_storage;
static playback_t player;
static album_t *album;
static unsigned queue_tracks[ALBUM_MAX_TRACKS], queue_original[ALBUM_MAX_TRACKS];
/* Occurrence indices preserve duplicate entries in user playlists. */
static unsigned queue_order[ALBUM_MAX_TRACKS];
static bool shuffle_enabled;
static uint32_t shuffle_rng = 0x59734;
static atomic_uint volume_level = 40;
/* The serialized A2DP data callback is the sole owner after prepare. */
static playback_gain_t output_gain;
static atomic_uint_least32_t max_decode_us, contention_bytes, max_callback_us;
static const char *TAG = "ALBUM";
/* The mutex protects RAM copies/state only. Never hold it over SD/decoder I/O,
 * logging, sleeps or display writes. The A2DP callback waits at most 2 ms
 * for a short RAM-copy critical section before falling back to silence. */
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
        unsigned track = queue_tracks[player.track];
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
    if (lock) return false;
    bool mounted = bench_storage_mount() == ESP_OK;
#ifndef HARMONY_PLAYER_UI
    if (!mounted) return false;
#endif
    album = heap_caps_malloc(sizeof(*album), MALLOC_CAP_SPIRAM | MALLOC_CAP_8BIT);
    uint8_t *storage = heap_caps_malloc(PCM_BYTES, MALLOC_CAP_SPIRAM | MALLOC_CAP_8BIT);
    if (!album || !storage) goto fail;
    memset(album, 0, sizeof(*album));
#ifdef HARMONY_PLAYER_UI
    if (!mounted) album->status = ALBUM_STATUS_MISSING;
    else if (!album_load("/sd/HARMONY", album))
        ESP_LOGE(TAG, "Library unavailable: %s", album_status_text(album->status));
#else
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
#endif
    for (unsigned i = 0; i < album->count; ++i) {
        queue_tracks[i] = queue_original[i] = i;
        queue_order[i] = i;
    }
    playback_init(&player, storage, PCM_BYTES, album->count);
    atomic_store(&volume_level, 40);
    playback_gain_init(&output_gain, 40);
    shuffle_rng ^= (uint32_t)esp_timer_get_time();
    lock = xSemaphoreCreateMutexStatic(&lock_storage);
    if (!lock) goto fail;
#ifdef HARMONY_PLAYER_UI
    player.paused = true;
    if (!album->count) {
        /* Keep the UI alive with the immutable library error. No decoder task. */
        player.stopped = false;
        player.buffering = false;
        if (mounted) bench_storage_unmount();
        return true;
    }
#endif
    if (xTaskCreatePinnedToCore(producer, "mp3_decode", 24576, NULL, 5, NULL, 1) != pdPASS) {
        vSemaphoreDelete(lock); lock = NULL; goto fail;
    }
    int64_t deadline = esp_timer_get_time() + 10000000;
    for (;;) {
        LOCK(); bool ready = !player.buffering, failed = player.failed; UNLOCK();
#ifdef HARMONY_PLAYER_UI
        if (failed) return true; /* Browse to another song after a decode error. */
#else
        if (failed) { audio_player_stop(); return false; }
#endif
        if (ready) return true;
        if (esp_timer_get_time() >= deadline) {
            LOCK(); player.failed = true; player.buffering = false; UNLOCK();
            audio_player_stop();
            return false;
        }
        vTaskDelay(pdMS_TO_TICKS(10));
    }
fail:
    free(album); album = NULL;
    free(storage);
    if (mounted) bench_storage_unmount();
    return false;
}

static void record_callback_time(int64_t start)
{
    uint32_t elapsed = (uint32_t)(esp_timer_get_time() - start);
    if (elapsed > atomic_load(&max_callback_us)) atomic_store(&max_callback_us, elapsed);
}

int32_t audio_player_read(uint8_t *data, int32_t len)
{
    if (!data || len <= 0) return 0;
    int64_t started = esp_timer_get_time();
    memset(data, 0, len);
    if (!lock) return len;
    if (xSemaphoreTake(lock, pdMS_TO_TICKS(2)) != pdTRUE) {
        atomic_fetch_add(&contention_bytes, (uint32_t)len);
        record_callback_time(started);
        return len;
    }
    playback_read(&player, data, (size_t)len);
    UNLOCK();
    /* Gain applies to already-queued raw PCM. Changing level never waits for
     * the SD producer or holds its mutex during per-sample work. */
    playback_gain_apply(&output_gain, data, (size_t)len, atomic_load(&volume_level));
    record_callback_time(started);
    return len;
}
void audio_player_connected(bool connected)
{
    if (!lock) return;
    LOCK();
#ifdef HARMONY_PLAYER_UI
    if (!connected) player.paused = true;
#endif
    player.connected = connected;
    UNLOCK();
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
    LOCK(); if (player.count) playback_activate(&player); UNLOCK();
}
const album_t *audio_player_library(void)
{
    return lock ? album : NULL;
}
static unsigned shuffle_random(void)
{
    shuffle_rng = shuffle_rng * 1664525U + 1013904223U;
    return shuffle_rng;
}
/* Caller holds the audio lock. No file access or allocation. */
static void order_queue(unsigned anchor, unsigned selected)
{
    for (unsigned i = 0; i < player.count; ++i) queue_order[i] = i;
    if (shuffle_enabled && player.count) {
        queue_order[0] = anchor;
        queue_order[anchor] = 0;
        for (unsigned i = player.count - 1; i > 1; --i) {
            unsigned j = 1 + shuffle_random() % i;
            unsigned saved = queue_order[i]; queue_order[i] = queue_order[j]; queue_order[j] = saved;
        }
    }
    for (unsigned i = 0; i < player.count; ++i) {
        queue_tracks[i] = queue_original[queue_order[i]];
        if (queue_order[i] == anchor) player.track = i;
        if (queue_order[i] == selected) player.selection = i;
    }
}
bool audio_player_play_queue(const unsigned *tracks, unsigned count, unsigned start)
{
    if (!lock || !tracks || !count || count > ALBUM_MAX_TRACKS || start >= count) return false;
    for (unsigned i = 0; i < count; ++i) if (tracks[i] >= album->count) return false;
    LOCK();
    if (player.stopped) { UNLOCK(); return false; }
    memcpy(queue_original, tracks, count * sizeof(*tracks));
    player.count = count;
    order_queue(start, start);
    /* Activate starts a new decoder generation even if the index is unchanged. */
    player.finished = true;
    playback_activate(&player);
    UNLOCK();
    return true;
}
void audio_player_toggle_pause(void)
{
    if (!lock) return;
    LOCK();
    if (player.count) {
        player.selection = player.track;
        playback_activate(&player);
    }
    UNLOCK();
}
void audio_player_set_paused(bool paused)
{
    if (!lock) return;
    LOCK();
    if (!paused && player.count && (player.finished || player.failed)) {
        player.selection = player.track;
        playback_activate(&player);
    }
    player.paused = paused;
    UNLOCK();
}
void audio_player_set_volume(unsigned volume)
{
    atomic_store(&volume_level, volume > 100 ? 100 : volume);
}
unsigned audio_player_volume(void)
{
    return atomic_load(&volume_level);
}
void audio_player_set_modes(bool shuffle, unsigned repeat)
{
    if (!lock) return;
    LOCK();
    if (shuffle != shuffle_enabled) {
        unsigned anchor = player.count ? queue_order[player.track] : 0;
        unsigned selected = player.count ? queue_order[player.selection] : 0;
        shuffle_enabled = shuffle;
        order_queue(anchor, selected);
    }
    player.repeat = repeat <= AUDIO_REPEAT_ONE ? repeat : AUDIO_REPEAT_OFF;
    UNLOCK();
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
    audio_player_snapshot_t s = {.volume = atomic_load(&volume_level)};
    if (!lock) {
#ifdef HARMONY_PLAYER_UI
        /* Preparation could fail before mutex creation (for example no RAM).
         * The recovery display must not imply an empty engine is playing. */
        s.failed = s.paused = s.stopped = true;
#endif
        return s;
    }
    LOCK();
    s = (audio_player_snapshot_t){.consumed_frames = player.consumed_frames,
        .generation = player.generation, .track = queue_tracks[player.track],
        .selection = queue_tracks[player.selection], .count = album->count,
        .queue_position = player.track, .queue_count = player.count, .finished = player.finished, .stopped = player.stopped,
        .failed = player.failed, .paused = player.paused, .connected = player.connected,
        .buffering = player.buffering, .volume = atomic_load(&volume_level),
        .shuffle = shuffle_enabled, .repeat = player.repeat};
    if (album->count) {
        strcpy(s.title, album->tracks[queue_tracks[player.track]].title);
        strcpy(s.selected_title, album->tracks[queue_tracks[player.selection]].title);
    }
    UNLOCK();
    return s;
}
void audio_player_log(void)
{
    if (!lock) return;
    LOCK(); playback_t p = player; UNLOCK();
    ESP_LOGI(TAG, "PLAYBACK track=%u/%u frames=%"PRIu32" total=%"PRIu64" queued=%u underrun=%"PRIu64" contention=%"PRIu32" max_decode_us=%"PRIu32" callback_us=%"PRIu32" done=%d failed=%d paused=%d connected=%d volume=%u",
        p.track + 1, p.count, p.consumed_frames, p.total_frames, (unsigned)p.queued,
        p.underrun_bytes, atomic_load(&contention_bytes), atomic_load(&max_decode_us), atomic_load(&max_callback_us),
        p.finished, p.failed, p.paused, p.connected, atomic_load(&volume_level));
}
