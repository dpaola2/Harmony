/* Player pages at 320 x 320, written as PPM (tests/verify.py turns them into
 * preview PNGs), and the SPI cost of common updates through the same
 * changed-region finder the display task uses. */
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "slab_render.h"
#include "slab_dirty.h"
#include "st7365p.h"

#define WORDS (SLAB_RENDER_W * SLAB_RENDER_H)
static const char *outdir;

static void save(const char *name, const uint16_t *f)
{
    if (!outdir) return;
    char path[512];
    snprintf(path, sizeof(path), "%s/%s.ppm", outdir, name);
    FILE *o = fopen(path, "wb");
    assert(o);
    fprintf(o, "P6\n%d %d\n255\n", SLAB_RENDER_W, SLAB_RENDER_H);
    for (int i = 0; i < WORDS; ++i) {
        unsigned c = f[i];
        unsigned char rgb[] = {(unsigned char)(((c >> 11) & 31) * 255 / 31), (unsigned char)(((c >> 5) & 63) * 255 / 63),
                               (unsigned char)((c & 31) * 255 / 31)};
        fwrite(rgb, 1, 3, o);
    }
    fclose(o);
}

/* Bytes the display task would send to go from a to b. */
static size_t update_bytes(const uint16_t *a, const uint16_t *b, unsigned *rects)
{
    slab_rect_t r[16];
    unsigned n = slab_dirty_rects(a, b, SLAB_RENDER_W, SLAB_RENDER_H, 8, r, 16);
    for (unsigned i = 0; i < n; ++i) {
        assert(r[i].x + r[i].w <= SLAB_RENDER_W && r[i].y + r[i].h <= SLAB_RENDER_H && r[i].w && r[i].h);
        /* Every changed pixel lies inside some rectangle. */
    }
    for (int y = 0; y < SLAB_RENDER_H; ++y)
        for (int x = 0; x < SLAB_RENDER_W; ++x) {
            if (a[y * SLAB_RENDER_W + x] == b[y * SLAB_RENDER_W + x]) continue;
            bool covered = false;
            for (unsigned i = 0; i < n && !covered; ++i)
                covered = x >= r[i].x && x < r[i].x + r[i].w && y >= r[i].y && y < r[i].y + r[i].h;
            assert(covered);
        }
    if (rects) *rects = n;
    return slab_rects_bytes(r, n, ST7365P_WINDOW_OVERHEAD);
}

static void report(const char *name, size_t bytes, unsigned rects)
{
    printf("BYTES %s %zu %u\n", name, bytes, rects);
}

static void songs(player_ui_view_t *v, unsigned first, unsigned selected)
{
    static const char *titles[] = {"15 Step", "Bodysnatchers", "Nude", "Weird Fishes - Arpeggi", "All I Need",
        "Faust Arp", "Reckoner", "House of Cards", "Jigsaw Falling into Place", "Videotape"};
    memset(v->rows, 0, sizeof(v->rows));
    v->page = PLAYER_UI_SONGS;
    strcpy(v->title, "In Rainbows"); strcpy(v->subtitle, "Radiohead");
    v->total_count = 10; v->first = first; v->selected = selected; v->row_count = 0;
    for (unsigned i = first; i < 10 && v->row_count < PLAYER_UI_ROWS; ++i) {
        player_ui_row_t *r = &v->rows[v->row_count++];
        strcpy(r->label, titles[i]); strcpy(r->detail, "Radiohead");
        r->playing = i == 3;
    }
}

