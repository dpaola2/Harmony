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
#include "player_power.h"
#include "ui_render.h"
#include "ui_assets/trial_durations.h"

#define FRAME_WORDS (320*240)
#define STRIP_WORDS (320*8)
static uint16_t *frame, *previous;
static player_ui_view_t drawn_view;

static void draw_task(void *arg)
{
    bool first = true;
    esp_err_t err = ESP_OK;
    uint32_t max_draw_us = 0, reported_input_ms = 0;
    unsigned updates = 0;
    uint32_t valid_strips = 0;
    bool backlight = true;
    while (err == ESP_OK) {
        int64_t cycle_start = esp_timer_get_time();
        player_ui_tick((uint32_t)(esp_timer_get_time()/1000));
        player_ui_update();
        if (player_ui_take_sleep_request()) player_power_sleep();
        /* Process controls even while buffering, but defer metadata and pixels.
         * The SD decoder gets the bus until at least half a PCM buffer is ready. */
        if(audio_player_needs_refill()){vTaskDelay(pdMS_TO_TICKS(20));continue;}
        player_ui_view_t view = player_ui_view();
        view.battery_mv = player_power_battery_mv();
        if (!ui_render_has_long_text(&view)) view.marquee_step = 0;
        if (backlight == view.display_asleep) {
            bench_display_backlight(!view.display_asleep);
            backlight = !view.display_asleep;
        }
        if (view.display_asleep) { vTaskDelay(pdMS_TO_TICKS(20)); continue; }
        /* Only elapsed whole seconds affect the pixels. Static menus must not
         * continually rasterize into PSRAM and delay physical input polling. */
        view.audio.consumed_frames = view.page == PLAYER_UI_NOW_PLAYING ?
            (view.audio.consumed_frames / 44100) * 44100 : 0;
        bool changed = first || memcmp(&view, &drawn_view, sizeof(view));
        const album_t *library = audio_player_library();
        album_track_t entry;
        unsigned duration=album_read_track(library,view.audio.track,&entry)?
            (entry.duration_seconds?entry.duration_seconds:trial_duration(entry.path)):0;
        int64_t start = esp_timer_get_time();
        if (changed && (first || !ui_render_selection(frame, &view, &drawn_view)))
            ui_render(frame, &view, duration);
        uint32_t render_us=(uint32_t)(esp_timer_get_time()-start);
        unsigned strips = 0;
        bool deferred = false;
        for (int y = 0; changed && y < 240 && err == ESP_OK; y += 8) {
            uint16_t *current = frame + y*320;
            uint16_t *old = previous + y*320;
            if ((valid_strips & (1u << (y/8))) && !memcmp(current, old, STRIP_WORDS*sizeof(*frame))) continue;
            if(audio_player_needs_refill()||player_ui_input_pending()){deferred=true;break;}
            err = bench_display_blit(0, y, 320, 8, current);
            if (err == ESP_OK) {memcpy(old, current, STRIP_WORDS*sizeof(*frame));valid_strips |= 1u << (y/8);}
            ++strips;
            /* Release the shared bus every eight rows (~2.6 ms at 16 MHz).
             * DMA blocks this task; no extra timed sleep is needed per strip. */
            taskYIELD();
        }
        uint32_t elapsed = (uint32_t)(esp_timer_get_time() - start);
        if (elapsed > max_draw_us) max_draw_us = elapsed;
        if (changed || ++updates % 250 == 0)
            ESP_LOGI("DISPLAY", "UI page=%u title=%s selection=%u/%u strips=%u max_draw_us=%"PRIu32" stack_free_min=%u",
                (unsigned)view.page, view.title, view.selected, view.total_count, strips,
                max_draw_us, (unsigned)uxTaskGetStackHighWaterMark(NULL));
        /* Keep the last completed view when interrupted. Force a full render
         * next time; previous[] still describes the pixels actually transmitted. */
        if(deferred)first=true;
        else {
            first=false;drawn_view=view;
            uint32_t input_ms=player_ui_last_input_ms();
            if(input_ms && input_ms!=reported_input_ms) {
                uint32_t latency_ms=(uint32_t)(esp_timer_get_time()/1000)-input_ms;
                ESP_LOGI("DISPLAY", "INPUT_COMPLETE latency_ms=%"PRIu32" update_us=%"PRIu32" draw_us=%"PRIu32" render_us=%"PRIu32" strips=%u page=%u",
                    latency_ms,(uint32_t)(esp_timer_get_time()-cycle_start),elapsed,render_us,strips,(unsigned)view.page);
                reported_input_ms=input_ms;
            }
        }
        /* Keep recovery/navigation usable even if the audio engine stopped. */
        vTaskDelay(pdMS_TO_TICKS(deferred ? 1 : 5));
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
    if (err != ESP_OK) err = bench_display_init_without_storage();
    if (err != ESP_OK) {
        ESP_LOGE("DISPLAY", "Initialization failed: %s", esp_err_to_name(err));
        return false;
    }
    frame = heap_caps_malloc(FRAME_WORDS*sizeof(*frame), MALLOC_CAP_SPIRAM|MALLOC_CAP_8BIT);
    previous = heap_caps_malloc(FRAME_WORDS*sizeof(*previous), MALLOC_CAP_SPIRAM|MALLOC_CAP_8BIT);
    if (!frame || !previous) { free(frame); free(previous); frame = previous = NULL; return false; }
    player_power_init();
    player_ui_init(); /* Before controls task starts producing input. */
    player_ui_enable_sleep(true);
    if (xTaskCreatePinnedToCore(draw_task, "player_display", 16384, NULL, 1, NULL, 0) != pdPASS) {
        free(frame); free(previous); frame = previous = NULL; return false;
    }
    return true;
}
