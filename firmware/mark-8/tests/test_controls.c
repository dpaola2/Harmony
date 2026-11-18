/* Wheel and side-button mapping, then through the real Mark-6 player UI
 * (player_ui.c with the Mark-7 test's audio and Bluetooth stand-ins). */
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "controls_map.h"
#include "player_ui.h"
#include "player_prefs.h"
#include "player_bluetooth.h"
#include "album_metadata.h"

static album_t library;
static audio_player_snapshot_t audio;
static int stepped;
const album_t *audio_player_library(void) { return &library; }
audio_player_snapshot_t audio_player_snapshot(void) { return audio; }
bool audio_player_play_queue(const unsigned *tracks, unsigned count, unsigned start)
{ (void)count; audio.track = tracks[start]; ++audio.generation; audio.paused = false; return true; }
void audio_player_toggle_pause(void) { audio.paused = !audio.paused; }
void audio_player_set_paused(bool paused) { audio.paused = paused; }
void audio_player_step(int delta) { stepped += delta; ++audio.generation; }
void audio_player_set_volume(unsigned n) { audio.volume = n > 100 ? 100 : n; }
unsigned audio_player_volume(void) { return audio.volume; }
void audio_player_set_modes(bool shuffle, unsigned repeat) { audio.shuffle = shuffle; audio.repeat = repeat; }
bool player_bluetooth_snapshot(player_bt_snapshot_t *out) { memset(out, 0, sizeof(*out)); return true; }
bool player_bluetooth_command(player_bt_command_t c, const uint8_t a[6]) { (void)c; (void)a; return true; }

static player_ui_view_t feed(const wheel_events_t *ev)
{
    controls_action_t a[CONTROLS_MAX_ACTIONS];
    unsigned n = controls_map_wheel(ev, a, CONTROLS_MAX_ACTIONS);
    for (unsigned i = 0; i < n; ++i) assert(player_ui_input(a[i].input, a[i].delta));
    player_ui_update();
    return player_ui_view();
}
static wheel_events_t tap(wheel_zone_t z) { return (wheel_events_t){.tap = z, .hold = WHEEL_ZONE_NONE}; }
static wheel_events_t hold(wheel_zone_t z) { return (wheel_events_t){.tap = WHEEL_ZONE_NONE, .hold = z}; }
static wheel_events_t scroll(int s) { return (wheel_events_t){.steps = s, .tap = WHEEL_ZONE_NONE, .hold = WHEEL_ZONE_NONE}; }

int main(void)
{
    controls_action_t a[CONTROLS_MAX_ACTIONS];
    wheel_events_t e = scroll(3);
    assert(controls_map_wheel(&e, a, 10) == 1 && a[0].input == PLAYER_UI_SCROLL && a[0].delta == 3);
    e = scroll(-2);
    assert(controls_map_wheel(&e, a, 10) == 1 && a[0].delta == -2);
    const struct { wheel_zone_t z; player_ui_input_t in; } map[] = {
        {WHEEL_ZONE_CENTRE, PLAYER_UI_SELECT}, {WHEEL_ZONE_HOME, PLAYER_UI_BACK}, {WHEEL_ZONE_NEXT, PLAYER_UI_NEXT},
        {WHEEL_ZONE_PREVIOUS, PLAYER_UI_PREVIOUS}, {WHEEL_ZONE_PLAY, PLAYER_UI_PLAY_PAUSE}};
    for (unsigned i = 0; i < 5; ++i) { e = tap(map[i].z); assert(controls_map_wheel(&e, a, 10) == 1 && a[0].input == map[i].in); }
    e = tap(WHEEL_ZONE_NONE);
    assert(controls_map_wheel(&e, a, 10) == 0);
    e = hold(WHEEL_ZONE_HOME);
    assert(controls_map_wheel(&e, a, 10) == CONTROLS_ROOT_BACKS);
    for (unsigned i = 0; i < CONTROLS_ROOT_BACKS; ++i) assert(a[i].input == PLAYER_UI_BACK);
    assert(controls_map_wheel(&e, a, 3) == 3);
    e = hold(WHEEL_ZONE_CENTRE);
    assert(controls_map_wheel(&e, a, 10) == 0);
    assert(controls_map_side_short(200, 1500, &a[0]) && a[0].input == PLAYER_UI_PLAY_PAUSE);
    assert(!controls_map_side_short(1500, 1500, &a[0]) && !controls_map_side_short(10, 1500, &a[0]));

    /* Through the real player UI. */
    const char *paths[] = {"Artist A/Album/01 One.mp3", "Artist A/Album/02 Two.mp3", "Artist A/Album/03 Three.mp3",
                           "Artist B/Other/01 Elsewhere.mp3"};
    library.count = 4;
    for (unsigned i = 0; i < 4; ++i) { strcpy(library.tracks[i].path, paths[i]); album_track_fallback(&library.tracks[i]); }
    player_prefs_init();
    player_prefs_t p = {.version = 1, .volume = 40};
    player_prefs_update(&p);
    audio.volume = 40;
    player_ui_init();
    player_ui_view_t v = player_ui_view();
    assert(v.page == PLAYER_UI_ROOT);
    v = feed(&(wheel_events_t){.tap = WHEEL_ZONE_CENTRE, .hold = WHEEL_ZONE_NONE});
    assert(v.page == PLAYER_UI_MUSIC);
    e = tap(WHEEL_ZONE_CENTRE); v = feed(&e); assert(v.page == PLAYER_UI_ARTISTS);
    e = tap(WHEEL_ZONE_CENTRE); v = feed(&e); assert(v.page == PLAYER_UI_ALBUMS);
    e = tap(WHEEL_ZONE_CENTRE); v = feed(&e); assert(v.page == PLAYER_UI_SONGS && v.total_count == 3);
    e = scroll(1); v = feed(&e); assert(v.selected == 1);
    e = scroll(-5); v = feed(&e); assert(v.selected == 0);
    e = scroll(2); v = feed(&e);
    e = tap(WHEEL_ZONE_CENTRE); v = feed(&e); assert(v.page == PLAYER_UI_NOW_PLAYING && audio.track == 2 && !audio.paused);
    e = scroll(5); v = feed(&e); assert(audio.volume == 45);           /* the wheel is volume here */
    e = tap(WHEEL_ZONE_PLAY); feed(&e); assert(audio.paused);
    e = tap(WHEEL_ZONE_CENTRE); feed(&e); assert(!audio.paused);
    e = tap(WHEEL_ZONE_NEXT); feed(&e); assert(stepped == 1);
    e = tap(WHEEL_ZONE_PREVIOUS); feed(&e); assert(stepped == 0);
    e = tap(WHEEL_ZONE_HOME); v = feed(&e); assert(v.page == PLAYER_UI_SONGS);   /* HOME tap: one level back */
    e = hold(WHEEL_ZONE_HOME); v = feed(&e); assert(v.page == PLAYER_UI_ROOT);   /* HOME hold: all the way */
    e = hold(WHEEL_ZONE_HOME); v = feed(&e); assert(v.page == PLAYER_UI_ROOT);
    puts("PASS controls: wheel zones and steps to Mark-7 events, HOME tap back, HOME hold to root, side button; "
         "through the real player UI");
    return 0;
}