int main(int argc, char **argv)
{
    outdir = argc > 1 ? argv[1] : NULL;
    uint16_t *a = calloc(WORDS, 2), *b = calloc(WORDS, 2), *black = calloc(WORDS, 2);
    assert(a && b && black);
    slab_status_t st = {.battery_valid = true, .battery_percent = 78, .usb = false};
    player_ui_view_t v;
    memset(&v, 0, sizeof(v));
    v.audio.connected = true; v.audio.volume = 40; v.audio.queue_count = 10; v.audio.queue_position = 3;
    v.audio.consumed_frames = 44100 * 72;
    strcpy(v.receiver, "SoundCore 2");

    /* Root menu. */
    v.page = PLAYER_UI_ROOT; strcpy(v.title, "Harmony"); strcpy(v.subtitle, "1,284 songs");
    const char *root[] = {"Music", "Now Playing", "Bluetooth", "Settings"};
    v.row_count = v.total_count = 4; v.selected = 0;
    for (int i = 0; i < 4; ++i) strcpy(v.rows[i].label, root[i]);
    slab_render(a, &v, 0, &st); save("player-home", a);
    /* Album song list: a step inside the visible rows. */
    songs(&v, 0, 2); slab_render(a, &v, 0, &st); save("player-songs", a);
    songs(&v, 0, 3); slab_render(b, &v, 0, &st);
    unsigned rects;
    size_t step = update_bytes(a, b, &rects); report("scroll_step_in_view", step, rects);
    /* A step that moves the visible rows. */
    songs(&v, 0, 5); slab_render(a, &v, 0, &st);
    songs(&v, 1, 6); slab_render(b, &v, 0, &st);
    size_t page = update_bytes(a, b, &rects); report("scroll_step_page_moves", page, rects);
    /* Now playing: the one-second tick and a volume step. */
    v.page = PLAYER_UI_NOW_PLAYING; strcpy(v.title, "Now Playing"); strcpy(v.subtitle, "Radiohead");
    strcpy(v.track_title, "Weird Fishes - Arpeggi"); strcpy(v.track_artist, "Radiohead"); strcpy(v.track_album, "In Rainbows");
    v.row_count = 0;
    slab_render(a, &v, 318, &st); save("player-now-playing", a);
    v.audio.consumed_frames += 44100; slab_render(b, &v, 318, &st);
    size_t tick = update_bytes(a, b, &rects); report("now_playing_second", tick, rects);
    v.audio.volume = 41; slab_render(a, &v, 318, &st);
    size_t vol = update_bytes(b, a, &rects); report("volume_step", vol, rects);
    /* Battery change, notice. */
    st.battery_percent = 77; slab_render(b, &v, 318, &st);
    report("battery_percent", update_bytes(a, b, &rects), rects);
    size_t full = update_bytes(black, b, &rects); report("full_frame", full, rects);
    /* A step inside the view repaints two 37-row list rows (band rounding adds up to 16 rows) and the counter. */
    assert(step <= (2 * 37 + 16) * 320 * 2 + 4000 && page <= full / 3 && tick < 8000 && vol < 4000);
    /* Settings page with a notice, USB power and long names. */
    memset(&v.rows, 0, sizeof(v.rows));
    v.page = PLAYER_UI_SETTINGS; strcpy(v.title, "Settings"); strcpy(v.subtitle, "Saved on this player");
    const char *set[][2] = {{"Shuffle", "Off"}, {"Repeat", "All"}, {"Display timeout", "60 seconds"}, {"Sleep", "Save and sleep"}};
    v.row_count = v.total_count = 4; v.first = 0; v.selected = 3;
    for (int i = 0; i < 4; ++i) { strcpy(v.rows[i].label, set[i][0]); strcpy(v.rows[i].detail, set[i][1]); }
    st.usb = true; st.battery_percent = 100;
    strcpy(v.notice, "Reconnecting to last selected receiver. Playback paused.");
    slab_render(a, &v, 0, &st); save("player-settings", a);
    v.notice[0] = 0;
    /* Every page with long text at every marquee step stays inside the frame (sanitizers). */
    for (unsigned pg = 0; pg <= PLAYER_UI_BT_FORGET; ++pg)
        for (unsigned m = 0; m < 140; m += 7) {
            v.page = pg; v.marquee_step = m; v.first = 60; v.selected = 63; v.total_count = 64; v.row_count = PLAYER_UI_ROWS;
            for (int i = 0; i < PLAYER_UI_ROWS; ++i) {
                memset(v.rows[i].label, 'W', sizeof(v.rows[i].label) - 1); v.rows[i].label[sizeof(v.rows[i].label) - 1] = 0;
                strcpy(v.rows[i].detail, "UTF-8: caf\xc3\xa9");
            }
            memset(v.track_title, 'M', sizeof(v.track_title) - 1); v.track_title[sizeof(v.track_title) - 1] = 0;
            strcpy(v.notice, "Cannot connect. Choose another receiver or try again.");
            st.battery_percent = m; v.audio.volume = m;
            slab_render(a, &v, m % 2 ? 1 : 0, &st);
        }
    assert(slab_render_has_long_text(&v));
    slab_render(a, &v, 0, NULL);   /* no status: no battery drawn, no crash */
    free(a); free(b); free(black);
    puts("PASS player render 320x320: home, songs, now playing, settings; long text and marquee bounds; update sizes");
    return 0;
}
