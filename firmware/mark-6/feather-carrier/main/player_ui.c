/* UI state is owned by one task. Input crosses tasks only through this SPSC
 * queue; audio never calls back into UI and its lock is never held here. */
#include "player_ui.h"
#include <stdatomic.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#define EVENT_COUNT 32
#define STACK_DEPTH 8
#define ALL_ARTISTS ALBUM_MAX_TRACKS
typedef struct { player_ui_input_t input; int delta; } event_t;
typedef struct {
    const char *artist, *album;
    size_t artist_len, album_len;
    char title[ALBUM_TITLE_MAX];
} metadata_t;
typedef struct {
    player_ui_page_t page;
    unsigned selected, first, artist, album;
} screen_t;
static const album_t *library;
static metadata_t metadata[ALBUM_MAX_TRACKS];
static screen_t screens[STACK_DEPTH];
static unsigned depth;
static uint32_t revision;
static event_t events[EVENT_COUNT];
static atomic_uint event_read, event_write;
static char notice[96];

static void text(char *dst, size_t size, const char *src, size_t len)
{
    if (len >= size) len = size - 1;
    memcpy(dst, src, len);
    dst[len] = '\0';
}
static void parse_metadata(unsigned i)
{
    const char *path = library->tracks[i].path;
    const char *first = strchr(path, '/');
    const char *second = first ? strchr(first + 1, '/') : NULL;
    metadata_t *m = &metadata[i];
    m->artist = second ? path : "Unknown Artist";
    m->artist_len = second ? (size_t)(first - path) : strlen(m->artist);
    m->album = second ? first + 1 : "Unknown Album";
    m->album_len = second ? (size_t)(second - first - 1) : strlen(m->album);
    const char *name = strrchr(path, '/');
    name = name ? name + 1 : path;
    const char *title = name;
    /* Strip a numeric track/disc prefix only when separated from the title. */
    if (isdigit((unsigned char)*name)) {
        const char *p = name;
        while (isdigit((unsigned char)*p)) ++p;
        if (*p == '-' && isdigit((unsigned char)p[1])) {
            ++p;
            while (isdigit((unsigned char)*p)) ++p;
        }
        if (*p == '.' && isspace((unsigned char)p[1])) ++p;
        if (isspace((unsigned char)*p) || *p == '_') {
            while (isspace((unsigned char)*p) || *p == '_') ++p;
            if (*p) title = p;
        }
    }
    const char *dot = strrchr(title, '.');
    text(m->title, sizeof(m->title), title, dot ? (size_t)(dot - title) : strlen(title));
}
static bool same_artist(unsigned a, unsigned b)
{
    return metadata[a].artist_len == metadata[b].artist_len &&
        !memcmp(metadata[a].artist, metadata[b].artist, metadata[a].artist_len);
}
static bool same_album(unsigned a, unsigned b)
{
    return same_artist(a, b) && metadata[a].album_len == metadata[b].album_len &&
        !memcmp(metadata[a].album, metadata[b].album, metadata[a].album_len);
}
/* IDs always refer to immutable global tracks. Album/artist IDs are the first
 * representative in playlist order, so equal album names stay artist-scoped. */
