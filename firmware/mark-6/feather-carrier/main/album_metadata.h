#pragma once
#include "album.h"
/* Set readable filename/folder fallbacks, preserving the exact file path. */
void album_track_fallback(album_track_t *track);
/* Read ID3v2.3/2.4, ID3v1 and Xing/VBRI duration. Returns false for malformed or
 * unsupported tags; any absent fields retain their fallback. Never rewrites SD. */
bool album_track_metadata(FILE *file, album_track_t *track);
