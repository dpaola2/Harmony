#pragma once
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#define ALBUM_MAX_TRACKS 512
#define ALBUM_PATH_MAX 192
#define ALBUM_TITLE_MAX 128
#define ALBUM_ARTIST_MAX 96
#define ALBUM_NAME_MAX 96
#define ALBUM_MAX_PLAYLISTS 16

typedef enum {
    ALBUM_STATUS_OK = 0, ALBUM_STATUS_MISSING, ALBUM_STATUS_EMPTY,
    ALBUM_STATUS_IO_ERROR, ALBUM_STATUS_CAPACITY, ALBUM_STATUS_INVALID_PLAYLIST,
    ALBUM_STATUS_PATH_TOO_LONG, ALBUM_STATUS_TOO_DEEP
} album_status_t;
typedef struct {
    char path[ALBUM_PATH_MAX], title[ALBUM_TITLE_MAX];
    char artist[ALBUM_ARTIST_MAX], album[ALBUM_NAME_MAX];
    uint16_t disc_number, track_number;
    uint32_t duration_seconds;
} album_track_t;
typedef struct {
    char name[ALBUM_NAME_MAX];
    unsigned count;
    uint16_t track_indices[ALBUM_MAX_TRACKS];
} album_playlist_t;
typedef struct {
    unsigned count;
    album_track_t tracks[ALBUM_MAX_TRACKS];
    unsigned playlist_count;
    album_playlist_t playlists[ALBUM_MAX_PLAYLISTS];
    album_status_t status;
    unsigned skipped_files, metadata_warnings;
} album_t;
/* Ordered UTF-8 M3U: relative MP3 paths under HARMONY; comments ignored.
 * Reject partial/empty/oversized playlists, traversal, absolute and URL paths.
 * The large output object belongs in PSRAM, never on a task stack. */
bool album_parse(FILE *file, album_t *album);
/* Read-only recursive index. root is /sd/HARMONY on device. On failure count and
 * playlist_count are zero; status explains why. No partial library is exposed.
 * Entries are sorted by artist, album, disc, track and path. M3U entries retain
 * their listed order and resolve relative to the playlist's own directory.
 * Supports 512 tracks, 16 playlists, 512 entries/playlist, eight directory levels.
 * Unsupported files are counted; damaged/unsupported tags use path fallbacks. */
bool album_load(const char *root, album_t *album);
const char *album_status_text(album_status_t status);
