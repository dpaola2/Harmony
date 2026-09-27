#pragma once
#include <stdbool.h>
#include <stdint.h>
#include "audio_player.h"
#define PLAYER_UI_ROWS 6

typedef enum {
    PLAYER_UI_ROOT, PLAYER_UI_MUSIC, PLAYER_UI_ARTISTS, PLAYER_UI_ALBUMS,
    PLAYER_UI_SONGS, PLAYER_UI_NOW_PLAYING, PLAYER_UI_BLUETOOTH, PLAYER_UI_SETTINGS
} player_ui_page_t;
typedef enum {
    PLAYER_UI_SCROLL, PLAYER_UI_SELECT, PLAYER_UI_BACK, PLAYER_UI_PLAY_PAUSE,
    PLAYER_UI_PREVIOUS, PLAYER_UI_NEXT
} player_ui_input_t;
typedef struct {
    char label[ALBUM_TITLE_MAX], detail[ALBUM_TITLE_MAX];
    bool playing;
} player_ui_row_t;
typedef struct {
    player_ui_page_t page;
    char title[ALBUM_TITLE_MAX], subtitle[ALBUM_TITLE_MAX];
    player_ui_row_t rows[PLAYER_UI_ROWS];
    unsigned row_count, total_count, selected, first;
    char track_title[ALBUM_TITLE_MAX], track_artist[ALBUM_TITLE_MAX], track_album[ALBUM_TITLE_MAX];
    char notice[96];
    audio_player_snapshot_t audio;
    uint32_t revision;
} player_ui_view_t;
/* Init/update/view belong to the display task. Input is a single-producer,
 * bounded nonblocking queue used by the controls task. false means full. */
void player_ui_init(void);
bool player_ui_input(player_ui_input_t input, int delta);
void player_ui_update(void);
player_ui_view_t player_ui_view(void);
