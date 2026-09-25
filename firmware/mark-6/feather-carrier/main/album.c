#include "album.h"
#include <string.h>
#include <strings.h>

static bool valid_path(const char *s)
{
    size_t n = strlen(s);
    if (n < 5 || n >= ALBUM_PATH_MAX || s[0] == '/' ||
        strcasecmp(s + n - 4, ".mp3")) return false;
    const char *part = s;
    for (const char *p = s;; ++p) {
        unsigned char c = (unsigned char)*p;
        if (c == '\\' || c == ':' || (c && c < 32) || c == 127) return false;
        if (!c || c == '/') {
            size_t len = (size_t)(p - part);
            if (!len || (len == 1 && part[0] == '.') ||
                (len == 2 && part[0] == '.' && part[1] == '.')) return false;
            part = p + 1;
        }
        if (!c) return true;
    }
}

bool album_parse(FILE *file, album_t *album)
{
    memset(album, 0, sizeof(*album));
    char line[512];
    bool first = true;
    for (;;) {
        size_t n = 0;
        int c;
        while ((c = fgetc(file)) != EOF && c != '\n') {
            if (!c || n + 1 >= sizeof(line)) goto invalid;
            line[n++] = (char)c;
        }
        if (ferror(file)) goto invalid;
        if (c == EOF && !n) break;
        if (n && line[n-1] == '\r') --n;
        line[n] = 0;
        char *path = line;
        if (first && n >= 3 && !memcmp(path, "\xef\xbb\xbf", 3)) path += 3;
        first = false;
        if (!*path || *path == '#') continue;
        if (album->count == ALBUM_MAX_TRACKS || !valid_path(path)) goto invalid;
        album_track_t *t = &album->tracks[album->count++];
        strcpy(t->path, path);
        const char *base = strrchr(path, '/');
        base = base ? base + 1 : path;
        size_t title_len = strlen(base) - 4;
        if (title_len >= sizeof(t->title)) title_len = sizeof(t->title) - 1;
        /* The current bitmap font is ASCII. Keep the actual filename untouched. */
        for (size_t i = 0; i < title_len; ++i)
            t->title[i] = (unsigned char)base[i] < 127 ? base[i] : '?';
        t->title[title_len] = 0;
    }
    if (!ferror(file) && album->count) return true;
invalid:
    memset(album, 0, sizeof(*album));
    return false;
}
