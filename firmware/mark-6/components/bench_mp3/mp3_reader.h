#pragma once
#include <stdio.h>
#include "minimp3.h"

typedef struct {
    FILE *file;
    mp3dec_t decoder;
    uint8_t input[16384];
    size_t offset, available;
    int eof;
    unsigned frames;
} mp3_reader_t;

/* 44.1 kHz stereo layer III only for this first bench test. */
int mp3_reader_open(mp3_reader_t *reader, const char *path);
/* Returns PCM sample count, 0 at EOF, or -1 on IO/format failure. */
int mp3_reader_next(mp3_reader_t *reader, int16_t pcm[MINIMP3_MAX_SAMPLES_PER_FRAME]);
void mp3_reader_close(mp3_reader_t *reader);
