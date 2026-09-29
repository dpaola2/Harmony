#pragma once
#include <stdbool.h>
#include <stdint.h>
#include "album.h"
#define PLAYER_VOLUME_DEFAULT 40
#define PLAYER_VOLUME_START_MAX 40
/* Versioned device NVS only; never write music-card files. */
typedef struct {
    uint32_t version;
    unsigned volume, repeat, timeout_seconds;
    bool shuffle;
    char track_path[ALBUM_PATH_MAX];
} player_prefs_t;
void player_prefs_init(void);
player_prefs_t player_prefs_get(void);
void player_prefs_update(const player_prefs_t *prefs);
bool player_prefs_available(void);
