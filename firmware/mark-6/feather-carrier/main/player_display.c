#include <stdio.h>
#include <inttypes.h>
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_heap_caps.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "bench_display.h"
#include "audio_player.h"
#include "player_display.h"
#include "player_ui.h"
#include "ui_render.h"
#include "ui_assets/trial_durations.h"

#define FRAME_WORDS (320*480)
#define STRIP_WORDS (320*8)
static uint16_t *frame, *previous;
static player_ui_view_t drawn_view;

static void draw_task(void *arg)
{
    bool first = true;
    esp_err_t err = ESP_OK;
    uint32_t max_draw_us = 0;
    unsigned updates = 0;
    while (err == ESP_OK) {
        player_ui_update();
        player_ui_view_t view = player_ui_view();
        /* Only elapsed whole seconds affect the pixels. Static menus must not
         * continually rasterize into PSRAM and delay physical input polling. */
        view.audio.consumed_frames = view.page == PLAYER_UI_NOW_PLAYING ?
            (view.audio.consumed_frames / 44100) * 44100 : 0;
        bool changed = first || memcmp(&view, &drawn_view, sizeof(view));
        const album_t *library = audio_player_library();
        unsigned duration = library && view.audio.track < library->count ?
            trial_duration(library->tracks[view.audio.track].path) : 0;
        int64_t start = esp_timer_get_time();
        if (changed && (first || !ui_render_selection(frame, &view, &drawn_view)))
            ui_render(frame, &view, duration);
        unsigned strips = 0;
        for (int y = 0; changed && y < 480 && err == ESP_OK; y += 8) {
            uint16_t *current = frame + y*320;
            uint16_t *old = previous + y*320;
            if (!first && !memcmp(current, old, STRIP_WORDS*sizeof(*frame))) continue;
            err = bench_display_blit(0, y, 320, 8, current);
            if (err == ESP_OK) memcpy(old, current, STRIP_WORDS*sizeof(*frame));
            ++strips;
            /* Limit each LCD bus hold to eight rows (~11 ms at 4 MHz).
             * Yield between strips for the audio producer and SD transactions. */
            vTaskDelay(1);
        }
        uint32_t elapsed = (uint32_t)(esp_timer_get_time() - start);
        if (elapsed > max_draw_us) max_draw_us = elapsed;
        if (changed || ++updates % 250 == 0)
            ESP_LOGI("DISPLAY", "UI page=%u title=%s selection=%u/%u strips=%u max_draw_us=%"PRIu32" stack_free_min=%u",
                (unsigned)view.page, view.title, view.selected, view.total_count, strips,
                max_draw_us, (unsigned)uxTaskGetStackHighWaterMark(NULL));
        first = false;
        drawn_view = view;
        if (view.audio.stopped) break;
        vTaskDelay(pdMS_TO_TICKS(20));
    }
    if (err != ESP_OK) {
        audio_player_stop();
        ESP_LOGE("DISPLAY", "Drawing failed; playback stopped: %s", esp_err_to_name(err));
    }
    free(frame); free(previous); frame = previous = NULL;
    vTaskDelete(NULL);
}
bool player_display_start(void)
{
    esp_err_t err = bench_display_init();
    if (err != ESP_OK) {
        ESP_LOGE("DISPLAY", "Initialization failed: %s", esp_err_to_name(err));
        return false;
    }
    frame = heap_caps_malloc(FRAME_WORDS*sizeof(*frame), MALLOC_CAP_SPIRAM|MALLOC_CAP_8BIT);
    previous = heap_caps_malloc(FRAME_WORDS*sizeof(*previous), MALLOC_CAP_SPIRAM|MALLOC_CAP_8BIT);
    if (!frame || !previous) { free(frame); free(previous); frame = previous = NULL; return false; }
    player_ui_init(); /* Before controls task starts producing input. */
    if (xTaskCreatePinnedToCore(draw_task, "player_display", 8192, NULL, 1, NULL, 0) != pdPASS) {
        free(frame); free(previous); frame = previous = NULL; return false;
    }
    return true;
}
