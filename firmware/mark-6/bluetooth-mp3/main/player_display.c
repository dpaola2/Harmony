#include <stdio.h>
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "bench_display.h"
#include "audio_player.h"
#include "player_display.h"

/* Exact decoded frame count from the pinned single-song fixture. */
#define TOTAL_FRAMES 13969152U
#define TOTAL_SECONDS 317U
#define WHITE 0xffff
#define CYAN 0x07ff
#define GRAY 0x4208

static void draw_task(void *arg)
{
    esp_err_t err = bench_display_text(8, 6, "HARMONY", CYAN, 0);
    if (err == ESP_OK) err = bench_display_text(8, 25, "Higher", WHITE, 0);
    if (err == ESP_OK) err = bench_display_text(8, 43, "Creed - Human Clay", WHITE, 0);
    if (err == ESP_OK) err = bench_display_text(8, 61, "SoundCore 2", CYAN, 0);
    if (err == ESP_OK) err = bench_display_fill(8, 116, 224, 8, GRAY);
    unsigned previous_second = UINT32_MAX, previous_bar = 0, updates = 0;
    uint32_t max_draw_us = 0;
    char previous_state[12] = "";
    while (err == ESP_OK) {
        audio_player_snapshot_t s = audio_player_snapshot();
        unsigned seconds = s.consumed_frames / 44100;
        if (s.finished && !s.failed && s.consumed_frames == TOTAL_FRAMES) seconds = TOTAL_SECONDS;
        const char *state = s.failed ? "ERROR" :
            (s.finished && s.consumed_frames == TOTAL_FRAMES) ? "FINISHED" :
            s.stopped ? "STOPPED" : s.consumed_frames ? "PLAYING" : "CONNECTING";
        int64_t start = esp_timer_get_time();
        if (strcmp(state, previous_state)) {
            char field[13]; snprintf(field, sizeof(field), "%-11s", state);
            err = bench_display_text(8, 79, field, CYAN, 0);
            snprintf(previous_state, sizeof(previous_state), "%s", state);
        }
        if (err == ESP_OK && seconds != previous_second) {
            char time_text[24];
            snprintf(time_text, sizeof(time_text), "%u:%02u / 5:17", seconds / 60, seconds % 60);
            err = bench_display_text(8, 97, time_text, WHITE, 0);
            previous_second = seconds;
        }
        unsigned bar = (uint64_t)s.consumed_frames * 224 / TOTAL_FRAMES;
        if (bar > 224) bar = 224;
        if (err == ESP_OK && bar > previous_bar) {
            err = bench_display_fill(8 + previous_bar, 116, bar - previous_bar, 8, CYAN);
            previous_bar = bar;
        }
        uint32_t elapsed = esp_timer_get_time() - start;
        if (elapsed > max_draw_us) max_draw_us = elapsed;
        if (++updates % 10 == 0 || s.finished || s.stopped) {
            ESP_LOGI("DISPLAY", "UPDATE count=%u elapsed_s=%u state=%s max_draw_us=%lu stack_free_min=%u",
                     updates, seconds, state, (unsigned long)max_draw_us,
                     (unsigned)uxTaskGetStackHighWaterMark(NULL));
        }
        if (s.finished || s.stopped) break;
        vTaskDelay(pdMS_TO_TICKS(1000));
    }
    if (err != ESP_OK) ESP_LOGE("DISPLAY", "Drawing stopped: %s", esp_err_to_name(err));
    vTaskDelete(NULL);
}

bool player_display_start(void)
{
    esp_err_t err = bench_display_init();
    if (err != ESP_OK) {
        ESP_LOGE("DISPLAY", "Initialization failed: %s", esp_err_to_name(err));
        return false;
    }
    return xTaskCreatePinnedToCore(draw_task, "player_display", 6144, NULL, 2, NULL, 0) == pdPASS;
}
