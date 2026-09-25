#include <stdio.h>
#include <inttypes.h>
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "bench_display.h"
#include "audio_player.h"
#include "player_display.h"
#define WHITE 0xffff
#define CYAN 0x07ff
/* Fixed 38-character fields clear shorter replacements without a full redraw. */
static esp_err_t field(unsigned y, const char *text, uint16_t color)
{
    char line[39];
    snprintf(line, sizeof(line), "%-38.38s", text);
    return bench_display_text(8, y, line, color, 0);
}
static void draw_task(void *arg)
{
    esp_err_t err = field(16, "HARMONY", CYAN);
    if (err == ESP_OK) err = field(112, "SoundCore 2", CYAN);
    if (err == ESP_OK) err = field(320, "Wheel / up / down: browse", WHITE);
    if (err == ESP_OK) err = field(344, "Center: choose / play / pause", WHITE);
    if (err == ESP_OK) err = field(368, "Left / right: previous / next", WHITE);
    audio_player_snapshot_t previous = {0};
    bool first = true;
    char previous_state[16] = "";
    uint32_t max_draw_us = 0;
    unsigned updates = 0;
    while (err == ESP_OK) {
        audio_player_snapshot_t s = audio_player_snapshot();
        const char *state = s.failed ? "TRACK ERROR" : s.stopped ? "STOPPED" :
            s.finished ? "ALBUM FINISHED" : s.paused ? "PAUSED" :
            !s.connected ? "CONNECTING" : s.buffering ? "BUFFERING" : "PLAYING";
        int64_t start = esp_timer_get_time();
        char label[64];
        if (first || s.generation != previous.generation) {
            err = field(56, s.title, WHITE);
            snprintf(label, sizeof(label), "Track %u of %u", s.track + 1, s.count);
            if (err == ESP_OK) err = field(80, label, WHITE);
        }
        if (err == ESP_OK && strcmp(state, previous_state)) {
            err = field(160, state, CYAN);
            snprintf(previous_state, sizeof(previous_state), "%s", state);
        }
        unsigned seconds = s.consumed_frames / 44100;
        if (err == ESP_OK && (first || s.generation != previous.generation || seconds != previous.consumed_frames / 44100)) {
            snprintf(label, sizeof(label), "Elapsed %u:%02u", seconds / 60, seconds % 60);
            err = field(192, label, WHITE);
        }
        if (err == ESP_OK && (first || s.selection != previous.selection)) {
            snprintf(label, sizeof(label), "Choose %u of %u", s.selection + 1, s.count);
            err = field(256, label, CYAN);
            if (err == ESP_OK) err = field(280, s.selected_title, WHITE);
        }
        previous = s;
        first = false;
        uint32_t elapsed = (uint32_t)(esp_timer_get_time() - start);
        if (elapsed > max_draw_us) max_draw_us = elapsed;
        if (++updates % 40 == 0)
            ESP_LOGI("DISPLAY", "UPDATE state=%s max_draw_us=%"PRIu32" stack_free_min=%u",
                     state, max_draw_us, (unsigned)uxTaskGetStackHighWaterMark(NULL));
        if (s.stopped) break;
        vTaskDelay(pdMS_TO_TICKS(250));
    }
    if (err != ESP_OK) {
        audio_player_stop();
        ESP_LOGE("DISPLAY", "Drawing failed; playback stopped: %s", esp_err_to_name(err));
    }
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
