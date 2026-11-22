/* Mark-8 copy of firmware/mark-7/pocket-player/main/player_display.c (October
 * 9 working tree), changed for the slab: 320 x 320 frames, the ST7365P on its
 * own bus, changed regions only (slab_dirty), MAX17048 percent, VSYS-adjusted
 * backlight, and deep sleep on idle or on a long side-button press.
 *
 * Priorities: this task runs at 1 on core 0. The MP3 decoder (5, core 1),
 * the Bluetooth worker (5) and the Bluedroid and controller tasks (higher)
 * all preempt it, and the wheel task (6) does too. */
#include <inttypes.h>
#include <stdio.h>
#include <string.h>
#include "sdkconfig.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_heap_caps.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "audio_player.h"
#include "player_display.h"
#include "player_ui.h"
#include "player_power.h"
#include "slab_controls.h"
#include "slab_render.h"
#include "slab_dirty.h"
#include "st7365p.h"
#include "ui_assets/trial_durations.h"

#ifndef CONFIG_SLAB_IDLE_SLEEP_MIN
#define CONFIG_SLAB_IDLE_SLEEP_MIN 10
#endif
#define FRAME_WORDS (SLAB_RENDER_W * SLAB_RENDER_H)
#define BAND 8
#define MAX_RECTS 16
static uint16_t *frame, *previous;
static player_ui_view_t drawn_view;
static slab_status_t drawn_status;

static bool idle_too_long(const player_ui_view_t *view)
{
    static uint32_t last_attempt;
    if (!CONFIG_SLAB_IDLE_SLEEP_MIN) return false;
    const audio_player_snapshot_t *a = &view->audio;
    bool playing = a->connected && !a->paused && !a->stopped && !a->finished && !a->failed;
    uint32_t now = (uint32_t)(esp_timer_get_time() / 1000);
    if (playing || now - slab_controls_last_activity_ms() < CONFIG_SLAB_IDLE_SLEEP_MIN * 60000u) return false;
    /* A refused sleep (a notice says why) is retried once a minute, not every frame. */
    if (last_attempt && now - last_attempt < 60000u) return false;
    last_attempt = now;
    return true;
}

