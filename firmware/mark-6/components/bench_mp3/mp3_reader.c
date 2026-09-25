#include <string.h>
#include "mp3_reader.h"

int mp3_reader_open(mp3_reader_t *r, const char *path)
{
    memset(r, 0, sizeof(*r));
    r->file = fopen(path, "rb");
    if (!r->file) return -1;
    unsigned char header[10];
    if (fread(header, 1, 10, r->file) != 10) goto fail;
    long offset = 0;
    if (!memcmp(header, "ID3", 3)) {
        if ((header[6] | header[7] | header[8] | header[9]) & 0x80) goto fail;
        offset = 10 + ((long)header[6] << 21) + ((long)header[7] << 14)
                 + ((long)header[8] << 7) + header[9];
        if (header[3] == 4 && (header[5] & 0x10)) offset += 10;
    }
    if (fseek(r->file, 0, SEEK_END)) goto fail;
    long size = ftell(r->file);
    if (size < 0 || offset >= size || fseek(r->file, offset, SEEK_SET)) goto fail;
    mp3dec_init(&r->decoder);
    return 0;
fail:
    mp3_reader_close(r);
    return -1;
}

int mp3_reader_next(mp3_reader_t *r, int16_t pcm[MINIMP3_MAX_SAMPLES_PER_FRAME])
{
    if (!r->file) return -1;
    for (;;) {
        if (r->available < 8192 && !r->eof) {
            memmove(r->input, r->input + r->offset, r->available);
            r->offset = 0;
            size_t n = fread(r->input + r->available, 1,
                             sizeof(r->input) - r->available, r->file);
            if (ferror(r->file)) return -1;
            r->available += n;
            r->eof = feof(r->file);
        }
        if (!r->available) return r->frames ? 0 : -1;
        mp3dec_frame_info_t info;
        int samples = mp3dec_decode_frame(&r->decoder, r->input + r->offset,
                                          (int)r->available, pcm, &info);
        if (info.frame_bytes < 0 || (size_t)info.frame_bytes > r->available) return -1;
        if (!info.frame_bytes) return r->eof && r->frames ? 0 : -1;
        r->offset += info.frame_bytes;
        r->available -= info.frame_bytes;
        if (!samples) continue;
        if (info.hz != 44100 || info.channels != 2 || info.layer != 3) return -1;
        r->frames++;
        return samples * info.channels;
    }
}

void mp3_reader_close(mp3_reader_t *r)
{
    if (r->file) fclose(r->file);
    r->file = NULL;
}
