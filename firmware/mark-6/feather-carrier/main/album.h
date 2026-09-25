#pragma once
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#define ALBUM_MAX_TRACKS 64
#define ALBUM_PATH_MAX 192
#define ALBUM_TITLE_MAX 64
typedef struct {
    char path[ALBUM_PATH_MAX], title[ALBUM_TITLE_MAX];
} album_track_t;
typedef struct { unsigned count; album_track_t tracks[ALBUM_MAX_TRACKS]; } album_t;
/* Ordered UTF-8 M3U: relative MP3 paths under HARMONY; comments ignored.
 * Reject partial/empty/oversized playlists, traversal, absolute and URL paths. */
bool album_parse(FILE *file, album_t *album);
