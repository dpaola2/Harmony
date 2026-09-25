#include <stdatomic.h>
#include <string.h>
#include <inttypes.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/stream_buffer.h"
#include "esp_heap_caps.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "bench_storage.h"
#include "mp3_reader.h"
#include "audio_player.h"

#define PCM_BYTES (128 * 1024)
static StreamBufferHandle_t stream;
static StaticStreamBuffer_t stream_state;
static atomic_bool done, stopped, failed;
static atomic_uint_least32_t produced, consumed, underrun_bytes, max_decode_us;
static const char *TAG = "MP3_BENCH";

static void producer(void *arg)
{
    mp3_reader_t *reader = calloc(1, sizeof(*reader));
    int16_t *pcm = malloc(MINIMP3_MAX_SAMPLES_PER_FRAME * sizeof(int16_t));
    if (!reader || !pcm || mp3_reader_open(reader, "/sd/HARMONY/HIGHER.MP3")) {
        ESP_LOGE(TAG, "Track open/allocation failed");
        atomic_store(&failed, true);
        goto cleanup;
    }
    while (!atomic_load(&stopped)) {
        int64_t start = esp_timer_get_time();
        int count = mp3_reader_next(reader, pcm);
        uint32_t elapsed = (uint32_t)(esp_timer_get_time() - start);
        if (elapsed > atomic_load(&max_decode_us)) atomic_store(&max_decode_us, elapsed);
        if (count < 0) {
            ESP_LOGE(TAG, "Decode/IO failure or unsupported format (requires 44.1kHz stereo MP3)");
            atomic_store(&failed, true);
            break;
        }
        if (!count) break;
        for (int i = 0; i < count; i++) pcm[i] /= 16; /* -24 dB digital attenuation */
        size_t bytes = (size_t)count * sizeof(int16_t), sent = 0;
        while (sent < bytes && !atomic_load(&stopped)) {
            sent += xStreamBufferSend(stream, (uint8_t *)pcm + sent, bytes - sent, pdMS_TO_TICKS(100));
        }
        atomic_fetch_add(&produced, sent / 4);
    }
cleanup:
    if (reader) mp3_reader_close(reader);
    free(reader);
    free(pcm);
    bench_storage_unmount();
    ESP_LOGI(TAG, "PRODUCER_DONE frames=%"PRIu32" failed=%d", atomic_load(&produced), atomic_load(&failed));
    atomic_store(&done, true);
    vTaskDelete(NULL);
}

bool audio_player_prepare(void)
{
    if (bench_storage_mount() != ESP_OK) return false;
    uint8_t *storage = heap_caps_malloc(PCM_BYTES + 1, MALLOC_CAP_SPIRAM | MALLOC_CAP_8BIT);
    if (!storage) {
        bench_storage_unmount();
        return false;
    }
    stream = xStreamBufferCreateStatic(PCM_BYTES + 1, 1, storage, &stream_state);
    if (!stream || xTaskCreatePinnedToCore(producer, "mp3_decode", 24576, NULL, 5, NULL, 1) != pdPASS) {
        if (stream) vStreamBufferDelete(stream);
        stream = NULL;
        free(storage);
        bench_storage_unmount();
        return false;
    }
    int64_t deadline = esp_timer_get_time() + 10000000;
    while (xStreamBufferBytesAvailable(stream) < PCM_BYTES / 2 && !atomic_load(&done)) {
        if (esp_timer_get_time() >= deadline) {
            audio_player_stop();
            return false;
        }
        vTaskDelay(pdMS_TO_TICKS(10));
    }
    ESP_LOGI(TAG, "PREFILLED bytes=%u gain=-24dB", (unsigned)xStreamBufferBytesAvailable(stream));
    return !atomic_load(&failed) && xStreamBufferBytesAvailable(stream) > 0;
}

int32_t audio_player_read(uint8_t *data, int32_t len)
{
    if (!data || len <= 0) return 0;
    memset(data, 0, len);
    if (atomic_load(&stopped)) return len;
    size_t n = xStreamBufferReceive(stream, data, len, 0);
    atomic_fetch_add(&consumed, n / 4);
    if (n < (size_t)len && !atomic_load(&done)) atomic_fetch_add(&underrun_bytes, len - n);
    return len;
}

bool audio_player_finished(void)
{
    return atomic_load(&done) && xStreamBufferBytesAvailable(stream) == 0;
}

void audio_player_stop(void)
{
    atomic_store(&stopped, true);
}

audio_player_snapshot_t audio_player_snapshot(void)
{
    return (audio_player_snapshot_t) {
        .consumed_frames = atomic_load(&consumed),
        .finished = audio_player_finished(),
        .stopped = atomic_load(&stopped),
        .failed = atomic_load(&failed),
    };
}

void audio_player_log(void)
{
    ESP_LOGI(TAG, "PLAYBACK produced=%"PRIu32" consumed=%"PRIu32" queued=%u underrun_bytes=%"PRIu32" max_decode_us=%"PRIu32" done=%d failed=%d",
             atomic_load(&produced), atomic_load(&consumed), (unsigned)xStreamBufferBytesAvailable(stream),
             atomic_load(&underrun_bytes), atomic_load(&max_decode_us), atomic_load(&done), atomic_load(&failed));
}