static unsigned items(const screen_t *s, unsigned *ids)
{
    unsigned count = 0;
    if (!library) return 0;
    for (unsigned i = 0; i < library->count; ++i) {
        if (s->page == PLAYER_UI_SONGS) {
            if (same_album(i, s->album)) ids[count++] = i;
            continue;
        }
        if (s->page == PLAYER_UI_ALBUMS && s->artist != ALL_ARTISTS && !same_artist(i, s->artist)) continue;
        bool duplicate = false;
        for (unsigned j = 0; j < count; ++j) {
            if (s->page == PLAYER_UI_ARTISTS ? same_artist(i, ids[j]) : same_album(i, ids[j])) {
                duplicate = true;
                break;
            }
        }
        if (!duplicate) ids[count++] = i;
    }
    return count;
}
static unsigned screen_count(const screen_t *s)
{
    if (s->page == PLAYER_UI_ROOT) return 4;
    if (s->page == PLAYER_UI_MUSIC) return 2;
    if (s->page == PLAYER_UI_BLUETOOTH || s->page == PLAYER_UI_SETTINGS || s->page == PLAYER_UI_NOW_PLAYING) return 0;
    unsigned ids[ALBUM_MAX_TRACKS];
    return items(s, ids);
}
static void push(player_ui_page_t page, unsigned artist, unsigned album)
{
    if (depth + 1 >= STACK_DEPTH) return;
    screens[++depth] = (screen_t){.page = page, .artist = artist, .album = album};
}
void player_ui_init(void)
{
    library = audio_player_library();
    if (library && library->count > ALBUM_MAX_TRACKS) library = NULL;
    if (library) for (unsigned i = 0; i < library->count; ++i) parse_metadata(i);
    depth = 0;
    screens[0] = (screen_t){.page = PLAYER_UI_ROOT};
    notice[0] = 0;
    revision = 1;
    atomic_store(&event_read, 0);
    atomic_store(&event_write, 0);
}
bool player_ui_input(player_ui_input_t input, int delta)
{
    if (input < PLAYER_UI_SCROLL || input > PLAYER_UI_NEXT) return false;
    unsigned w = atomic_load_explicit(&event_write, memory_order_relaxed);
    unsigned next = (w + 1) % EVENT_COUNT;
    if (next == atomic_load_explicit(&event_read, memory_order_acquire)) return false;
    events[w] = (event_t){input, delta};
    atomic_store_explicit(&event_write, next, memory_order_release);
    return true;
}
static void handle(event_t event)
{
    screen_t *s = &screens[depth];
    notice[0] = 0;
    ++revision;
    if (event.input == PLAYER_UI_BACK) { if (depth) --depth; return; }
    if (event.input == PLAYER_UI_PLAY_PAUSE) { audio_player_toggle_pause(); return; }
    if (event.input == PLAYER_UI_PREVIOUS || event.input == PLAYER_UI_NEXT) {
        audio_player_step(event.input == PLAYER_UI_NEXT ? 1 : -1); return;
    }
    if (event.input == PLAYER_UI_SCROLL) {
        if (s->page == PLAYER_UI_NOW_PLAYING) {
            snprintf(notice, sizeof(notice), "Volume uses speaker buttons");
            return;
        }
        unsigned count = screen_count(s);
        int64_t next = (int64_t)s->selected + event.delta;
        s->selected = next < 0 ? 0 : (next >= count ? (count ? count - 1 : 0) : (unsigned)next);
        if (s->selected < s->first) s->first = s->selected;
        if (s->selected >= s->first + PLAYER_UI_ROWS) s->first = s->selected - PLAYER_UI_ROWS + 1;
        return;
    }
    if (event.input != PLAYER_UI_SELECT) return;
    switch (s->page) {
    case PLAYER_UI_ROOT: {
        const player_ui_page_t pages[] = {PLAYER_UI_MUSIC, PLAYER_UI_NOW_PLAYING, PLAYER_UI_BLUETOOTH, PLAYER_UI_SETTINGS};
        push(pages[s->selected], ALL_ARTISTS, 0);
        break;
    }
    case PLAYER_UI_MUSIC:
        push(s->selected ? PLAYER_UI_ALBUMS : PLAYER_UI_ARTISTS, ALL_ARTISTS, 0);
        break;
    case PLAYER_UI_ARTISTS: case PLAYER_UI_ALBUMS: case PLAYER_UI_SONGS: {
        unsigned ids[ALBUM_MAX_TRACKS], count = items(s, ids);
        if (!count) break;
        if (s->page == PLAYER_UI_ARTISTS) push(PLAYER_UI_ALBUMS, ids[s->selected], 0);
        else if (s->page == PLAYER_UI_ALBUMS) push(PLAYER_UI_SONGS, s->artist, ids[s->selected]);
        else if (audio_player_play_queue(ids, count, s->selected)) push(PLAYER_UI_NOW_PLAYING, s->artist, s->album);
        break;
    }
    case PLAYER_UI_NOW_PLAYING: audio_player_toggle_pause(); break;
    default: break;
    }
}
void player_ui_update(void)
{
    unsigned r = atomic_load_explicit(&event_read, memory_order_relaxed);
    while (r != atomic_load_explicit(&event_write, memory_order_acquire)) {
        event_t event = events[r];
        r = (r + 1) % EVENT_COUNT;
        atomic_store_explicit(&event_read, r, memory_order_release);
        handle(event);
    }
}
player_ui_view_t player_ui_view(void)
{
    player_ui_view_t v = {0};
    const screen_t *s = &screens[depth];
    v.page = s->page;
    v.first = s->first;
    v.selected = s->selected;
    v.total_count = screen_count(s);
    v.revision = revision;
    v.audio = audio_player_snapshot();
    snprintf(v.notice, sizeof(v.notice), "%s", notice);
    if (library && v.audio.track < library->count) {
        const metadata_t *m = &metadata[v.audio.track];
        snprintf(v.track_title, sizeof(v.track_title), "%s", m->title);
        text(v.track_artist, sizeof(v.track_artist), m->artist, m->artist_len);
        text(v.track_album, sizeof(v.track_album), m->album, m->album_len);
    }
    const char *titles[] = {"Harmony", "Music", "Artists", "Albums", "Songs", "Now Playing", "Bluetooth", "Settings"};
    snprintf(v.title, sizeof(v.title), "%s", titles[s->page]);
    if (s->page == PLAYER_UI_ALBUMS && s->artist != ALL_ARTISTS)
        text(v.subtitle, sizeof(v.subtitle), metadata[s->artist].artist, metadata[s->artist].artist_len);
    else if (s->page == PLAYER_UI_SONGS) {
        text(v.title, sizeof(v.title), metadata[s->album].album, metadata[s->album].album_len);
        text(v.subtitle, sizeof(v.subtitle), metadata[s->album].artist, metadata[s->album].artist_len);
    } else if (s->page == PLAYER_UI_NOW_PLAYING) snprintf(v.subtitle, sizeof(v.subtitle), "%s", v.track_artist);
    else if (s->page == PLAYER_UI_BLUETOOTH) {
        snprintf(v.subtitle, sizeof(v.subtitle), "SoundCore 2");
        snprintf(v.notice, sizeof(v.notice), "Device selection comes next; SoundCore 2 only.");
    } else if (s->page == PLAYER_UI_SETTINGS) {
        snprintf(v.subtitle, sizeof(v.subtitle), "Quiet level: -24 dB");
        snprintf(v.notice, sizeof(v.notice), "Volume uses speaker buttons in this version.");
    }
    else snprintf(v.subtitle, sizeof(v.subtitle), "%u songs", library ? library->count : 0);
    unsigned ids[ALBUM_MAX_TRACKS];
    if (s->page == PLAYER_UI_ARTISTS || s->page == PLAYER_UI_ALBUMS || s->page == PLAYER_UI_SONGS) items(s, ids);
    for (unsigned i = s->first; i < v.total_count && v.row_count < PLAYER_UI_ROWS; ++i) {
        player_ui_row_t *row = &v.rows[v.row_count++];
        if (s->page == PLAYER_UI_ROOT) {
            const char *labels[] = {"Music", "Now Playing", "Bluetooth", "Settings"};
            snprintf(row->label, sizeof(row->label), "%s", labels[i]);
        } else if (s->page == PLAYER_UI_MUSIC) {
            snprintf(row->label, sizeof(row->label), "%s", i ? "Albums" : "Artists");
        } else {
            unsigned id = ids[i];
            const metadata_t *m = &metadata[id];
            if (s->page == PLAYER_UI_ARTISTS) text(row->label, sizeof(row->label), m->artist, m->artist_len);
            else if (s->page == PLAYER_UI_ALBUMS) {
                text(row->label, sizeof(row->label), m->album, m->album_len);
                text(row->detail, sizeof(row->detail), m->artist, m->artist_len);
            } else {
                snprintf(row->label, sizeof(row->label), "%s", m->title);
                row->playing = id == v.audio.track;
            }
        }
    }
    return v;
}
