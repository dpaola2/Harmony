#pragma once
#include <stdbool.h>
#include <stdint.h>
#include "album.h"
bool audio_player_prepare(void);
int32_t audio_player_read(uint8_t *data, int32_t len);
bool audio_player_finished(void);
void audio_player_stop(void);
void audio_player_log(void);
void audio_player_connected(bool connected);
void audio_player_browse(int delta);
void audio_player_step(int delta);
void audio_player_activate(void);
/* Loaded once before UI startup; immutable for the lifetime of the player. */
const album_t *audio_player_library(void);
bool audio_player_play_queue(const unsigned *tracks, unsigned count, unsigned start);
void audio_player_toggle_pause(void);
typedef struct {
    uint32_t consumed_frames, generation;
    unsigned track, selection, count, queue_position, queue_count;
    bool finished, stopped, failed, paused, connected, buffering;
    char title[ALBUM_TITLE_MAX], selected_title[ALBUM_TITLE_MAX];
} audio_player_snapshot_t;
audio_player_snapshot_t audio_player_snapshot(void);