static void draw_task(void *arg)
{
    bool first = true;
    esp_err_t err = ESP_OK;
    uint32_t max_draw_us = 0, reported_input_ms = 0, last_power_ms = 0;
    unsigned updates = 0;
    bool backlight = false;
    while (err == ESP_OK) {
        int64_t cycle_start = esp_timer_get_time();
        uint32_t now_ms = (uint32_t)(cycle_start / 1000);
        player_ui_tick(now_ms);
        player_ui_update();
        if (now_ms - last_power_ms >= 1000) { player_power_poll(); last_power_ms = now_ms; }
        if (player_ui_take_sleep_request() || slab_controls_take_sleep_request() || player_power_take_battery_empty())
            player_power_sleep();
        /* Library reads share the card bus with the decoder: let it refill first. */
        if (audio_player_needs_refill()) { vTaskDelay(pdMS_TO_TICKS(20)); continue; }
        player_ui_view_t view = player_ui_view();
        if (idle_too_long(&view)) { ESP_LOGI("DISPLAY", "Idle: deep sleep"); player_power_sleep(); }
        player_power_status_t power = player_power_status();
        slab_status_t st = {.battery_valid = power.valid, .battery_percent = power.percent, .usb = power.usb};
        view.battery_mv = power.vcell_mv;
        if (!slab_render_has_long_text(&view)) view.marquee_step = 0;
        if (backlight == view.display_asleep) {
            player_power_backlight(!view.display_asleep);
            backlight = !view.display_asleep;
        }
        if (view.display_asleep) { vTaskDelay(pdMS_TO_TICKS(20)); continue; }
        /* Only elapsed whole seconds change the pixels. */
        view.audio.consumed_frames = view.page == PLAYER_UI_NOW_PLAYING ?
            (view.audio.consumed_frames / 44100) * 44100 : 0;
        bool changed = first || memcmp(&view, &drawn_view, sizeof(view)) || memcmp(&st, &drawn_status, sizeof(st));
        const album_t *library = audio_player_library();
        album_track_t entry;
        unsigned duration = album_read_track(library, view.audio.track, &entry) ?
            (entry.duration_seconds ? entry.duration_seconds : trial_duration(entry.path)) : 0;
        int64_t start = esp_timer_get_time();
        if (changed) slab_render(frame, &view, duration, &st);
        uint32_t render_us = (uint32_t)(esp_timer_get_time() - start);
        slab_rect_t rects[MAX_RECTS];
        unsigned n = changed ? slab_dirty_rects(previous, frame, SLAB_RENDER_W, SLAB_RENDER_H, BAND, rects, MAX_RECTS) : 0;
        unsigned sent = 0;
        bool deferred = false;
        uint32_t bytes0 = st7365p_bytes_sent();
        for (unsigned i = 0; i < n && err == ESP_OK; ++i) {
            /* New input wins over finishing this frame; the next pass redraws from previous[]. */
            if (player_ui_input_pending()) { deferred = true; break; }
            const slab_rect_t *r = &rects[i];
            err = st7365p_blit(r->x, r->y, r->w, r->h, frame + (size_t)r->y * SLAB_RENDER_W + r->x, SLAB_RENDER_W);
            if (err == ESP_OK) { slab_rect_copy(previous, frame, SLAB_RENDER_W, r); ++sent; }
            taskYIELD();
        }
        uint32_t elapsed = (uint32_t)(esp_timer_get_time() - start);
        if (elapsed > max_draw_us) max_draw_us = elapsed;
        if (changed || ++updates % 250 == 0)
            ESP_LOGI("DISPLAY", "UI page=%u title=%s selection=%u/%u rects=%u/%u bytes=%" PRIu32 " max_draw_us=%" PRIu32 " stack_free_min=%u",
                (unsigned)view.page, view.title, view.selected, view.total_count, sent, n,
                st7365p_bytes_sent() - bytes0, max_draw_us, (unsigned)uxTaskGetStackHighWaterMark(NULL));
        if (deferred) first = true;
        else if (changed) {
            first = false; drawn_view = view; drawn_status = st;
            uint32_t input_ms = player_ui_last_input_ms();
            if (input_ms && input_ms != reported_input_ms) {
                uint32_t latency_ms = (uint32_t)(esp_timer_get_time() / 1000) - input_ms;
                ESP_LOGI("DISPLAY", "INPUT_COMPLETE latency_ms=%" PRIu32 " update_us=%" PRIu32 " draw_us=%" PRIu32 " render_us=%" PRIu32 " rects=%u page=%u",
                    latency_ms, (uint32_t)(esp_timer_get_time() - cycle_start), elapsed, render_us, sent, (unsigned)view.page);
                reported_input_ms = input_ms;
            }
        }
        vTaskDelay(pdMS_TO_TICKS(deferred ? 1 : 5));
    }
    audio_player_stop();
    ESP_LOGE("DISPLAY", "Drawing failed; playback stopped: %s", esp_err_to_name(err));
    free(frame); free(previous); frame = previous = NULL;
    vTaskDelete(NULL);
}

bool player_display_start(void)
{
    st7365p_config_t cfg;
    st7365p_default_config(&cfg);
    esp_err_t err = st7365p_init(&cfg);
    if (err != ESP_OK) {
        ESP_LOGE("DISPLAY", "Initialization failed: %s", esp_err_to_name(err));
        return false;
    }
    /* previous[] mirrors the panel, which st7365p_init filled black. */
    frame = heap_caps_calloc(FRAME_WORDS, sizeof(*frame), MALLOC_CAP_SPIRAM | MALLOC_CAP_8BIT);
    previous = heap_caps_calloc(FRAME_WORDS, sizeof(*previous), MALLOC_CAP_SPIRAM | MALLOC_CAP_8BIT);
    if (!frame || !previous) { free(frame); free(previous); frame = previous = NULL; return false; }
    player_ui_init();   /* before the controls start producing input */
    player_ui_enable_sleep(true);
    if (xTaskCreatePinnedToCore(draw_task, "player_display", 16384, NULL, 1, NULL, 0) != pdPASS) {
        free(frame); free(previous); frame = previous = NULL; return false;
    }
    return true;
}
