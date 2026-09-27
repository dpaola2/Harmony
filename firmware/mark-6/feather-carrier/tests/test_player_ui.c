#include "player_ui.h"
#include <assert.h>
#include <limits.h>
#include <stdio.h>
#include <string.h>
static album_t library;
static audio_player_snapshot_t audio;
static unsigned played[ALBUM_MAX_TRACKS], played_count, played_start, calls;
const album_t *audio_player_library(void) { return &library; }
audio_player_snapshot_t audio_player_snapshot(void) { return audio; }
bool audio_player_play_queue(const unsigned *tracks, unsigned count, unsigned start)
{
    memcpy(played, tracks, count * sizeof(*tracks));
    played_count = count; played_start = start; ++calls;
    audio.track = tracks[start]; ++audio.generation;
    return true;
}
void audio_player_toggle_pause(void) { audio.paused = !audio.paused; }
void audio_player_step(int delta) { (void)delta; ++audio.generation; }
static player_ui_view_t action(player_ui_input_t input, int delta)
{
    assert(player_ui_input(input, delta)); player_ui_update(); return player_ui_view();
}
static player_ui_view_t select_item(void) { return action(PLAYER_UI_SELECT, 0); }
static player_ui_view_t back(void) { return action(PLAYER_UI_BACK, 0); }
static player_ui_view_t scroll(int delta) { return action(PLAYER_UI_SCROLL, delta); }
static void load(void)
{
    const char *paths[] = {
        "Artist A/Same Album/01-01 First.mp3",
        "Artist B/Same Album/01 Other artist.mp3",
        "Artist A/Same Album/01-02 Second.mp3",
        "Artist A/Other Album/01 Elsewhere.mp3",
        "Artist A/Same Album/03 Third.mp3",
        "Artist A/Same Album/04 Fourth.mp3",
        "Artist A/Same Album/05 Fifth.mp3",
        "Artist A/Same Album/06 Sixth.mp3",
        "Artist A/Same Album/07 Seventh.mp3",
        "Artist A/Same Album/08 Eighth.mp3",
        "Artist A/Same Album/09 1979.mp3",
    };
    library.count = sizeof(paths) / sizeof(*paths);
    for (unsigned i = 0; i < library.count; ++i) strcpy(library.tracks[i].path, paths[i]);
    audio.count = library.count;
    player_ui_init();
}
int main(void)
{
    const char *numeric_paths[] = {
        "Radiohead/In Rainbows/01 15 Step.mp3",
        "Creed/Human Clay/01-01 Are You Ready.mp3",
        "Artist/Album/1979.mp3",
        "Artist/Album/01. 15 Step.mp3",
        "Artist/Album/01_15 Step.mp3",
    };
    const char *numeric_titles[] = {"15 Step", "Are You Ready", "1979", "15 Step", "15 Step"};
    library.count = 1;
    for (unsigned i = 0; i < sizeof(numeric_paths) / sizeof(*numeric_paths); ++i) {
        strcpy(library.tracks[0].path, numeric_paths[i]);
        player_ui_init();
        assert(!strcmp(player_ui_view().track_title, numeric_titles[i]));
    }
    load();
    assert(player_ui_view().page == PLAYER_UI_ROOT);
    assert(back().page == PLAYER_UI_ROOT);
    assert(select_item().page == PLAYER_UI_MUSIC);
    assert(select_item().page == PLAYER_UI_ARTISTS);
    player_ui_view_t v = player_ui_view();
    assert(v.total_count == 2 && !strcmp(v.rows[0].label, "Artist A"));
    assert(audio.generation == 0); /* Browsing cannot affect decoding/playback. */
    v = select_item(); assert(v.page == PLAYER_UI_ALBUMS && v.total_count == 2);
    v = select_item(); assert(v.page == PLAYER_UI_SONGS && v.total_count == 9);
    assert(!strcmp(v.rows[0].label, "First"));
    assert(!strcmp(v.title, "Same Album") && !strcmp(v.subtitle, "Artist A"));
    v = scroll(INT_MAX); assert(v.selected == 8 && v.first == 3);
    assert(!strcmp(v.rows[5].label, "1979"));
    v = scroll(INT_MIN); assert(v.selected == 0 && v.first == 0);
    scroll(6);
    v = select_item(); assert(v.page == PLAYER_UI_NOW_PLAYING);
    assert(calls == 1 && played_count == 9 && played_start == 6);
    assert(played[0] == 0 && played[1] == 2 && played[8] == 10);
    assert(!strcmp(v.track_title, "Seventh") && !strcmp(v.subtitle, "Artist A"));
    assert(!strcmp(v.track_artist, "Artist A") && !strcmp(v.track_album, "Same Album"));
    v = scroll(1); assert(strstr(v.notice, "speaker"));
    select_item(); assert(audio.paused);
    action(PLAYER_UI_PLAY_PAUSE, 0); assert(!audio.paused);
    v = back(); assert(v.page == PLAYER_UI_SONGS && v.selected == 6 && v.first == 1);
    assert(v.rows[5].playing);
    back(); back(); scroll(1);
    v = select_item(); assert(v.total_count == 1 && !strcmp(v.subtitle, "Artist B"));
    v = select_item(); assert(v.total_count == 1 && !strcmp(v.rows[0].label, "Other artist"));
    assert(calls == 1); /* Browsing another album leaves the queue alone. */
    select_item(); assert(played_count == 1 && played[0] == 1);
    back(); back(); back(); back(); back();
    select_item(); scroll(1); v = select_item();
    assert(v.page == PLAYER_UI_ALBUMS && v.total_count == 3); /* Identical names, distinct artists. */
    for (unsigned i = 0; i < 31; ++i) assert(player_ui_input(PLAYER_UI_SCROLL, 1));
    assert(!player_ui_input(PLAYER_UI_BACK, 0));
    player_ui_update(); assert(player_ui_view().selected == 2);
    assert(player_ui_input(PLAYER_UI_BACK, 0)); player_ui_update();
    player_ui_init(); scroll(2); v = select_item();
    assert(v.page == PLAYER_UI_BLUETOOTH && strstr(v.notice, "SoundCore 2 only"));
    back(); scroll(1); v = select_item();
    assert(v.page == PLAYER_UI_SETTINGS && strstr(v.notice, "speaker buttons"));
    library.count = 0; player_ui_init(); select_item(); select_item();
    assert(player_ui_view().total_count == 0);
    assert(select_item().page == PLAYER_UI_ARTISTS);
    puts("PASS native UI: artist/album identity, numeric titles, noncontiguous queue, exact Back restoration, clamping, pause, browse independence, bounded events and empty library");
}
